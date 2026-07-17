#!/usr/bin/env bash
# AeroSpace desktop switcher — jump to a workspace by its content name.
# - WezTerm desktops show the git branch (their window title)
# - other desktops show the app name (e.g. Slack)
# - zero dependencies: uses the native macOS chooser, nothing to install
set -uo pipefail

if ! command -v aerospace >/dev/null 2>&1; then
  osascript -e 'display notification "AeroSpace is not running" with title "Desktop switcher"' >/dev/null 2>&1
  exit 0
fi

# One line per window: workspace <TAB> app-name <TAB> window-title
fmt=$'%{workspace}\t%{app-name}\t%{window-title}'
windows="$(aerospace list-windows --all --format "$fmt" 2>/dev/null)"
[ -z "$windows" ] && exit 0

# Collapse windows into one label per non-empty desktop: "N · <name>".
# Prefer a WezTerm window's title (the branch); else the first window's app.
# Append " (+k)" when a desktop holds more than one window.
labels="$(printf '%s\n' "$windows" | awk -F'\t' '
  {
    ws = $1; app = $2; title = $3
    if (!(ws in seen)) { seen[ws] = 1; order[++n] = ws }
    if (app == "WezTerm" && title != "" && !(ws in wez)) wez[ws] = title
    if (!(ws in firstapp)) firstapp[ws] = app
    count[ws]++
  }
  END {
    for (i = 1; i <= n; i++) {
      ws = order[i]
      name = (ws in wez) ? wez[ws] : firstapp[ws]
      extra = (count[ws] > 1) ? " (+" (count[ws] - 1) ")" : ""
      printf "%s · %s%s\n", ws, name, extra
    }
  }
')"
[ -z "$labels" ] && exit 0

# Native list chooser (type to filter, Enter to pick). `paragraphs of` splits
# the newline-joined labels; the label list is passed as argv item 1.
chosen="$(osascript \
  -e 'on run argv' \
  -e 'set theList to paragraphs of (item 1 of argv)' \
  -e 'set pick to choose from list theList with prompt "Jump to desktop:" without multiple selections allowed' \
  -e 'if pick is false then return ""' \
  -e 'return item 1 of pick' \
  -e 'end run' \
  "$labels")"
[ -z "$chosen" ] && exit 0

# Label is "N · name"; the workspace id is everything before " · ".
ws="${chosen%% · *}"
aerospace workspace "$ws"
