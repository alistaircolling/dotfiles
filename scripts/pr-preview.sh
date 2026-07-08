#!/usr/bin/env bash
# Open a PR's Vercel preview URL in the browser.
# Usage: pr-preview.sh <owner/repo> <pr-number>
# Called from gh-dash keybinding.
set -euo pipefail

repo="${1:?repo required}"
pr="${2:?pr number required}"

# Repo-specific handling (e.g. projects whose previews live on stable CI
# domains) lives in the gitignored private overlay. The override may exit 0
# if it fully handled the PR.
override="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/private/scripts/pr-preview-override.sh"
if [ -f "$override" ]; then
  # shellcheck source=/dev/null
  source "$override"
fi

# Fallback: read the vercel[bot] PR comment. Avoid the "-git-" branch alias,
# which is the cancelled Vercel-Git deployment; prefer a unique deployment URL.
body=$(gh -R "$repo" pr view "$pr" --json comments \
  --jq '[.comments[] | select(.author.login=="vercel") | .body] | last')

urls=$(printf '%s' "$body" | grep -oiE 'https://[a-z0-9._-]+vercel\.app' || true)

url=$(printf '%s\n' "$urls" | grep -v -- '-git-' | head -1 || true)
[ -z "$url" ] && url=$(printf '%s\n' "$urls" | head -1 || true)

if [ -z "$url" ]; then
  echo "No Vercel preview URL found for $repo #$pr" >&2
  exit 1
fi

open "$url"
