// Translates a declarative diagram spec into real tldraw shapes.
// - The spec file is the source of truth for shapes it owns.
// - Ownership is tagged in shape `meta`, so hand-drawn shapes survive a redraw.
import {
	createShapeId,
	renderPlaintextFromRichText,
	toRichText,
	type Editor,
	type TLShape,
	type TLArrowShapeArrowheadStyle,
	type TLArrowShapeKind,
	type TLDefaultColorStyle,
	type TLDefaultDashStyle,
	type TLDefaultFillStyle,
	type TLDefaultFontStyle,
	type TLDefaultSizeStyle,
	type TLGeoShapeGeoStyle,
	type TLShapeId,
} from 'tldraw'

export interface SpecNode {
	id: string
	type?: string
	x?: number
	y?: number
	w?: number
	h?: number
	text?: string
	color?: string
	fill?: string
	dash?: string
	size?: string
	font?: string
}

export interface SpecArrow {
	from: string
	to: string
	text?: string
	color?: string
	dash?: string
	bend?: number
	kind?: string
	arrowhead?: string
}

export interface Spec {
	title?: string
	layout?: 'right' | 'down' | 'grid' | 'none'
	shapes?: SpecNode[]
	arrows?: SpecArrow[]
}

// The spec is hand-written JSON, so every style value is checked against the
// real tldraw enum and falls back to a default rather than failing validation.
function oneOf<T extends string>(allowed: readonly T[]) {
	const set = new Set<string>(allowed)
	return (value: string | undefined, fallback: T): T =>
		value !== undefined && set.has(value) ? (value as T) : fallback
}

const color = oneOf<TLDefaultColorStyle>([
	'black',
	'grey',
	'light-violet',
	'violet',
	'blue',
	'light-blue',
	'yellow',
	'orange',
	'green',
	'light-green',
	'light-red',
	'red',
	'white',
])
const fill = oneOf<TLDefaultFillStyle>(['none', 'semi', 'solid', 'pattern', 'fill', 'lined-fill'])
const dash = oneOf<TLDefaultDashStyle>(['draw', 'solid', 'dashed', 'dotted', 'none'])
const size = oneOf<TLDefaultSizeStyle>(['s', 'm', 'l', 'xl'])
const font = oneOf<TLDefaultFontStyle>(['draw', 'sans', 'serif', 'mono'])
const arrowKind = oneOf<TLArrowShapeKind>(['arc', 'elbow'])
const arrowhead = oneOf<TLArrowShapeArrowheadStyle>([
	'none',
	'arrow',
	'triangle',
	'square',
	'dot',
	'pipe',
	'diamond',
	'inverted',
	'bar',
])

// tldraw's geo shape covers most box-like forms; these are the friendly aliases.
const GEO_ALIASES: Record<string, TLGeoShapeGeoStyle> = {
	rect: 'rectangle',
	rectangle: 'rectangle',
	box: 'rectangle',
	square: 'rectangle',
	ellipse: 'ellipse',
	circle: 'ellipse',
	oval: 'oval',
	diamond: 'diamond',
	rhombus: 'rhombus',
	triangle: 'triangle',
	hexagon: 'hexagon',
	pentagon: 'pentagon',
	octagon: 'octagon',
	star: 'star',
	cloud: 'cloud',
	heart: 'heart',
	trapezoid: 'trapezoid',
	'check-box': 'check-box',
	'x-box': 'x-box',
	'arrow-right': 'arrow-right',
	'arrow-left': 'arrow-left',
	'arrow-up': 'arrow-up',
	'arrow-down': 'arrow-down',
}

const DEFAULT_W = 200
const DEFAULT_H = 120
const NOTE_SIZE = 200
const GAP_MAIN = 140 // between layers
const GAP_CROSS = 60 // within a layer

const nodeW = (n: SpecNode) => n.w ?? (n.type === 'note' ? NOTE_SIZE : DEFAULT_W)
const nodeH = (n: SpecNode) => n.h ?? (n.type === 'note' ? NOTE_SIZE : DEFAULT_H)

/**
 * Longest-path layering over the arrow graph (Kahn's algorithm).
 * Nodes left over from a cycle keep layer 0 rather than hanging the layout.
 */
function computeLayers(ids: string[], edges: Array<[string, string]>): Map<string, number> {
	const out = new Map<string, string[]>(ids.map((id) => [id, []]))
	const indeg = new Map<string, number>(ids.map((id) => [id, 0]))
	for (const [a, b] of edges) {
		if (!out.has(a) || !out.has(b) || a === b) continue
		out.get(a)!.push(b)
		indeg.set(b, indeg.get(b)! + 1)
	}
	const layer = new Map<string, number>(ids.map((id) => [id, 0]))
	const queue = ids.filter((id) => indeg.get(id) === 0)
	const queued = new Set(queue)
	while (queue.length) {
		const n = queue.shift()!
		for (const m of out.get(n)!) {
			layer.set(m, Math.max(layer.get(m)!, layer.get(n)! + 1))
			indeg.set(m, indeg.get(m)! - 1)
			if (indeg.get(m) === 0 && !queued.has(m)) {
				queued.add(m)
				queue.push(m)
			}
		}
	}
	return layer
}

/** Fills in x/y for any node that did not specify them. Explicit coords always win. */
function layout(spec: Spec): Map<string, { x: number; y: number }> {
	const shapes = spec.shapes ?? []
	const pos = new Map<string, { x: number; y: number }>()
	const needsLayout = shapes.filter((s) => s.x === undefined || s.y === undefined)
	for (const s of shapes) {
		if (s.x !== undefined && s.y !== undefined) pos.set(s.id, { x: s.x, y: s.y })
	}
	if (needsLayout.length === 0) return pos

	const mode = spec.layout ?? (spec.arrows?.length ? 'right' : 'grid')

	if (mode === 'none') {
		needsLayout.forEach((s, i) => pos.set(s.id, { x: s.x ?? i * 40, y: s.y ?? i * 40 }))
		return pos
	}

	if (mode === 'grid' || !spec.arrows?.length) {
		const cols = Math.max(1, Math.ceil(Math.sqrt(needsLayout.length)))
		const colW = Math.max(...needsLayout.map(nodeW)) + GAP_CROSS
		const rowH = Math.max(...needsLayout.map(nodeH)) + GAP_CROSS
		needsLayout.forEach((s, i) => {
			pos.set(s.id, {
				x: s.x ?? (i % cols) * colW,
				y: s.y ?? Math.floor(i / cols) * rowH,
			})
		})
		return pos
	}

	// Layered flow: group by graph depth, then centre each layer on the cross axis.
	const edges = spec.arrows.map((a) => [a.from, a.to] as [string, string])
	const layers = computeLayers(
		shapes.map((s) => s.id),
		edges
	)
	const byLayer = new Map<number, SpecNode[]>()
	for (const s of needsLayout) {
		const l = layers.get(s.id) ?? 0
		if (!byLayer.has(l)) byLayer.set(l, [])
		byLayer.get(l)!.push(s)
	}

	const horizontal = mode === 'right'
	const layerKeys = [...byLayer.keys()].sort((a, b) => a - b)
	// Main-axis offset of each layer, accumulated from the widest node in each.
	const mainOffsets = new Map<number, number>()
	let cursor = 0
	for (const l of layerKeys) {
		mainOffsets.set(l, cursor)
		const extent = Math.max(...byLayer.get(l)!.map(horizontal ? nodeW : nodeH))
		cursor += extent + GAP_MAIN
	}
	const crossExtent = (nodes: SpecNode[]) =>
		nodes.reduce((sum, n) => sum + (horizontal ? nodeH(n) : nodeW(n)) + GAP_CROSS, -GAP_CROSS)
	const widestCross = Math.max(...layerKeys.map((l) => crossExtent(byLayer.get(l)!)))

	for (const l of layerKeys) {
		const nodes = byLayer.get(l)!
		let cross = (widestCross - crossExtent(nodes)) / 2
		for (const s of nodes) {
			const main = mainOffsets.get(l)!
			pos.set(s.id, {
				x: s.x ?? (horizontal ? main : cross),
				y: s.y ?? (horizontal ? cross : main),
			})
			cross += (horizontal ? nodeH(s) : nodeW(s)) + GAP_CROSS
		}
	}
	return pos
}

/** Builds the tldraw shape record for one spec node. */
function toShape(docKey: string, n: SpecNode, at: { x: number; y: number }, id: TLShapeId) {
	const type = (n.type ?? 'rect').toLowerCase()
	const meta = { specDoc: docKey, specId: n.id }
	const richText = toRichText(n.text ?? '')

	if (type === 'note') {
		return {
			id,
			type: 'note' as const,
			x: at.x,
			y: at.y,
			meta,
			props: {
				richText,
				color: color(n.color, 'yellow'),
				size: size(n.size, 'm'),
				font: font(n.font, 'draw'),
			},
		}
	}

	if (type === 'text' || type === 'label') {
		return {
			id,
			type: 'text' as const,
			x: at.x,
			y: at.y,
			meta,
			props: {
				richText,
				color: color(n.color, 'black'),
				size: size(n.size, 'm'),
				font: font(n.font, 'draw'),
			},
		}
	}

	if (type === 'frame' || type === 'group') {
		return {
			id,
			type: 'frame' as const,
			x: at.x,
			y: at.y,
			meta,
			props: { w: nodeW(n), h: nodeH(n), name: n.text ?? '' },
		}
	}

	return {
		id,
		type: 'geo' as const,
		x: at.x,
		y: at.y,
		meta,
		props: {
			geo: GEO_ALIASES[type] ?? 'rectangle',
			w: nodeW(n),
			h: nodeH(n),
			richText,
			color: color(n.color, 'black'),
			fill: fill(n.fill, 'none'),
			dash: dash(n.dash, 'draw'),
			size: size(n.size, 'm'),
			font: font(n.font, 'draw'),
		},
	}
}

/**
 * Replaces this document's shapes with the ones in `spec`.
 * Shapes the user drew by hand carry no `specDoc` meta, so they are left alone.
 */
export function applySpec(editor: Editor, docKey: string, spec: Spec) {
	const shapes = spec.shapes ?? []
	const arrows = spec.arrows ?? []
	const shapeId = (specId: string) => createShapeId(`${docKey}::${specId}`)

	editor.run(
		() => {
			const owned = editor
				.getCurrentPageShapes()
				.filter((s) => s.meta?.specDoc === docKey)
				.map((s) => s.id)
			if (owned.length) editor.deleteShapes(owned)

			const pos = layout(spec)
			const known = new Set(shapes.map((s) => s.id))
			editor.createShapes(
				shapes.map((n) => toShape(docKey, n, pos.get(n.id) ?? { x: 0, y: 0 }, shapeId(n.id)))
			)

			arrows.forEach((a, i) => {
				if (!known.has(a.from) || !known.has(a.to)) return
				const arrowId = createShapeId(`${docKey}::arrow::${i}`)
				const from = editor.getShapePageBounds(shapeId(a.from))
				const to = editor.getShapePageBounds(shapeId(a.to))
				if (!from || !to) return

				editor.createShape({
					id: arrowId,
					type: 'arrow',
					x: 0,
					y: 0,
					meta: { specDoc: docKey },
					props: {
						start: { x: from.center.x, y: from.center.y },
						end: { x: to.center.x, y: to.center.y },
						richText: toRichText(a.text ?? ''),
						color: color(a.color, 'black'),
						dash: dash(a.dash, 'draw'),
						bend: a.bend ?? 0,
						kind: arrowKind(a.kind, 'arc'),
						arrowheadEnd: arrowhead(a.arrowhead, 'arrow'),
					},
				})
				// Bindings make the arrow follow the shapes when they are moved.
				editor.createBindings(
					(['start', 'end'] as const).map((terminal) => ({
						fromId: arrowId,
						toId: shapeId(terminal === 'start' ? a.from : a.to),
						type: 'arrow' as const,
						props: {
							terminal,
							normalizedAnchor: { x: 0.5, y: 0.5 },
							isExact: false,
							isPrecise: false,
							snap: 'none' as const,
						},
					}))
				)
			})
		},
		{ history: 'ignore' }
	)
}

// --- writing the canvas back out to a spec ------------------------------------

// Reverse of GEO_ALIASES, preferring the short name we document.
const GEO_TO_ALIAS: Record<string, string> = { rectangle: 'rect', ellipse: 'ellipse' }
for (const [alias, geo] of Object.entries(GEO_ALIASES)) {
	if (!(geo in GEO_TO_ALIAS)) GEO_TO_ALIAS[geo] = alias
}

/** Shape types the spec can express; anything else stays browser-only. */
const SERIALIZABLE = new Set(['geo', 'note', 'text', 'frame'])

/** Only writes a field when it differs from the default, to keep the JSON readable. */
function put<T>(target: Record<string, unknown>, key: string, value: T, fallback: T) {
	if (value !== undefined && value !== fallback) target[key] = value
}

/**
 * Gives every serializable shape on the page a stable spec id, so the file and
 * the canvas describe exactly the same set of shapes. Shapes the user drew by
 * hand are adopted into the document here.
 */
function adoptShapes(editor: Editor, docKey: string): TLShape[] {
	const taken = new Set<string>()
	for (const s of editor.getCurrentPageShapes()) {
		if (s.meta?.specDoc === docKey && typeof s.meta?.specId === 'string') taken.add(s.meta.specId)
	}

	let counter = 1
	const nextId = (prefix: string) => {
		let id = `${prefix}${counter++}`
		while (taken.has(id)) id = `${prefix}${counter++}`
		taken.add(id)
		return id
	}

	const adopted: TLShape[] = []
	for (const s of editor.getCurrentPageShapes()) {
		if (!SERIALIZABLE.has(s.type) && s.type !== 'arrow') continue
		if (s.meta?.specDoc === docKey && typeof s.meta?.specId === 'string') continue
		adopted.push(s)
		editor.updateShape({
			id: s.id,
			type: s.type,
			meta: { ...s.meta, specDoc: docKey, specId: nextId(s.type === 'arrow' ? 'arrow' : 'shape') },
		})
	}
	return adopted
}

/**
 * Reads the canvas back into a spec. Positions become explicit, since the point
 * of writing back is to keep wherever the user dragged things to.
 *
 * `adopt` must be false when the result is only being measured rather than
 * saved — adopting is a mutation, and adopting shapes into a baseline that is
 * never written would strand them out of the file for good.
 */
export function serializeSpec(editor: Editor, docKey: string, previous: Spec, adopt = true): Spec {
	if (adopt) editor.run(() => adoptShapes(editor, docKey), { history: 'ignore' })

	const owned = editor
		.getCurrentPageShapes()
		.filter((s) => s.meta?.specDoc === docKey)
		.sort((a, b) => (a.index < b.index ? -1 : a.index > b.index ? 1 : 0))

	const specIdOf = new Map(owned.map((s) => [s.id, s.meta.specId as string]))
	const shapes: SpecNode[] = []
	const arrows: SpecArrow[] = []

	for (const s of owned) {
		const id = s.meta.specId as string
		const props = s.props as Record<string, any>

		if (s.type === 'arrow') {
			const bindings = editor.getBindingsFromShape(s, 'arrow')
			const from = bindings.find((b) => b.props.terminal === 'start')
			const to = bindings.find((b) => b.props.terminal === 'end')
			// An arrow with a loose end cannot be expressed as from/to; leave it
			// on the canvas rather than writing something misleading.
			if (!from || !to) continue
			const fromId = specIdOf.get(from.toId)
			const toId = specIdOf.get(to.toId)
			if (!fromId || !toId) continue

			const arrow: Record<string, unknown> = { from: fromId, to: toId }
			put(arrow, 'text', renderPlaintextFromRichText(editor, props.richText), '')
			put(arrow, 'color', props.color, 'black')
			put(arrow, 'dash', props.dash, 'draw')
			put(arrow, 'bend', Math.round(props.bend), 0)
			put(arrow, 'kind', props.kind, 'arc')
			put(arrow, 'arrowhead', props.arrowheadEnd, 'arrow')
			arrows.push(arrow as unknown as SpecArrow)
			continue
		}

		if (!SERIALIZABLE.has(s.type)) continue

		const node: Record<string, unknown> = { id }
		const bounds = editor.getShapePageBounds(s.id)

		if (s.type === 'geo') node.type = GEO_TO_ALIAS[props.geo] ?? 'rect'
		else node.type = s.type

		node.x = Math.round(s.x)
		node.y = Math.round(s.y)

		const text = s.type === 'frame' ? props.name : renderPlaintextFromRichText(editor, props.richText)
		put(node, 'text', text, '')

		if (s.type === 'geo' || s.type === 'frame') {
			node.w = Math.round(props.w)
			node.h = Math.round(props.h)
		} else if (bounds) {
			// Notes and text size themselves; record what they came out as.
			node.w = Math.round(bounds.width)
			node.h = Math.round(bounds.height)
		}

		put(node, 'color', props.color, s.type === 'note' ? 'yellow' : 'black')
		put(node, 'fill', props.fill, 'none')
		put(node, 'dash', props.dash, 'draw')
		put(node, 'size', props.size, 'm')
		put(node, 'font', props.font, 'draw')
		shapes.push(node as unknown as SpecNode)
	}

	return {
		...(previous.title ? { title: previous.title } : {}),
		// Every position is explicit now, so record that rather than a stale mode.
		layout: 'none',
		shapes,
		arrows,
	}
}
