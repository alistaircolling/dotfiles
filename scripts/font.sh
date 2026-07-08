#!/usr/bin/env zsh

set -euo pipefail

DOTFILES_ROOT="/Users/Shared/dotfiles"
DEFAULT_FONT="Gyrotrope"
FONT_OVERRIDE_FILE="$DOTFILES_ROOT/wezterm/font-override"
FAVORITES_FILE="$DOTFILES_ROOT/wezterm/font-favorites"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

list_fonts_raw() {
  fc-list : family \
    | awk -F',' '{print $1}' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | awk 'NF && substr($0,1,1) != "."' \
    | sort -fu
}

_mono_fonts_cache=""
_build_mono_cache() {
  [[ -n "$_mono_fonts_cache" ]] && return
  _mono_fonts_cache="$(fc-list : family spacing | awk -F: '$2 ~ /100/ {split($1,a,","); gsub(/^[[:space:]]+|[[:space:]]+$/,"",a[1]); print a[1]}' | sort -fu)"
}

is_mono() {
  _build_mono_cache
  printf '%s\n' "$_mono_fonts_cache" | awk -v f="$1" '$0==f { found=1 } END { exit(found ? 0 : 1) }'
}

list_fonts() {
  _build_mono_cache
  local mono=() nonprop=()
  while IFS= read -r name; do
    if printf '%s\n' "$_mono_fonts_cache" | awk -v f="$name" '$0==f { found=1 } END { exit(found ? 0 : 1) }'; then
      mono+=("$name [mono]")
    else
      nonprop+=("$name")
    fi
  done < <(list_fonts_raw)
  printf '%s\n' "${mono[@]}" "${nonprop[@]}"
}

current_font() {
  if [[ -s "$FONT_OVERRIDE_FILE" ]]; then
    local value
    value="$(<"$FONT_OVERRIDE_FILE")"
    value="$(trim "$value")"
    if [[ -n "$value" ]]; then
      printf '%s\n' "$value"
      return
    fi
  fi
  printf '%s\n' "$DEFAULT_FONT"
}

apply_font() {
  local font_name="$1"
  printf '%s\n' "$font_name" > "$FONT_OVERRIDE_FILE"
  printf 'Applied font: %s\n' "$font_name"
}

ensure_favorites_file() {
  if [[ ! -f "$FAVORITES_FILE" ]]; then
    printf '%s\n' "$DEFAULT_FONT" > "$FAVORITES_FILE"
    return
  fi
  if [[ ! -s "$FAVORITES_FILE" ]]; then
    printf '%s\n' "$DEFAULT_FONT" > "$FAVORITES_FILE"
    return
  fi
  if ! awk -v d="$DEFAULT_FONT" '$0==d { found=1 } END { exit(found ? 0 : 1) }' "$FAVORITES_FILE"; then
    {
      printf '%s\n' "$DEFAULT_FONT"
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
  local font_name="${1:-$(current_font)}"
  ensure_favorites_file
  if favorites_list | awk -v f="$font_name" '$0==f { found=1 } END { exit(found ? 0 : 1) }'; then
    printf 'Already in favorites: %s\n' "$font_name"
    return
  fi
  printf '%s\n' "$font_name" >> "$FAVORITES_FILE"
  printf 'Added favorite: %s\n' "$font_name"
}

favorite_remove() {
  local font_name="${1:-$(current_font)}"
  if [[ "$font_name" == "$DEFAULT_FONT" ]]; then
    printf 'Default font cannot be removed from favorites: %s\n' "$DEFAULT_FONT"
    return
  fi
  ensure_favorites_file
  awk -v f="$font_name" '$0!=f' "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp"
  mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
  ensure_favorites_file
  printf 'Removed favorite: %s\n' "$font_name"
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
  cur="$(current_font)"
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

  apply_font "${favorites[idx]}"
}

all_fonts_cycle() {
  local direction="$1"
  local -a fonts
  fonts=("${(@f)$(list_fonts_raw)}")
  local count="${#fonts[@]}"
  if (( count == 0 )); then
    printf 'No fonts found\n'
    return 1
  fi

  local cur idx
  cur="$(current_font)"
  idx=0
  local i
  for (( i=1; i<=count; i++ )); do
    if [[ "${fonts[i]}" == "$cur" ]]; then
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

  apply_font "${fonts[idx]}"
}

favorite_pick() {
  ensure_favorites_file
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is required for interactive pick\n'
    return 1
  fi
  local selected
  selected="$(favorites_list | fzf --height=40% --layout=reverse --border --prompt='Favorite font > ' --header='Enter to apply')"
  [[ -z "$selected" ]] && return 0
  apply_font "$selected"
}

search_font() {
  local query="${1:-}"
  if command -v fzf >/dev/null 2>&1; then
    local selected
    selected="$(
      list_fonts | fzf \
        --height=70% \
        --layout=reverse \
        --border \
        --prompt='Font search > ' \
        --query="$query" \
        --header='Type to filter, Enter to apply' \
        --preview 'printf "%s\n\nThe quick brown fox jumps over the lazy dog\n0123456789" {}'
    )"
    [[ -z "$selected" ]] && return 0
    selected="${selected% \[mono\]}"
    apply_font "$selected"
    return
  fi

  local selected
  selected="$(list_fonts | awk -v q="$query" 'BEGIN{IGNORECASE=1} index($0,q){print; exit}')"
  if [[ -n "$selected" ]]; then
    selected="${selected% \[mono\]}"
    apply_font "$selected"
    return
  fi
  printf 'No matching fonts\n'
}

show_status() {
  printf 'Current:  %s\n' "$(current_font)"
  printf 'Default:  %s\n' "$DEFAULT_FONT"
  printf 'Favorites:\n'
  favorites_list | sed 's/^/  - /'
}

reset_font() {
  rm -f "$FONT_OVERRIDE_FILE"
  printf 'Reset to default: %s\n' "$DEFAULT_FONT"
}

interactive_menu() {
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is required for interactive mode\n'
    return 1
  fi

  local choice
  choice="$(
    printf '%s\n' \
      'Search and apply font' \
      'Next font (all)' \
      'Previous font (all)' \
      'Next favorite' \
      'Previous favorite' \
      'Pick favorite' \
      'Add current to favorites' \
      'Remove current from favorites' \
      'Reset to default' \
      'Show status' \
      'Quit' \
      | fzf --height=55% --layout=reverse --border --prompt='Font menu > ' --header="Current: $(current_font)"
  )"

  case "$choice" in
    'Search and apply font') search_font ;;
    'Next font (all)') all_fonts_cycle next ;;
    'Previous font (all)') all_fonts_cycle prev ;;
    'Next favorite') favorite_cycle next ;;
    'Previous favorite') favorite_cycle prev ;;
    'Pick favorite') favorite_pick ;;
    'Add current to favorites') favorite_add ;;
    'Remove current from favorites') favorite_remove ;;
    'Reset to default') reset_font ;;
    'Show status') show_status ;;
    *) ;;
  esac
}

usage() {
  cat <<'EOF'
Usage:
  font                     # interactive menu
  font search [query]      # fuzzy search and apply
  font set <font-name>     # apply explicit font
  font current             # print current font
  font reset               # reset to default (Gyrotrope)
  font status              # print current/default/favorites
  font next [all|fav]      # next font (default: all)
  font prev [all|fav]      # previous font (default: all)
  font fav list            # list favorites
  font fav add [font]      # add favorite (defaults to current)
  font fav remove [font]   # remove favorite (defaults to current)
  font fav next            # next favorite
  font fav prev            # previous favorite
  font fav pick            # pick favorite with fzf
EOF
}

ensure_favorites_file

cmd="${1:-interactive}"
case "$cmd" in
  interactive) interactive_menu ;;
  search) shift; search_font "${1:-}" ;;
  set) shift; [[ -z "${1:-}" ]] && usage && exit 1; apply_font "$1" ;;
  current) current_font ;;
  list) list_fonts ;;
  reset) reset_font ;;
  status) show_status ;;
  next)
    mode="${2:-all}"
    case "$mode" in
      all) all_fonts_cycle next ;;
      fav|favorite|favorites) favorite_cycle next ;;
      *) usage; exit 1 ;;
    esac
    ;;
  prev)
    mode="${2:-all}"
    case "$mode" in
      all) all_fonts_cycle prev ;;
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
  *) usage; exit 1 ;;
esac
