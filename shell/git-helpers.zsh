# Shared git helper functions used by worktree.zsh and other shell scripts

_repo_name() {
  basename "$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
}

_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || return 1
}

_default_branch() {
  local ref
  ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null) && {
    echo "${ref#refs/remotes/origin/}"
    return
  }
  # Fallback: check for main or master
  git show-ref --verify --quiet refs/heads/main 2>/dev/null && echo "main" && return
  git show-ref --verify --quiet refs/heads/master 2>/dev/null && echo "master" && return
  echo "main"
}

_slugify() {
  python3 -c "
import re, sys
title = sys.argv[1]
slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
parts = slug.split('-')[:4]
print('-'.join(parts))
" "$1"
}

_time_ago() {
  local ts="$1"
  local now=$(date +%s)
  local diff=$((now - ts))

  if (( diff < 60 )); then
    echo "just now"
  elif (( diff < 3600 )); then
    echo "$(( diff / 60 ))m ago"
  elif (( diff < 86400 )); then
    echo "$(( diff / 3600 ))h ago"
  elif (( diff < 604800 )); then
    echo "$(( diff / 86400 ))d ago"
  elif (( diff < 2592000 )); then
    echo "$(( diff / 604800 ))w ago"
  else
    echo "$(( diff / 2592000 ))mo ago"
  fi
}
