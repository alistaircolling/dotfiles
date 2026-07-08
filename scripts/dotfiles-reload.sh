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
# Message is intentionally literal: $MYVIMRC is expanded by the user inside nvim,
# not by this shell (single-quoted) — it is instruction text shown in the editor.
NVIM_EXPR='luaeval("vim.schedule(function() vim.notify([[⚠ dotfiles changed — :source $MYVIMRC or restart nvim]], vim.log.levels.WARN) end)")'

# Debounce so editing dotfiles doesn't spam the editor with this notice:
#   GRACE    — a just-opened nvim already loaded the current config, so there is
#              nothing to tell it. Skip any socket younger than this. This is
#              what stops the notice firing on (almost) every nvim launch, since
#              unrelated repo churn is often in flight within fswatch's latency.
#   DEBOUNCE — never re-notify the same nvim more than once per this window.
GRACE=60
DEBOUNCE=60
now="$(date +%s)"

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

    if nvim --server "$sock" --remote-expr "$NVIM_EXPR" >/dev/null 2>&1; then
      echo "$now" > "$stamp" 2>/dev/null || true
    else
      # No live server on this socket — clean up the stale file and its state.
      rm -f "$sock" "$stamp" 2>/dev/null || true
    fi
  done

  # Prune state files whose sockets are gone.
  for stamp in "$STATE_DIR"/*.last; do
    [ -e "$stamp" ] || continue
    [ -S "$SOCK_DIR/$(basename "$stamp" .last)" ] || rm -f "$stamp" 2>/dev/null || true
  done
fi

exit 0
