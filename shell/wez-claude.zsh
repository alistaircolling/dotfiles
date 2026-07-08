# WezTerm pane management for Claude Code sessions
# Adapted from brew@kiseljak's workflow

_wez_focus_pane() {
  local target_pane="$1"
  [[ -z "$target_pane" ]] && return 1

  wezterm cli activate-pane --pane-id "$target_pane" 2>/dev/null
}

_wez_spawn_window() {
  if wezterm cli list &>/dev/null; then
    wezterm cli spawn --new-window --cwd "$1"
    return
  fi

  open -a WezTerm
  local retries=0
  while ! wezterm cli list &>/dev/null && (( retries < 20 )); do
    sleep 0.3
    ((retries++))
  done

  wezterm cli list &>/dev/null || return 1

  local first_pane
  first_pane=$(wezterm cli list --format json 2>/dev/null | jq -r '.[0].pane_id')
  [[ -n "$first_pane" && "$first_pane" != "null" ]] && echo "$first_pane"
}

_wez_layout() {
  local main_pane="$1"
  shift

  # Top-right pane (30% width): neovim.
  local right_pane
  right_pane=$(wezterm cli split-pane --right --percent 30 --pane-id "$main_pane" --cwd "$PWD")
  [[ -z "$right_pane" ]] && { echo "Split failed"; return 1; }

  # Bottom-right pane (lower 50% of the right column): plain shell.
  local bottom_right
  bottom_right=$(wezterm cli split-pane --bottom --percent 50 --pane-id "$right_pane" --cwd "$PWD")

  printf 'nvim\n' | wezterm cli send-text --pane-id "$right_pane" --no-paste
  [[ -n "$bottom_right" ]] && \
    printf 'clear\n' | wezterm cli send-text --pane-id "$bottom_right" --no-paste

  # Left pane: run the claude command, then leave it focused.
  wezterm cli activate-pane --pane-id "$main_pane"

  local cmd=$(printf '%q ' "$@")
  printf '%s\n' "$cmd" | wezterm cli send-text --pane-id "$main_pane" --no-paste

  wezterm cli activate-pane --pane-id "$main_pane"
}

_claude_wez() {
  local session="${${PWD##*/}//[.:]/_}"
  local state_file="/tmp/wez_claude_${session}"

  if [[ -f "$state_file" ]]; then
    local saved_pane
    saved_pane=$(cat "$state_file")

    local pane_json
    pane_json=$(wezterm cli list --format json 2>/dev/null)

    local pane_tty
    pane_tty=$(echo "$pane_json" | jq -r --arg pid "$saved_pane" \
      '[.[] | select(.pane_id == ($pid | tonumber))][0].tty_name // empty')

    if [[ -n "$pane_tty" ]]; then
      if ps -t "$pane_tty" -o comm= 2>/dev/null | command grep -q '^claude$'; then
        _wez_focus_pane "$saved_pane"
        return
      fi

      local cmd=$(printf '%q ' "$@")
      printf '%s\n' "$cmd" | wezterm cli send-text --pane-id "$saved_pane" --no-paste
      _wez_focus_pane "$saved_pane"
      return
    fi

    rm -f "$state_file"
  fi

  local main_pane
  if [[ -n "$WEZTERM_PANE" ]]; then
    main_pane="$WEZTERM_PANE"
  else
    main_pane=$(_wez_spawn_window "$PWD")
    [[ -z "$main_pane" ]] && { echo "Could not create WezTerm window"; return 1; }
  fi

  _wez_layout "$main_pane" "$@" && echo "$main_pane" > "$state_file"
}

claude() {
  # Non-interactive flags/subcommands: bypass the WezTerm layout and run the real
  # binary. Scan all args (not just $1) so flag position doesn't matter.
  local arg
  for arg in "$@"; do
    case "$arg" in
      -p|--print|-c|--continue|-r|--resume|update|doctor|mcp|config|migrate-installer|login|logout|--version|-v|--help|-h)
        command claude "$@"
        return
        ;;
    esac
  done

  clear
  local -a args=(command claude --permission-mode auto)
  [[ $# -gt 0 ]] && args+=("$@")
  _claude_wez "${args[@]}"
}

# Heal a 0-width pane. `wezterm cli spawn`/`split-pane` can start the shell
# before the PTY winsize is applied, so zsh reads a 0x0 window and caches
# COLUMNS=0 with no follow-up SIGWINCH to correct it. That corrupts zsh's
# display (command output renders off-screen and looks "swallowed") and
# crashes width-sensitive TUIs — e.g. gh-dash panics with a nil markdown
# renderer. While COLUMNS is 0, re-query the real tty size via `tput` (a
# fresh TIOCGWINSZ ioctl) and nudge a redraw. Cheap: it early-returns the
# instant the width is valid, so it does nothing on healthy panes.
_wez_heal_winsize() {
  [[ -n "$WEZTERM_PANE" ]] || return
  (( ${COLUMNS:-0} > 0 )) && return

  local cols lines
  cols=$(command tput cols 2>/dev/null)
  lines=$(command tput lines 2>/dev/null)
  if (( cols > 0 )); then
    export COLUMNS=$cols LINES=${lines:-24}
    kill -WINCH $$ 2>/dev/null
  fi
}
precmd_functions+=(_wez_heal_winsize)
