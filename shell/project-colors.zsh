# Per-project pastel colors for ~/Development projects
# Each project gets a unique color, assigned alphabetically on shell startup.
# Override any assignment by editing project_overrides in themes/shared.lua.

# Accent + per-project overrides live in themes/shared.lua — the single source
# of truth shared with wezterm.lua. The values below are fallbacks used only if
# shared.lua can't be read; edit shared.lua to change them.
_SHARED_THEME_FILE='/Users/Shared/dotfiles/themes/shared.lua'
ACCENT_COLOR='#94e2d5'    # teal (fallback)
ACCENT_RGBA='rgba(148, 226, 213, 0.5)'  # 50% transparent (fallback)
typeset -gA PROJECT_COLOR_OVERRIDES

# Read accent + project overrides from shared.lua (zsh-native, no Lua needed).
# Also reads the gitignored private overlay file, whose overrides win.
_load_shared_theme() {
  local f line in_overrides
  for f in "$_SHARED_THEME_FILE" '/Users/Shared/dotfiles/private/themes/local.lua'; do
    [[ -r "$f" ]] || continue
    in_overrides=0
    while IFS= read -r line; do
      if (( in_overrides )); then
        [[ "$line" == *"}"* ]] && { in_overrides=0; continue; }
        if [[ "$line" =~ "\\['([^']+)'\\][[:space:]]*=[[:space:]]*'(#[0-9a-fA-F]{6})'" ]]; then
          PROJECT_COLOR_OVERRIDES[${match[1]}]="${match[2]}"
        fi
        continue
      fi
      case "$line" in
        *project_overrides*) in_overrides=1 ;;
        *accent_rgba*) [[ "$line" =~ "'([^']+)'" ]] && ACCENT_RGBA="${match[1]}" ;;
        *accent*)      [[ "$line" =~ "'(#[0-9a-fA-F]{6})'" ]] && ACCENT_COLOR="${match[1]}" ;;
      esac
    done < "$f"
  done
}
_load_shared_theme
# Pre-blended 50% accent against dark bg — used where rgba isn't supported
_blend_accent() {
  local hex="${ACCENT_COLOR#\#}"
  local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
  # Luminance of theme background (0-255)
  local lum=$(( (_THEME_BG_R * 299 + _THEME_BG_G * 587 + _THEME_BG_B * 114) / 1000 ))
  if (( lum > 128 )); then
    # Light background: darken accent (blend toward black) for visibility
    r=$(( r / 2 ))
    g=$(( g / 2 ))
    b=$(( b / 2 ))
  else
    # Dark background: blend accent toward bg (original behavior)
    r=$(( (_THEME_BG_R + r) / 2 ))
    g=$(( (_THEME_BG_G + g) / 2 ))
    b=$(( (_THEME_BG_B + b) / 2 ))
  fi
  printf '#%02x%02x%02x' "$r" "$g" "$b"
}


# Read shell palette from active theme file
_read_theme_palette() {
  local themes_dir="/Users/Shared/dotfiles/themes"
  local current_file="$themes_dir/current"
  local theme_name
  if [[ -r "$current_file" ]]; then
    theme_name="$(<"$current_file")"
    theme_name="${theme_name## }"; theme_name="${theme_name%% }"
  fi
  [[ -z "$theme_name" ]] && theme_name="catppuccin-mocha"
  local theme_file="$themes_dir/${theme_name}.lua"
  if [[ -r "$theme_file" ]]; then
    local in_palette=0
    while IFS= read -r line; do
      if [[ "$line" == *"shell_palette"* ]]; then
        in_palette=1; continue
      fi
      if (( in_palette )); then
        [[ "$line" == *"}"* ]] && break
        if [[ "$line" =~ "'(#[0-9a-fA-F]{6})'" ]]; then
          echo "${match[1]}"
        fi
      fi
    done < "$theme_file"
  fi
}

_theme_palette_colors=("${(@f)$(_read_theme_palette)}")
if (( ${#_theme_palette_colors[@]} >= 10 )); then
  _PASTEL_PALETTE=("${_theme_palette_colors[@]}")
else
  _PASTEL_PALETTE=(
    '#f38ba8' '#a6e3a1' '#f9e2af' '#89b4fa'
    '#cba6f7' '#94e2d5' '#fab387' '#f5c2e7'
    '#74c7ec' '#b4befe' '#f2cdcd' '#eba0ac'
    '#89dceb' '#f5e0dc'
  )
fi

# Build color map once on shell startup (sorted alphabetically → unique colors)
typeset -gA _PROJECT_COLOR_MAP

_build_project_colors() {
  local i=1
  for dir in "$HOME/Development"/*(N/on); do
    local name="${dir:t}"
    _PROJECT_COLOR_MAP[$name]="${_PASTEL_PALETTE[$i]}"
    i=$(( i % ${#_PASTEL_PALETTE[@]} + 1 ))
  done
}
_build_project_colors

_get_project_color() {
  if [[ -n "${PROJECT_COLOR_OVERRIDES[$1]}" ]]; then
    echo "${PROJECT_COLOR_OVERRIDES[$1]}"
    return
  fi
  echo "${_PROJECT_COLOR_MAP[$1]:-${_PASTEL_PALETTE[1]}}"
}

# Convert hex -> zsh prompt color escape
_hex_fg() {
  local hex="$1"
  [[ "$hex" != \#* ]] && hex="#${hex}"
  printf '%%F{%s}' "$hex"
}
_COLOR_RESET='%f'

# Read theme background color for tinting
_THEME_BG_R=30 _THEME_BG_G=30 _THEME_BG_B=46
{
  local themes_dir="/Users/Shared/dotfiles/themes"
  local current_file="$themes_dir/current"
  local theme_name=""
  if [[ -r "$current_file" ]]; then
    theme_name="$(<"$current_file")"
    theme_name="${theme_name## }"; theme_name="${theme_name%% }"
  fi
  [[ -z "$theme_name" ]] && theme_name="catppuccin-mocha"
  local theme_file="$themes_dir/${theme_name}.lua"
  if [[ -r "$theme_file" ]]; then
    local bg_line=""
    bg_line=$(command grep "background = '#" "$theme_file" | head -1)
    if [[ "$bg_line" =~ "'#([0-9a-fA-F]{6})'" ]]; then
      local bg_hex="${match[1]}"
      _THEME_BG_R=$((16#${bg_hex:0:2}))
      _THEME_BG_G=$((16#${bg_hex:2:2}))
      _THEME_BG_B=$((16#${bg_hex:4:2}))
    fi
  fi
}

# 50% accent blended against theme bg (for contexts that don't support rgba)
ACCENT_BLENDED=$(_blend_accent)

# Per-theme caret color (OSC 12). Read the active theme's cursor_bg so the shell
# caret matches WezTerm and contrasts each theme's text. Falls back to the
# blended accent if the theme value is too close to the background to see.
CARET_COLOR="$ACCENT_BLENDED"
{
  local themes_dir="/Users/Shared/dotfiles/themes"
  local current_file="$themes_dir/current"
  local theme_name=""
  if [[ -r "$current_file" ]]; then
    theme_name="$(<"$current_file")"
    theme_name="${theme_name## }"; theme_name="${theme_name%% }"
  fi
  [[ -z "$theme_name" ]] && theme_name="catppuccin-mocha"
  local theme_file="$themes_dir/${theme_name}.lua"
  local cursor_hex=""
  if [[ -r "$theme_file" ]]; then
    local cur_line
    cur_line=$(command grep "cursor_bg = '#" "$theme_file" | head -1)
    [[ "$cur_line" =~ "'#([0-9a-fA-F]{6})'" ]] && cursor_hex="#${match[1]}"
  fi
  if [[ -n "$cursor_hex" ]]; then
    local ch="${cursor_hex#\#}"
    local clum=$(( (16#${ch:0:2} * 299 + 16#${ch:2:2} * 587 + 16#${ch:4:2} * 114) / 1000 ))
    local bglum=$(( (_THEME_BG_R * 299 + _THEME_BG_G * 587 + _THEME_BG_B * 114) / 1000 ))
    local d=$(( clum - bglum )); (( d < 0 )) && d=$(( -d ))
    (( d >= 32 )) && CARET_COLOR="$cursor_hex"
  fi
}

# Darken a hex color for use as a subtle background tint
# Mixes ~15% of the pastel color with the active theme's background
_darken_for_bg() {
  local hex="${1#\#}"
  local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
  r=$(( (_THEME_BG_R * 85 + r * 15) / 100 ))
  g=$(( (_THEME_BG_G * 85 + g * 15) / 100 ))
  b=$(( (_THEME_BG_B * 85 + b * 15) / 100 ))
  printf '#%02x%02x%02x' "$r" "$g" "$b"
}

# State variables used in PROMPT
_current_project=""
_current_project_prompt=""
_current_cwd_prompt=""

# Keep directory font-color mapping consistent with wezterm.lua (hash path + pastel palette)
_path_color() {
  local path="$1"
  local -i hash=0
  local -i i=1
  local -i code=0
  local ch
  for (( i = 1; i <= ${#path}; i++ )); do
    ch="${path[i]}"
    code=$(printf '%d' "'$ch")
    hash=$(( (hash * 31 + code) % 99999997 ))
  done
  local -i idx=$(( (hash % ${#_PASTEL_PALETTE[@]}) + 1 ))
  echo "${_PASTEL_PALETTE[$idx]}"
}

# Called from precmd – updates project color state
_update_project_prompt() {
  local dev_root="$HOME/Development"
  # -- Per-directory prompt color disabled (only the wezterm bottom bar indicates cwd)
  # local cwd_hex=$(_path_color "$PWD")
  local cwd_label="${PWD:t}"
  [[ -z "$cwd_label" ]] && cwd_label='/'
  _current_cwd_prompt="$(_hex_fg "$ACCENT_BLENDED")${cwd_label}${_COLOR_RESET} "

  if [[ "$PWD" == "$dev_root"/* ]]; then
    local rel="${PWD#$dev_root/}"
    local project="${rel%%/*}"
    _current_project="$project"
    local hex=$(_get_project_color "$project")
    _current_project_prompt="$(_hex_fg "$hex")[$project]${_COLOR_RESET} "
    # -- Background tinting disabled (only the wezterm bottom bar indicates cwd)
    # local bg=$(_darken_for_bg "$hex")
    # printf '\033]11;%s\007' "$bg"
    # Set caret to the per-theme cursor color (falls back to blended accent)
    printf '\033]12;%s\007' "$CARET_COLOR"
  else
    _current_project=""
    _current_project_prompt=""
    # -- Background reset disabled (only the wezterm bottom bar indicates cwd)
    # printf '\033]111\007'
    # Set caret to the per-theme cursor color (falls back to blended accent)
    printf '\033]12;%s\007' "$CARET_COLOR"
  fi
  # Notify WezTerm of current directory (also useful for shell integration/state)
  printf '\033]7;file://%s%s\007' "$HOST" "$PWD"
}
