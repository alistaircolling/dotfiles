#!/usr/bin/env bash
# gh-dash-update-check — weekly check for a gh-dash release NEWER than the
# known-broken v4.24.1. A newer release carries the markdown-panic fix
# (PR #894, https://github.com/dlvhdr/gh-dash/pull/894), so it's safe to unpin.
# Notifies once per new version via a macOS desktop notification.
#
# Run by the per-user launchd agent com.dotfiles.gh-dash-update (weekly).
# Override the baseline for testing: GHDASH_BASELINE=v4.0.0 ./gh-dash-update-check.sh

set -u
# launchd agents start with a minimal PATH; ensure curl/python3 resolve.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
LOG="$HOME/Library/Logs/gh-dash-update-check.log"
STATE="$HOME/.cache/gh-dash-update-last-notified"
mkdir -p "$(dirname "$LOG")" "$(dirname "$STATE")"
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

BASELINE="${GHDASH_BASELINE:-v4.24.1}"

# Latest non-prerelease tag (public repo — no auth, no gh dependency).
latest=$(curl -fsSL -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/dlvhdr/gh-dash/releases/latest 2>/dev/null \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tag_name",""))' 2>/dev/null)

if [ -z "$latest" ]; then
  log "could not fetch latest release tag (network/api?) — skipping"
  exit 0
fi

# Strictly newer than the baseline?
newest=$(printf '%s\n%s\n' "${latest#v}" "${BASELINE#v}" | sort -V | tail -1)
if [ "$latest" = "$BASELINE" ] || [ "$newest" = "${BASELINE#v}" ]; then
  log "latest=$latest not newer than baseline=$BASELINE — no action"
  exit 0
fi

# Only notify once per new version.
if [ "$latest" = "$(cat "$STATE" 2>/dev/null)" ]; then
  log "already notified for $latest — skipping"
  exit 0
fi

log "latest=$latest newer than baseline=$BASELINE — notifying"
osascript -e "display notification \"gh-dash ${latest} is out and likely fixes the v4.24.1 panic. Unpin with: gh extension install dlvhdr/gh-dash --force\" with title \"gh-dash update available\" sound name \"Glass\"" 2>>"$LOG" || true
printf '%s' "$latest" > "$STATE"
exit 0
