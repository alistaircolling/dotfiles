#!/usr/bin/env bash
# show.sh — display an image file in a managed WezTerm split pane.
#
# Opens a horizontal split BELOW the current pane and renders the image there
# with `wezterm imgcat` (the split has a real TTY, so imgcat works even though
# the caller — a tool subprocess — has none). A single preview pane is reused:
# the previous one is closed first so panes don't pile up across draws.
#
# Usage: show.sh <image-file> [height-percent]
#
# Used automatically by diagram.sh / image.sh when run as a tool inside WezTerm.

set -euo pipefail

IMG="${1:?show.sh: need an image path}"
PCT="${2:-50}"

[[ -f "$IMG" ]] || { echo "show.sh: file not found: $IMG" >&2; exit 2; }
command -v wezterm >/dev/null 2>&1 || { echo "show.sh: wezterm not found" >&2; exit 1; }
[[ -n "${WEZTERM_PANE:-}" ]] || { echo "show.sh: not inside a WezTerm pane" >&2; exit 1; }

state="${TMPDIR:-/tmp}/claude-draw-preview-pane"

# Close the previous preview pane, if any (harmless if it's already gone).
if [[ -f "$state" ]]; then
  old="$(cat "$state" 2>/dev/null || true)"
  [[ -n "$old" ]] && wezterm cli kill-pane --pane-id "$old" 2>/dev/null || true
fi

# Shell-quote the path so spaces/quotes survive into the spawned pane's command
# (the mux server spawns the pane, so env vars from here are NOT inherited).
qimg=$(printf '%q' "$IMG")

# --width/--height 100% scales the image to fill the pane; aspect ratio is
# preserved by default. Height 96% leaves a line for the close hint.
pane=$(wezterm cli split-pane --bottom --percent "$PCT" -- \
  bash -lc "wezterm imgcat --width 100% --height 96% ${qimg}; printf '\n[draw preview — press enter to close]'; read -r _")

printf '%s' "$pane" > "$state"
