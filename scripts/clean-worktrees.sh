#!/bin/bash
# Interactively remove worktrees whose branches have been merged into their
# parent repo's default branch.
#
# Worktrees are enumerated with `git worktree list` (authoritative) for every
# primary clone found under DEV_DIR, so worktrees are detected no matter where
# they live on disk. Merge detection understands squash/rebase merges via the
# GitHub CLI, in addition to fast-forward and patch-id (cherry) merges.
#
# Usage:
#   clean-worktrees          Scan every repo under DEV_DIR.
#   clean-worktrees --repo   Only scan worktrees of the repo you're standing in.
#
# Env:
#   DEV_DIR        Where primary clones live (default: parent of WORKTREES_DIR).
#   WORKTREES_DIR  Legacy; only used to derive DEV_DIR's default.

set -euo pipefail

WORKTREES_DIR="${WORKTREES_DIR:-$HOME/Development/worktrees}"
DEV_DIR="${DEV_DIR:-$(dirname "$WORKTREES_DIR")}"

G='\033[32m' Y='\033[33m' R='\033[31m' B='\033[34m' D='\033[2m' BOLD='\033[1m' N='\033[0m'

# ── Args ────────────────────────────────────────────────────────────────
repo_filter=""  # when set, only clean worktrees whose parent repo matches
for arg in "$@"; do
  case "$arg" in
    --repo)
      git_common=$(git rev-parse --git-common-dir 2>/dev/null) \
        || { echo "--repo: not inside a git repository"; exit 1; }
      [[ "$git_common" != /* ]] && git_common="$PWD/$git_common"
      repo_filter=$(cd "$(dirname "$git_common")" && pwd)
      ;;
    -h|--help)
      echo "Usage: clean-worktrees [--repo]"
      echo "  --repo   Only clean worktrees of the repo in the current directory"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: clean-worktrees [--repo]" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$DEV_DIR" ]]; then
  echo "No development directory at $DEV_DIR"
  exit 0
fi

default_branch_of() {
  local root="$1" ref
  if ref=$(git -C "$root" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null); then
    echo "${ref#refs/remotes/origin/}"
    return
  fi
  git -C "$root" show-ref --verify --quiet refs/heads/main && { echo main; return; }
  git -C "$root" show-ref --verify --quiet refs/heads/master && { echo master; return; }
  echo main
}

# ── Detect GitHub CLI (lets us recognise squash/rebase merges via PR state) ─
GH_OK=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  GH_OK=1
fi

# ── Discover primary clones ───────────────────────────────────────────────
# A primary clone has a real .git *directory*; worktrees have a .git *file*, so
# they are never matched here. We then enumerate each clone's worktrees with
# `git worktree list`, which finds them wherever they live on disk.
declare -a main_repos=()
if [[ -n "$repo_filter" ]]; then
  main_repos=("$repo_filter")
else
  while IFS= read -r gitdir; do
    main_repos+=("$(cd "$(dirname "$gitdir")" && pwd)")
  done < <(find "$DEV_DIR" -maxdepth 3 -type d -name node_modules -prune -o \
                 -type d -name .git -print 2>/dev/null)
  if [[ ${#main_repos[@]} -gt 1 ]]; then
    deduped=()
    while IFS= read -r r; do deduped+=("$r"); done \
      < <(printf '%s\n' "${main_repos[@]}" | sort -u)
    main_repos=("${deduped[@]}")
  fi
fi

# ── Scan worktrees of every primary clone ─────────────────────────────────
paths=()    # worktree dir
branches=() # branch name
repos=()    # parent repo root
types=()    # "merged" | "squash-merged" | "pr-merged"
dirty=()    # 1 if working tree has real changes (file-mode-only noise ignored)

for main_root in "${main_repos[@]}"; do
  [[ -d "$main_root" ]] || continue

  default=$(default_branch_of "$main_root")
  git -C "$main_root" fetch origin --quiet 2>/dev/null || true
  if git -C "$main_root" rev-parse --verify --quiet "origin/$default" >/dev/null; then
    base="origin/$default"
  else
    base="$default"
  fi

  while IFS= read -r wt_dir; do
    [[ -z "$wt_dir" ]] && continue
    [[ "$wt_dir" == "$main_root" ]] && continue   # skip the primary worktree

    branch=$(git -C "$wt_dir" branch --show-current 2>/dev/null || true)
    [[ -z "$branch" ]] && continue                # skip detached HEAD
    [[ "$branch" == "$default" ]] && continue

    merge_type=""
    if [[ -z "$(git -C "$wt_dir" log "$base..$branch" --oneline 2>/dev/null)" ]]; then
      merge_type="merged"                          # branch is an ancestor of base
    elif [[ -z "$(git -C "$wt_dir" cherry "$base" "$branch" 2>/dev/null | grep '^+' || true)" ]]; then
      merge_type="squash-merged"                   # every commit's patch is already in base
    elif [[ -n "$GH_OK" ]] && \
         [[ "$( (cd "$wt_dir" && gh pr list --head "$branch" --state merged \
                  --json number --jq 'length' 2>/dev/null) )" =~ ^[1-9] ]]; then
      merge_type="pr-merged"                        # GitHub reports a merged PR (squash/rebase)
    else
      continue
    fi

    # Ignore file-mode-only diffs — a common source of phantom "dirty" trees.
    is_dirty=0
    [[ -n "$(git -C "$wt_dir" -c core.fileMode=false status --porcelain 2>/dev/null)" ]] && is_dirty=1

    paths+=("$wt_dir")
    branches+=("$branch")
    repos+=("$main_root")
    types+=("$merge_type")
    dirty+=("$is_dirty")
  done < <(git -C "$main_root" worktree list --porcelain | awk '/^worktree /{print substr($0,10)}')
done

if [[ ${#paths[@]} -eq 0 ]]; then
  if [[ -n "$repo_filter" ]]; then
    echo "No merged worktrees to clean up for $(basename "$repo_filter")."
  else
    echo "No merged worktrees to clean up."
  fi
  exit 0
fi

# ── Summary ─────────────────────────────────────────────────────────────
echo "Found ${#paths[@]} merged worktree(s):"
echo ""
for i in "${!paths[@]}"; do
  repo_name=$(basename "${repos[$i]}")
  dirty_mark=""
  [[ "${dirty[$i]}" == "1" ]] && dirty_mark=" ${Y}[dirty]${N}"
  printf "  ${B}%s${N}  %s  ${D}(%s)${N}%b\n" "$repo_name" "${branches[$i]}" "${types[$i]}" "$dirty_mark"
done
echo ""

# ── Interactive prompts ─────────────────────────────────────────────────
yes_to_all=0
removed=0
skipped=0
failed=0

prompt() {
  # $1 = prompt text, $2 = default char (y or n)
  local reply
  read -r -p "$1" reply </dev/tty
  reply="${reply:-$2}"
  echo "$reply"
}

for i in "${!paths[@]}"; do
  wt="${paths[$i]}"
  br="${branches[$i]}"
  repo="${repos[$i]}"
  mt="${types[$i]}"
  is_dirty="${dirty[$i]}"
  repo_name=$(basename "$repo")

  echo ""
  printf "${BOLD}%s${N} ${D}/${N} %s ${D}(%s)${N}\n" "$repo_name" "$br" "$mt"
  printf "  ${D}path:${N} %s\n" "$wt"

  if [[ "$yes_to_all" -eq 0 ]]; then
    ans=$(prompt "  Delete? [y/N/a=yes-to-all/q=quit] " "n")
    case "$ans" in
      a|A) yes_to_all=1 ;;
      q|Q) echo "Quit."; break ;;
      y|Y) ;;
      *) echo "  ${D}skipped${N}"; skipped=$((skipped+1)); continue ;;
    esac
  fi

  if [[ "$is_dirty" == "1" ]]; then
    ans=$(prompt "  ${Y}Worktree has uncommitted changes.${N} Delete anyway? [y/N] " "n")
    case "$ans" in
      y|Y) ;;
      *) echo "  ${D}skipped (dirty)${N}"; skipped=$((skipped+1)); continue ;;
    esac
  fi

  # Remove worktree (force needed for dirty trees)
  if ! git -C "$repo" worktree remove "$wt" 2>/dev/null; then
    if ! git -C "$repo" worktree remove --force "$wt" 2>/dev/null; then
      printf "  ${R}failed to remove worktree${N}\n"
      failed=$((failed+1))
      continue
    fi
  fi

  # Delete branch
  if [[ "$mt" == "merged" ]]; then
    git -C "$repo" branch -d "$br" >/dev/null 2>&1 || git -C "$repo" branch -D "$br" >/dev/null 2>&1 || true
  else
    git -C "$repo" branch -D "$br" >/dev/null 2>&1 || true
  fi

  printf "  ${G}removed${N}\n"
  removed=$((removed+1))
done

echo ""
echo "Done. removed=$removed skipped=$skipped failed=$failed"
