#!/usr/bin/env bash
# dotfiles-reload — tell already-open sessions that the shared dotfiles changed.
#
# Run automatically by the repo's git hooks (post-merge / post-commit /
# post-rewrite / post-checkout) so a `git pull` or `git commit` in
# /Users/Shared/dotfiles propagates to live sessions. Safe to run by hand too.
#
# It does two things:
#   1. touches a sentinel file that each zsh shell's precmd watches, nudging
#      open shells to run `reload`.
#   2. broadcasts a notification to every running nvim that was launched with a
#      control socket (see the nvim() wrapper in shell/.zshrc).
#
# Per-user by design: it can only reach the sockets owned by the user running
# it, which is exactly what we want — each account's pull notifies that
# account's own editors. Always exits 0 so it never blocks a git operation.

set -u

# launchd agents (and git hooks invoked from them) start with a minimal PATH;
# ensure Homebrew bins — notably nvim — resolve regardless of caller.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

DOTFILES="/Users/Shared/dotfiles"
SENTINEL="$DOTFILES/.reload-sentinel"

# 1) Nudge open shells.
touch "$SENTINEL" 2>/dev/null || true

# 2) Broadcast to running nvim instances launched with a socket.
SOCK_DIR="${HOME}/.cache/nvim/sockets"
# Per-socket timestamp of the last notification we sent, used to debounce.
STATE_DIR="$SOCK_DIR/.notify-state"
# Keep this SHORT. A message wider than the cmdline forces nvim's hit-enter
# prompt, which blocks its main loop until the user presses a key — and a
# blocked nvim does not answer RPC, which is what used to hang this script
# indefinitely (and with it, any git command that triggered a hook).
NVIM_EXPR='luaeval("vim.schedule(function() vim.notify([[⚠ dotfiles changed — restart nvim]], vim.log.levels.WARN) end)")'

# Debounce so editing dotfiles doesn't spam the editor with this notice:
#   GRACE    — a just-opened nvim already loaded the current config, so there is
#              nothing to tell it. Skip any socket younger than this. This is
#              what stops the notice firing on (almost) every nvim launch, since
#              unrelated repo churn is often in flight within fswatch's latency.
#   DEBOUNCE — never re-notify the same nvim more than once per this window.
GRACE=60
DEBOUNCE=60
now="$(date +%s)"

# Hard ceiling, in seconds, on a single RPC call.
#
# `nvim --server --remote-expr` is a *request*: it waits for a reply and has no
# timeout of its own. An nvim blocked in a modal state (hit-enter prompt, a
# :confirm dialog, a running :!cmd) does not service RPC, so the client waits
# FOREVER. That is fatal here, because the git hooks call this script and would
# hang the git command — and therefore the user's shell — along with it.
RPC_TIMEOUT=2

# Deliver the notice to one socket under a watchdog.
#   0 = delivered, 1 = socket is dead (safe to reap), 2 = nvim alive but busy.
#
# Status comes from `wait`, never from polling with `kill -0`: a finished child
# stays a zombie until it is waited on, so `kill -0` still succeeds on it and a
# fast failure (dead socket) would be misread as a timeout — leaving stale
# sockets to pile up forever.
_notify_sock() {
  local sock="$1" pid killer rc
  nvim --server "$sock" --remote-expr "$NVIM_EXPR" >/dev/null 2>&1 &
  pid=$!
  ( sleep "$RPC_TIMEOUT"; kill -9 "$pid" 2>/dev/null ) &
  killer=$!

  wait "$pid" 2>/dev/null
  rc=$?
  kill "$killer" 2>/dev/null || true
  wait "$killer" 2>/dev/null || true

  # 137 = 128 + SIGKILL, i.e. the watchdog fired: that nvim is alive but wedged.
  [ "$rc" -eq 137 ] && return 2
  [ "$rc" -eq 0 ] && return 0
  return 1
}

# Guard on nvim existing: without it, every connect would "fail" and we'd
# wrongly reap live sockets. Only touch sockets when nvim is actually present.
if [ -d "$SOCK_DIR" ] && command -v nvim >/dev/null 2>&1; then
  mkdir -p "$STATE_DIR" 2>/dev/null || true
  for sock in "$SOCK_DIR"/*.sock; do
    [ -S "$sock" ] || continue

    # A socket's mtime is its creation time (connections don't bump it), so it
    # is the age of that nvim session. Leave freshly-opened editors alone.
    sock_mtime="$(stat -f %m "$sock" 2>/dev/null || echo 0)"
    [ $(( now - sock_mtime )) -lt "$GRACE" ] && continue

    # Skip if we already nudged this socket within the debounce window.
    stamp="$STATE_DIR/$(basename "$sock").last"
    last="$(cat "$stamp" 2>/dev/null || echo 0)"
    [ $(( now - last )) -lt "$DEBOUNCE" ] && continue

    _notify_sock "$sock"
    case "$?" in
      0) echo "$now" > "$stamp" 2>/dev/null || true ;;
      # No live server on this socket — clean up the stale file and its state.
      1) rm -f "$sock" "$stamp" 2>/dev/null || true ;;
      # Timed out: that nvim is alive but busy, so the socket is NOT stale.
      # Skip it and try again next time — never reap a live socket here.
      2) : ;;
    esac
  done

  # Prune state files whose sockets are gone.
  for stamp in "$STATE_DIR"/*.last; do
    [ -e "$stamp" ] || continue
    [ -S "$SOCK_DIR/$(basename "$stamp" .last)" ] || rm -f "$stamp" 2>/dev/null || true
  done
fi

exit 0
