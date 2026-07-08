---
name: draw
description: Draw a diagram or generate an image and render it inline in the WezTerm terminal — using free, no-key web services. Use when the user asks to "draw", "diagram", "visualize", "sketch", "illustrate", "show me a picture/photo of", or "make an image of" something; or proactively when a visual communicates an idea far better than text (architecture, a flow, a layout, a spatial concept). Two engines: labelled diagrams (flows, architecture, ER) render exactly via Mermaid; illustrations and photos generate via a free image model. You write the source/prompt; the script renders it, so your token cost is just the text.
---

# Draw

Two free, no-API-key engines. Pick by what the user needs:

| Need | Use | Engine | Text/labels |
|------|-----|--------|-------------|
| Diagram with labels — flow, architecture, ER, sequence, state, mindmap | `diagram.sh` | kroki.io (Mermaid etc.) | **Exact** |
| Illustration, photo, concept art, mockup, texture | `image.sh` | Pollinations (Flux) | Garbled — avoid text |

Both save a file, render it inline via `wezterm imgcat`, and print the path on the last line. No key, no billing, no local install — just `curl`/`jq`/`wezterm` (already present). Prompts/source are sent to a third-party service, so don't use these for sensitive or proprietary content.

## When to use it

- The user explicitly asks for a diagram, image, picture, illustration, sketch, mockup, or photo.
- A visual is clearly the better medium than text/table/code.

Do **not** use it when a short list, a code block, or a table already does the job. And for any visual that needs **accurate text** (almost every real diagram), use `diagram.sh`, not `image.sh`.

## diagram.sh — exact diagrams (preferred for anything labelled)

Write Mermaid (default) and pipe it in:

```bash
~/.claude/skills/draw/diagram.sh <<'EOF'
flowchart LR
  User --> API --> Database
EOF
```

- `--type TYPE` — `mermaid` (default), `graphviz`, `d2`, `plantuml`, `erd`, … match it to the source.
- `--height PCT` — inline height (default 60). `--out FILE`, `--no-show` as usual.
- Mermaid covers flowchart, sequence, class, state, ER, gantt, mindmap, timeline, gitgraph, pie. Reach for it first — it's deterministic and the labels come out right.

## image.sh — free illustrations / photos

```bash
~/.claude/skills/draw/image.sh "a cozy cinematic coffee shop at golden hour, 35mm, shallow depth of field"
```

- `--size WxH` (default 1024x1024), `--seed N` (reproducible), `--model M` (default flux), `--height PCT`.
- Describe subject, setting, lighting, lens, mood. **Do not** ask for text/labels in the image — the model mangles them; use `diagram.sh` for that.

## Showing the result

Both scripts display the image automatically — no extra step:

- When **you** (the agent) run a script inside WezTerm, it opens a **horizontal split below the current pane** and renders the image there via `show.sh` (a tool subprocess has no TTY, but a spawned pane does). A single preview pane is reused — each new draw replaces the last, so panes don't pile up. The user closes it with Enter.
- When a **human** runs the script directly, it renders inline with `wezterm imgcat`.

The script also prints the saved path on the last line. After drawing, just reference the result briefly — the user can already see it. (If you need the image in the conversation itself, Read that path; the user can also re-open any saved file with `img <path>`.)

## Notes

- Free hosted services: `kroki.io` (deterministic diagram rendering) and `image.pollinations.ai` (Flux image model). Both work with no account.
- No `GEMINI_API_KEY` or any key is needed. (An earlier version used Gemini; that key in `shell/.secrets` is now unused and can be removed.)
