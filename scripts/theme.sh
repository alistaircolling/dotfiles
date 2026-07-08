#!/usr/bin/env zsh

set -euo pipefail

DOTFILES_ROOT="/Users/Shared/dotfiles"
THEMES_DIR="$DOTFILES_ROOT/themes"
DEFAULT_THEME="catppuccin-mocha"
CURRENT_FILE="$THEMES_DIR/current"
FAVORITES_FILE="$THEMES_DIR/favorites"
# Absolute path to this script, so fzf preview callbacks can re-invoke it
SELF="${0:A}"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

list_themes() {
  emulate -L zsh
  setopt null_glob
  local -a themes
  themes=()
  local f base
  for f in "$THEMES_DIR"/*.lua; do
    base="${f:t:r}"
    [[ "$base" == loader ]] && continue
    themes+=("$base")
  done
  printf '%s\n' "${themes[@]}" | sort -f
}

current_theme() {
  if [[ -s "$CURRENT_FILE" ]]; then
    local value
    value="$(<"$CURRENT_FILE")"
    value="$(trim "$value")"
    if [[ -n "$value" ]]; then
      printf '%s\n' "$value"
      return
    fi
  fi
  printf '%s\n' "$DEFAULT_THEME"
}

apply_theme() {
  local key="$1"
  if [[ ! -f "$THEMES_DIR/$key.lua" ]]; then
    printf 'Unknown theme: %s\n' "$key"
    return 1
  fi
  printf '%s\n' "$key" > "$CURRENT_FILE"
  sync_claude_theme "$key"
  nudge_current_window "$key"
  printf 'Applied theme: %s\n' "$key"
}

# Re-touch themes/current once, shortly after a commit, so the *focused*
# WezTerm window repaints — not just newly spawned ones.
#
# During live preview, fzf writes themes/current on every highlight change.
# The final commit write lands right on top of that burst, so WezTerm's file
# watcher coalesces them into a single reload that can read a pre-final value
# and then sees no further change — leaving the current window on the
# previously-previewed theme. A single isolated write, fired after the picker
# has closed and the burst has settled, gives the watcher a clean reload event.
# (An isolated write is exactly what Leader+>/< cycling does, which works.)
#
# Guards:
# - backgrounded + disowned so it never blocks the prompt
# - bails if a newer theme was set in the meantime, to avoid clobbering it
nudge_current_window() {
  local key="$1"
  ( sleep 0.4
    [[ "$(current_theme)" == "$key" ]] || exit 0
    printf '%s\n' "$key" > "$CURRENT_FILE"
  ) >/dev/null 2>&1 &!
}

# Lightweight apply for live preview while browsing a picker.
# - writes only themes/current (WezTerm + Neovim watch it and reload)
# - skips the Claude sync and messages so it stays instant
# - no-ops when already on the theme, to avoid a redundant reload/flicker
preview_theme() {
  local key="$1"
  [[ -n "$key" && -f "$THEMES_DIR/$key.lua" ]] || return 0
  [[ "$(current_theme)" == "$key" ]] && return 0
  printf '%s\n' "$key" > "$CURRENT_FILE"
}

# --- Swatch preview -------------------------------------------------------
# Render a theme's colors plus a readability sample; wired as the fzf --preview
# so you can judge contrast (text, caret, palette) before committing.
_hex_rgb() { local h="${1#\#}"; printf '%d;%d;%d' "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"; }

_theme_field() {  # <file> <lua-key> -> '#rrggbb'
  local line
  line="$(command grep -m1 "$2 = '#" "$1" 2>/dev/null || true)"
  [[ "$line" =~ "'(#[0-9a-fA-F]{6})'" ]] && printf '%s' "${match[1]}"
  return 0
}

_theme_array() {  # <file> <key> -> one hex per line (contents of `key = { ... }`)
  local line in=0 rest
  while IFS= read -r line; do
    if (( in )); then
      [[ "$line" == *"}"* ]] && break
      rest="$line"
      while [[ "$rest" =~ '#[0-9a-fA-F]{6}' ]]; do
        printf '%s\n' "$MATCH"
        rest="${rest#*$MATCH}"
      done
    elif [[ "$line" == *"$2 = {"* ]]; then
      in=1
    fi
  done < "$1"
  return 0
}

swatch() {
  local key="${1:-}" file="$THEMES_DIR/${1:-}.lua"
  [[ -n "$key" && -f "$file" ]] || { printf 'Unknown theme: %s\n' "$key"; return 0; }
  local name bg fg cbg cfg
  name="$(command grep -m1 "name = '" "$file" 2>/dev/null || true)"
  [[ "$name" =~ "name = '([^']+)'" ]] && name="${match[1]}" || name="$key"
  bg="$(_theme_field "$file" background)"; [[ -z "$bg" ]] && bg='#000000'
  fg="$(_theme_field "$file" foreground)"; [[ -z "$fg" ]] && fg='#ffffff'
  cbg="$(_theme_field "$file" cursor_bg)"; [[ -z "$cbg" ]] && cbg="$fg"
  cfg="$(_theme_field "$file" cursor_fg)"; [[ -z "$cfg" ]] && cfg="$bg"
  local -a ansi brights
  ansi=("${(@f)$(_theme_array "$file" ansi)}")
  brights=("${(@f)$(_theme_array "$file" brights)}")

  local R=$'\033[0m'
  local BG=$'\033[48;2;'"$(_hex_rgb "$bg")"'m'$'\033[38;2;'"$(_hex_rgb "$fg")"'m'
  local CUR=$'\033[48;2;'"$(_hex_rgb "$cbg")"'m'$'\033[38;2;'"$(_hex_rgb "$cfg")"'m'
  local c
  printf '\n  %s %s %s\n\n' "$BG" "$name" "$R"
  printf '  %s%s%s%s%s%s%s\n' \
    "$BG" "  the quick brown fox " "$CUR" "I" "$BG" " jumps 0123456789 " "$R"
  printf '  %s%s%s\n\n' "$BG" "  ~/dev \$ git commit --amend -m msg  " "$R"
  printf '  ansi   '
  for c in "${ansi[@]}"; do [[ -n "$c" ]] && printf '\033[48;2;%sm    %s' "$(_hex_rgb "$c")" "$R"; done
  printf '\n  bright '
  for c in "${brights[@]}"; do [[ -n "$c" ]] && printf '\033[48;2;%sm    %s' "$(_hex_rgb "$c")" "$R"; done
  printf '\n\n  caret %s   fg %s   bg %s\n' "$cbg" "$fg" "$bg"
  return 0
}

# Match Claude Code's UI theme to the terminal theme
# - reads nvim background from theme file
# - uses the -ansi variants so Claude renders with our terminal palette (stays
#   in sync with the theme and inherits our light-theme contrast fixes)
# - applies to new Claude sessions only
sync_claude_theme() {
  local key="$1" mode="dark-ansi"
  [[ -f "$HOME/.claude.json" ]] || return 0
  command -v node >/dev/null 2>&1 || return 0
  if grep -qE "background *= *'light'" "$THEMES_DIR/$key.lua"; then
    mode="light-ansi"
  fi
  node -e '
    const fs = require("fs");
    const path = process.env.HOME + "/.claude.json";
    const j = JSON.parse(fs.readFileSync(path, "utf8"));
    j.theme = process.argv[1];
    fs.writeFileSync(path, JSON.stringify(j, null, 2));
  ' "$mode" 2>/dev/null || true
}

ensure_favorites_file() {
  if [[ ! -f "$FAVORITES_FILE" ]]; then
    printf '%s\n' "$DEFAULT_THEME" > "$FAVORITES_FILE"
    return
  fi
  if [[ ! -s "$FAVORITES_FILE" ]]; then
    printf '%s\n' "$DEFAULT_THEME" > "$FAVORITES_FILE"
    return
  fi
  if ! awk -v d="$DEFAULT_THEME" '$0==d { found=1 } END { exit(found ? 0 : 1) }' "$FAVORITES_FILE"; then
    {
      printf '%s\n' "$DEFAULT_THEME"
      cat "$FAVORITES_FILE"
    } | awk 'NF && !seen[$0]++' > "$FAVORITES_FILE.tmp"
    mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
  fi
}

favorites_list() {
  ensure_favorites_file
  awk 'NF && !seen[$0]++' "$FAVORITES_FILE"
}

favorite_add() {
  local key="${1:-$(current_theme)}"
  ensure_favorites_file
  if favorites_list | awk -v k="$key" '$0==k { found=1 } END { exit(found ? 0 : 1) }'; then
    printf 'Already in favorites: %s\n' "$key"
    return
  fi
  printf '%s\n' "$key" >> "$FAVORITES_FILE"
  printf 'Added favorite: %s\n' "$key"
}

favorite_remove() {
  local key="${1:-$(current_theme)}"
  if [[ "$key" == "$DEFAULT_THEME" ]]; then
    printf 'Default theme cannot be removed from favorites: %s\n' "$DEFAULT_THEME"
    return
  fi
  ensure_favorites_file
  awk -v k="$key" '$0!=k' "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp"
  mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
  ensure_favorites_file
  printf 'Removed favorite: %s\n' "$key"
}

favorite_cycle() {
  local direction="$1"
  ensure_favorites_file
  local -a favorites
  favorites=("${(@f)$(favorites_list)}")
  local count="${#favorites[@]}"
  if (( count == 0 )); then
    printf 'No favorites found\n'
    return 1
  fi

  local cur idx
  cur="$(current_theme)"
  idx=0
  local i
  for (( i=1; i<=count; i++ )); do
    if [[ "${favorites[i]}" == "$cur" ]]; then
      idx="$i"
      break
    fi
  done

  if [[ "$direction" == "next" ]]; then
    idx=$(( (idx % count) + 1 ))
  else
    if (( idx == 0 )); then
      idx="$count"
    else
      idx=$(( idx - 1 ))
      (( idx < 1 )) && idx="$count"
    fi
  fi

  apply_theme "${favorites[idx]}"
}

all_themes_cycle() {
  local direction="$1"
  local -a themes
  themes=("${(@f)$(list_themes)}")
  local count="${#themes[@]}"
  if (( count == 0 )); then
    printf 'No themes found\n'
    return 1
  fi

  local cur idx
  cur="$(current_theme)"
  idx=0
  local i
  for (( i=1; i<=count; i++ )); do
    if [[ "${themes[i]}" == "$cur" ]]; then
      idx="$i"
      break
    fi
  done

  if [[ "$direction" == "next" ]]; then
    idx=$(( (idx % count) + 1 ))
  else
    if (( idx == 0 )); then
      idx="$count"
    else
      idx=$(( idx - 1 ))
      (( idx < 1 )) && idx="$count"
    fi
  fi

  apply_theme "${themes[idx]}"
}

favorite_pick() {
  ensure_favorites_file
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is required for interactive pick\n'
    return 1
  fi
  local original selected
  original="$(current_theme)"
  selected="$(
    favorites_list | fzf \
      --height=70% \
      --layout=reverse \
      --border \
      --prompt='Favorite theme > ' \
      --preview "$SELF swatch {}" \
      --preview-window='right,55%,border-left' \
      --bind "start:execute-silent($SELF preview {})" \
      --bind "focus:execute-silent($SELF preview {})" \
      --header='Live preview in all panes · Enter to keep · Esc to cancel'
  )" || selected=""
  if [[ -z "$selected" ]]; then
    preview_theme "$original"   # revert the preview
    return 0
  fi
  apply_theme "$selected"
}

search_theme() {
  local query="${1:-}"
  if command -v fzf >/dev/null 2>&1; then
    local original selected
    original="$(current_theme)"
    selected="$(
      list_themes | fzf \
        --height=70% \
        --layout=reverse \
        --border \
        --prompt='Theme search > ' \
        --query="$query" \
        --preview "$SELF swatch {}" \
        --preview-window='right,55%,border-left' \
        --bind "start:execute-silent($SELF preview {})" \
        --bind "focus:execute-silent($SELF preview {})" \
        --header='Type to filter · live preview in all panes · Enter to keep · Esc to cancel'
    )" || selected=""
    if [[ -z "$selected" ]]; then
      preview_theme "$original"   # revert the preview
      return 0
    fi
    apply_theme "$selected"
    return
  fi

  local selected
  selected="$(list_themes | awk -v q="$query" 'BEGIN{IGNORECASE=1} index($0,q){print; exit}')"
  if [[ -n "$selected" ]]; then
    apply_theme "$selected"
    return
  fi
  printf 'No matching themes\n'
}

show_status() {
  printf 'Current:  %s\n' "$(current_theme)"
  printf 'Default:  %s\n' "$DEFAULT_THEME"
  printf 'Favorites:\n'
  favorites_list | sed 's/^/  - /'
}

reset_theme() {
  apply_theme "$DEFAULT_THEME"
}

interactive_menu() {
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is required for interactive mode\n'
    return 1
  fi

  local choice
  choice="$(
    printf '%s\n' \
      'Search and apply theme' \
      'Next theme (all)' \
      'Previous theme (all)' \
      'Next favorite' \
      'Previous favorite' \
      'Pick favorite' \
      'Add current to favorites' \
      'Remove current from favorites' \
      'Reset to default' \
      'Show status' \
      'Quit' \
      | fzf --height=55% --layout=reverse --border --prompt='Theme menu > ' --header="Current: $(current_theme)"
  )"

  case "$choice" in
    'Search and apply theme') search_theme ;;
    'Next theme (all)') all_themes_cycle next ;;
    'Previous theme (all)') all_themes_cycle prev ;;
    'Next favorite') favorite_cycle next ;;
    'Previous favorite') favorite_cycle prev ;;
    'Pick favorite') favorite_pick ;;
    'Add current to favorites') favorite_add ;;
    'Remove current from favorites') favorite_remove ;;
    'Reset to default') reset_theme ;;
    'Show status') show_status ;;
    *) ;;
  esac
}

usage() {
  cat <<'EOF'
Usage:
  theme                    # interactive menu
  theme search [query]     # fuzzy search and apply
  theme set <key>          # apply theme (filename in themes/ without .lua)
  theme current            # print current theme key
  theme get                # same as current
  theme reset              # apply default (catppuccin-mocha)
  theme status             # current/default/favorites
  theme next [all|fav]     # next theme (default: all)
  theme prev [all|fav]     # previous theme (default: all)
  theme list               # list theme keys
  theme swatch <key>       # print a color + readability preview
  theme fav list           # list favorites
  theme fav add [key]      # add favorite (defaults to current)
  theme fav remove [key]   # remove favorite (defaults to current)
  theme fav next           # next favorite
  theme fav prev           # previous favorite
  theme fav pick           # pick favorite with fzf
EOF
}

ensure_favorites_file

cmd="${1:-interactive}"
case "$cmd" in
  interactive) interactive_menu ;;
  preview) shift; preview_theme "${1:-}" ;;  # live-preview callback for fzf pickers
  swatch) shift; swatch "${1:-}" ;;          # color/readability preview for fzf --preview
  search) shift; search_theme "${1:-}" ;;
  set) shift; [[ -z "${1:-}" ]] && usage && exit 1; apply_theme "$1" ;;
  current|get) current_theme ;;
  list) list_themes ;;
  reset) reset_theme ;;
  status) show_status ;;
  next)
    mode="${2:-all}"
    case "$mode" in
      all) all_themes_cycle next ;;
      fav|favorite|favorites) favorite_cycle next ;;
      *) usage; exit 1 ;;
    esac
    ;;
  prev)
    mode="${2:-all}"
    case "$mode" in
      all) all_themes_cycle prev ;;
      fav|favorite|favorites) favorite_cycle prev ;;
      *) usage; exit 1 ;;
    esac
    ;;
  fav)
    sub="${2:-list}"
    case "$sub" in
      list) favorites_list ;;
      add) favorite_add "${3:-}" ;;
      remove) favorite_remove "${3:-}" ;;
      next) favorite_cycle next ;;
      prev) favorite_cycle prev ;;
      pick) favorite_pick ;;
      *) usage; exit 1 ;;
    esac
    ;;
  help|-h|--help) usage ;;
  *)
    if [[ -n "$cmd" && "$cmd" != "interactive" ]]; then
      if [[ -f "$THEMES_DIR/$cmd.lua" ]]; then
        apply_theme "$cmd"
        exit 0
      fi
    fi
    usage
    exit 1
    ;;
esac
