---
name: tldraw
description: >-
  Draw a diagram onto a live, editable tldraw canvas in the browser — boxes,
  arrows, sticky notes, laid out automatically. Use when the user asks to "draw",
  "diagram", "map out", "visualize", or "sketch" something they want to *edit
  afterwards*, or asks for a whiteboard/canvas/tldraw. You write a small JSON
  spec; the canvas renders it and updates live as you redraw. Prefer this over
  /draw when the result should be editable or built up over several turns;
  prefer /draw when a throwaway picture in the terminal is enough.
---

# tldraw canvas

Renders a JSON spec as real tldraw shapes on a local canvas at
`http://127.0.0.1:<port>/?doc=<name>`. The user can then move, edit, restyle and
add to the diagram like any tldraw drawing.

```bash
/Users/Shared/dotfiles/skills/tldraw/bin/tldraw.sh --name auth-flow <<'EOF'
{
  "title": "Auth flow",
  "shapes": [
    { "id": "client", "type": "rect", "text": "Client", "color": "blue" },
    { "id": "api", "type": "rect", "text": "API", "color": "violet" },
    { "id": "db", "type": "ellipse", "text": "Postgres", "color": "green" }
  ],
  "arrows": [
    { "from": "client", "to": "api", "text": "POST /login" },
    { "from": "api", "to": "db" }
  ]
}
EOF
```

The script prints the URL and opens a browser tab the first time. **Run it again
with the same `--name` to redraw** — an open tab picks the change up instantly,
so iterate freely rather than starting over.

## Edits sync both ways

The spec file and the canvas mirror each other. When the user moves, restyles,
retitles or adds shapes in the browser, the spec file is rewritten about a
second later — including shapes they drew by hand, which get an auto id
(`shape1`, `arrow2`).

**So before redrawing a document that already exists, read its spec file first
and edit that** — do not compose a fresh spec from memory, or you will silently
throw away whatever the user changed:

```bash
cat ~/.local/share/tldraw-canvas/docs/auth-flow.json
```

Once written back, every position is explicit and `layout` becomes `"none"`.
To re-run the automatic layout, delete the `x`/`y` fields and set `layout` back
to `right`, `down` or `grid`.

Freehand pen strokes, images and unbound arrows cannot be expressed in the spec.
They stay on the canvas untouched, but they are not in the file — so they are
invisible to you, and they will not survive if the document is rebuilt.

## Spec

Top level: `title` (browser tab), `layout`, `shapes` (required), `arrows`.

**shapes** — each needs a unique `id` (used by arrows, never shown):

| Field | Meaning |
|-------|---------|
| `type` | `rect` (default), `ellipse`, `diamond`, `triangle`, `hexagon`, `pentagon`, `octagon`, `star`, `cloud`, `heart`, `oval`, `trapezoid`, `check-box`, `x-box`, `arrow-right`/`-left`/`-up`/`-down`, plus `note` (sticky), `text` (bare label), `frame` (titled container) |
| `text` | Label inside the shape |
| `color` | `black` (default), `grey`, `blue`, `light-blue`, `violet`, `light-violet`, `green`, `light-green`, `red`, `light-red`, `orange`, `yellow`, `white` |
| `fill` | `none` (default), `semi`, `solid`, `pattern` |
| `dash` | `draw` (default), `solid`, `dashed`, `dotted` |
| `size` | `s`, `m` (default), `l`, `xl` — text size |
| `font` | `draw` (default, handwritten), `sans`, `serif`, `mono` |
| `w`, `h` | Pixels (default 200×120). Widen for long labels |
| `x`, `y` | Explicit position — **omit these and let the layout run** |

**arrows** — `from` and `to` are shape ids. Optional `text` (label), `color`,
`dash`, `bend` (curve, e.g. `40`), `kind` (`arc` default, or `elbow` for
right-angled), `arrowhead` (`arrow` default, `none`, `dot`, `diamond`, `bar`…).
Arrows are *bound* to their shapes, so they follow when the user drags things.

**layout** — `right` (default when there are arrows: left-to-right flow),
`down` (top-to-bottom), `grid` (default with no arrows), `none`. Nodes are
placed by their depth in the arrow graph. Any shape with explicit `x`/`y` keeps
that position, so you can mix automatic and manual placement.

## Options

- `--name NAME` — the document. **Use a distinct name per diagram** (`auth-flow`,
  not `default`) so separate diagrams don't overwrite each other.
- `--no-open` — update without launching a browser.
- `--print` — also print the saved spec path.
- `--stop` — stop this user's canvas server.

## Guidance

- **Keep ids short and meaningful** (`api`, `db`) — you reference them in arrows.
- **Set `w` wider for long labels.** Text does not shrink to fit; it overflows.
- Use `note` for asides and commentary, `frame` to group a region, `text` for
  headings.
- Colour carries meaning: keep one colour per category (e.g. red for failure
  paths) rather than colouring every box differently.
- 5–25 shapes reads well. Past that, split into several named documents.
- Documents are saved per-user under `~/.local/share/tldraw-canvas/docs/`.

## When not to use this

Use the `draw` skill instead when the user just wants to *see* a picture in the
terminal — it renders inline via Mermaid and needs no browser. Use this skill
when the diagram should be editable, or when you'll refine it over several
turns.

## Notes

- Everything runs locally: nothing is uploaded, and the server binds to
  `127.0.0.1` only. One server per macOS account, so both users can draw at once.
- First run builds the canvas app with npm (~30s, once per machine). It is
  shared from `/Users/Shared/dotfiles`, so the second user gets it for free.
- The tldraw SDK is source-available and free for local use; the canvas shows a
  "get a license for production" badge. That is expected — ignore it.
