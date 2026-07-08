#!/usr/bin/env bash
#
# redeploy-preview.sh — trigger a fresh Vercel preview deploy for the current
# branch's PR by pushing an empty commit (Vercel deploys on push).
#
# Usage:
#   redeploy-preview            # empty commit + push on the current branch
#   redeploy-preview -w         # ...then watch the PR checks until they settle
#   redeploy-preview -m "msg"   # use a custom commit message
#
set -euo pipefail

msg="chore: redeploy preview"
watch=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--watch) watch=1; shift ;;
    -m|--message) msg="${2:?-m needs a message}"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "redeploy-preview: unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Must be inside a git repo.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "redeploy-preview: not a git repository" >&2; exit 1; }

branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
  || { echo "redeploy-preview: detached HEAD, refusing" >&2; exit 1; }

# Don't accidentally redeploy production by pushing to the default branch.
default=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#refs/remotes/origin/##')
default=${default:-main}
if [[ "$branch" == "$default" ]]; then
  echo "redeploy-preview: on default branch '$branch' — that deploys PRODUCTION, refusing." >&2
  echo "Switch to a feature branch first." >&2
  exit 1
fi

echo "↻ Redeploying preview for branch: $branch"
git commit --allow-empty -m "$msg" >/dev/null
git push

if [[ "$watch" == "1" ]]; then
  if command -v gh >/dev/null 2>&1; then
    echo "👀 Watching PR checks..."
    gh pr checks --watch || true
  else
    echo "redeploy-preview: gh not installed; skipping --watch" >&2
  fi
fi

echo "✓ Pushed. Preview will rebuild shortly."
