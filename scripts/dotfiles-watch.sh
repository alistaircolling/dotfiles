#!/usr/bin/env bash
# dotfiles-watch — run dotfiles-reload.sh whenever anything in the shared
# dotfiles tree changes, INCLUDING uncommitted local edits (the git hooks only
# catch commits/pulls). Runs as a per-user launchd agent (com.dotfiles.watch).
#
# Requires fswatch:  brew install fswatch
# If fswatch is missing we log and exit 0 so launchd just retries later (per
# the plist's ThrottleInterval) instead of hard-failing in a tight loop.

set -u
# launchd agents start with a minimal PATH that omits Homebrew; add it so
# fswatch (and the nvim that dotfiles-reload calls) resolve.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
DOTFILES="/Users/Shared/dotfiles"
RELOAD="$DOTFILES/scripts/dotfiles-reload.sh"
LOG="$HOME/Library/Logs/dotfiles-watch.log"
mkdir -p "$(dirname "$LOG")"

if ! command -v fswatch >/dev/null 2>&1; then
  echo "$(date '+%F %T') fswatch not installed — run: brew install fswatch" >> "$LOG"
  exit 0
fi

echo "$(date '+%F %T') watching $DOTFILES" >> "$LOG"

# Exclude churn and — critically — the sentinel itself: dotfiles-reload.sh
# touches it inside the watched tree, so without this exclusion we'd loop.
# --latency batches a burst of saves into a single reload.
fswatch -o --latency 2 \
  -e '/\.git/' \
  -e '\.reload-sentinel' \
  -e '/\.DS_Store$' \
  -e '/themes/current$' \
  -e '/\.venv/' \
  -e '/\.playwright-mcp/' \
  "$DOTFILES" | while read -r _; do
    "$RELOAD"
    echo "$(date '+%F %T') change -> reload" >> "$LOG"
  done
