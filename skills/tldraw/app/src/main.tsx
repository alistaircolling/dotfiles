import { StrictMode, useCallback, useRef } from 'react'
import { createRoot } from 'react-dom/client'
import { Tldraw, type Editor } from 'tldraw'
import 'tldraw/tldraw.css'
import { applySpec, serializeSpec, type Spec } from './spec'

const doc = new URLSearchParams(location.search).get('doc') || 'default'
// Identifies this tab so the server does not echo our own saves back at us.
const clientId = Math.random().toString(36).slice(2)
const SAVE_DEBOUNCE_MS = 800

async function fetchSpec(): Promise<Spec | null> {
	const res = await fetch(`/api/doc?name=${encodeURIComponent(doc)}`, { cache: 'no-store' })
	if (!res.ok) return null
	return res.json()
}

function Canvas() {
	const editorRef = useRef<Editor | null>(null)
	const specRef = useRef<Spec>({})
	// Serialized form of the last state we loaded or saved. Anything matching it
	// needs no write, which is what stops a load or a redraw echoing back out.
	const baselineRef = useRef<string | null>(null)
	const saveTimer = useRef<ReturnType<typeof setTimeout> | null>(null)

	const saveRef = useRef<() => void>(() => {})

	const draw = useCallback(async () => {
		const editor = editorRef.current
		if (!editor) return
		const spec = await fetchSpec()
		if (!spec) return
		specRef.current = spec
		applySpec(editor, doc, spec)
		// Measure without adopting: the baseline must describe what the *file*
		// holds, so anything drawn by hand still reads as unsaved below.
		baselineRef.current = JSON.stringify(serializeSpec(editor, doc, spec, false))
		document.title = spec.title ? `${spec.title} — tldraw` : `${doc} — tldraw`
		editor.zoomToFit({ animation: { duration: 200 } })
		// Picks up anything hand-drawn that the file does not know about yet;
		// a no-op when the canvas already matches.
		saveRef.current()
	}, [])

	const save = useCallback(async () => {
		const editor = editorRef.current
		if (!editor) return
		const next = serializeSpec(editor, doc, specRef.current)
		const compact = JSON.stringify(next)
		if (compact === baselineRef.current) return
		baselineRef.current = compact
		await fetch(`/api/doc?name=${encodeURIComponent(doc)}&client=${clientId}`, {
			method: 'POST',
			headers: { 'content-type': 'application/json' },
			body: JSON.stringify(next, null, 2),
		}).catch(() => {})
	}, [])
	saveRef.current = save

	const onMount = useCallback(
		(editor: Editor) => {
			editorRef.current = editor
			// Handy from the browser console for poking at the canvas.
			;(window as unknown as { editor: Editor }).editor = editor
			draw()

			// The server pushes an event whenever the spec file is rewritten,
			// and reconnects on its own if the server restarts.
			const events = new EventSource(
				`/api/events?doc=${encodeURIComponent(doc)}&client=${clientId}`
			)
			events.addEventListener('update', () => draw())

			const unlisten = editor.store.listen(
				() => {
					if (saveTimer.current) clearTimeout(saveTimer.current)
					saveTimer.current = setTimeout(save, SAVE_DEBOUNCE_MS)
				},
				{ scope: 'document', source: 'user' }
			)

			return () => {
				events.close()
				unlisten()
				if (saveTimer.current) clearTimeout(saveTimer.current)
			}
		},
		[draw, save]
	)

	return <Tldraw persistenceKey={`tldraw-canvas:${doc}`} onMount={onMount} />
}

createRoot(document.getElementById('root')!).render(
	<StrictMode>
		<Canvas />
	</StrictMode>
)
