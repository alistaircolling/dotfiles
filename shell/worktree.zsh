# Worktree management functions
# Requires: git-helpers.zsh to be sourced first

# Team key and branch prefix come from the private overlay config (or the
# environment); fall back to the current username for the prefix.
LINEAR_TEAM_KEY="${LINEAR_TEAM_KEY:-}"
WORKTREE_BRANCH_PREFIX="${WORKTREE_BRANCH_PREFIX:-$USER}"
WORKTREES_DIR="$HOME/Development/worktrees"

# ── _wt_new_branch_for_ticket: generate a fresh branch name from a Linear ticket ──
# Echoes a branch name like <prefix>/abc-2077-age-gate-geo (or just <prefix>/abc-2077 if Linear lookup fails)
_wt_new_branch_for_ticket() {
  local ticket_num="$1"
  local title=""
  if [[ -n "${LINEAR_API_KEY:-}" ]]; then
    title=$(curl -s -X POST https://api.linear.app/graphql \
      -H "Content-Type: application/json" \
      -H "Authorization: $LINEAR_API_KEY" \
      -d "{\"query\": \"{ issues(filter: { number: { eq: $ticket_num }, team: { key: { eq: \\\"$LINEAR_TEAM_KEY\\\" } } }) { nodes { title identifier } } }\"}" \
      | python3 -c "
import sys, json
data = json.load(sys.stdin)
nodes = data.get('data', {}).get('issues', {}).get('nodes', [])
if nodes: print(nodes[0]['title'])
else: sys.exit(1)
" 2>/dev/null) || true
  fi
  local key_lower="${LINEAR_TEAM_KEY:l}"
  if [[ -n "$title" ]]; then
    local slug=$(_slugify "$title")
    echo "${WORKTREE_BRANCH_PREFIX}/${key_lower}-${ticket_num}-${slug}"
  else
    echo "${WORKTREE_BRANCH_PREFIX}/${key_lower}-${ticket_num}"
  fi
}

# ── wt: create or checkout a worktree ──
# Usage: wt              (list worktrees)
#        wt <number>     (Linear ticket — find existing or create new)
#        wt <key>-<number> (Linear ticket — same as above)
#        wt <name>       (branch name — find existing or create new)
wt() {
  local arg="$1"
  local repo
  repo=$(_repo_name) || { echo "Not a git repo"; return 1; }

  # No args → list worktrees
  [[ -z "$arg" ]] && { git worktree list; return; }

  # Normalise: strip the team-key prefix (any case) to get the ticket number
  local ticket_num=""
  if [[ -n "$LINEAR_TEAM_KEY" && "${arg:l}" =~ ^${LINEAR_TEAM_KEY:l}-([0-9]+)$ ]]; then
    ticket_num="${match[1]}"
  elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    ticket_num="$arg"
  fi

  local base
  base=$(_default_branch)
  local branch_name=""
  local is_existing=false
  local skip_confirm=false

  git fetch origin --quiet

  if [[ -n "$ticket_num" ]]; then
    # ── Ticket mode ──
    local ticket_id="${LINEAR_TEAM_KEY}-${ticket_num}"
    echo "Looking for existing branch with $ticket_id..."

    # Search local and remote branches for this ticket
    local found=""
    found=$(git branch -a --list "*${ticket_num}*" 2>/dev/null \
      | sed 's/^[*+ ]*//' | sed 's|remotes/origin/||' \
      | sort -u | head -1)

    if [[ -n "$found" ]]; then
      echo "Found existing branch: $found"
      branch_name="$found"
      is_existing=true
    else
      # Check for open PRs with this ticket
      echo "Checking for open PRs with $ticket_id..."
      local pr_branch=""
      pr_branch=$(gh pr list --search "$ticket_id" --json headRefName -q '.[0].headRefName' 2>/dev/null)

      if [[ -n "$pr_branch" ]]; then
        echo "Found PR branch: $pr_branch"
        branch_name="$pr_branch"
        is_existing=true
      else
        # No existing branch — look up Linear for title
        echo "No existing branch found. Looking up Linear ticket $ticket_id..."
        [[ -z "${LINEAR_API_KEY:-}" ]] && echo "LINEAR_API_KEY not set — using ticket number only"
        branch_name=$(_wt_new_branch_for_ticket "$ticket_num")
        echo "New branch name: $branch_name"
      fi
    fi
  else
    # ── Branch name mode ──
    echo "Looking for existing branch '$arg'..."

    local found=""
    found=$(git branch -a --list "$arg" --list "origin/$arg" 2>/dev/null \
      | sed 's/^[*+ ]*//' | sed 's|remotes/origin/||' \
      | sort -u | head -1)

    if [[ -n "$found" ]]; then
      echo "Found existing branch: $found"
      branch_name="$found"
      is_existing=true
    else
      branch_name="$arg"
    fi
  fi

  # ── Check if branch already has a worktree ──
  local existing_wt=""
  existing_wt=$(git worktree list | grep -F "$branch_name" | awk '{print $1}' || true)
  if [[ -n "$existing_wt" ]]; then
    if [[ -d "$existing_wt" ]]; then
      echo ""
      echo "Found existing worktree at: \033[1m$existing_wt\033[0m"
      echo "Branch: \033[1m$branch_name\033[0m"
      if [[ -t 0 ]]; then
        read "confirm?[S]witch to it, create [n]ew branch, or [c]ancel? [S/n/c] "
        case "$confirm" in
          n|N|new|NEW)
            local default_new=""
            [[ -n "$ticket_num" ]] && default_new=$(_wt_new_branch_for_ticket "$ticket_num")
            if [[ -n "$default_new" && "$default_new" != "$branch_name" ]]; then
              read "branch_name?New branch name [$default_new]: "
              [[ -z "$branch_name" ]] && branch_name="$default_new"
            else
              read "branch_name?Enter new branch name: "
            fi
            [[ -z "$branch_name" ]] && { echo "Cancelled."; return 1; }
            is_existing=false
            skip_confirm=true
            # Re-check the new branch doesn't itself have a worktree
            local new_existing
            new_existing=$(git worktree list | grep -F "$branch_name" | awk '{print $1}' || true)
            if [[ -n "$new_existing" && -d "$new_existing" ]]; then
              echo "Worktree already exists at: $new_existing — switching."
              builtin cd "$new_existing"
              return 0
            fi
            ;;
          c|C|cancel) echo "Cancelled."; return 0 ;;
          *) builtin cd "$existing_wt"; return 0 ;;
        esac
      else
        builtin cd "$existing_wt"
        return 0
      fi
    else
      echo "Stale worktree entry (directory missing) — pruning..."
      git worktree prune
    fi
  fi

  # ── Confirm branch name ──
  if [[ "$skip_confirm" == true ]]; then
    :  # User just entered the branch name — no need to re-confirm
  elif [[ "$is_existing" == true ]]; then
    echo ""
    echo "Checking out existing branch: \033[1m$branch_name\033[0m"
    read "confirm?[P]roceed, create [n]ew branch, [e]dit name, or [c]ancel? [P/n/e/c] "
    case "$confirm" in
      n|N|new|NEW)
        # Generate a fresh branch name for this ticket (or prompt if no ticket)
        local default_new=""
        [[ -n "$ticket_num" ]] && default_new=$(_wt_new_branch_for_ticket "$ticket_num")
        if [[ -n "$default_new" ]]; then
          read "branch_name?New branch name [$default_new]: "
          [[ -z "$branch_name" ]] && branch_name="$default_new"
        else
          read "branch_name?New branch name: "
        fi
        [[ -z "$branch_name" ]] && { echo "Cancelled."; return 1; }
        is_existing=false
        skip_confirm=true
        ;;
      c|C|cancel) echo "Cancelled."; return 1 ;;
      e|edit|E)
        read "branch_name?Enter branch name: "
        [[ -z "$branch_name" ]] && { echo "Cancelled."; return 1; }
        # Re-check if edited name exists
        local edited_found=""
        edited_found=$(git branch -a --list "$branch_name" --list "origin/$branch_name" 2>/dev/null \
          | sed 's/^[*+ ]*//' | sed 's|remotes/origin/||' \
          | sort -u | head -1)
        if [[ -n "$edited_found" ]]; then
          branch_name="$edited_found"
          is_existing=true
        else
          is_existing=false
        fi
        ;;
    esac
  else
    echo ""
    echo "Creating new branch: \033[1m$branch_name\033[0m"
    read "confirm?Proceed? [Y/n/edit] "
    case "$confirm" in
      n|N) echo "Cancelled."; return 1 ;;
      e|edit|E)
        read "branch_name?Enter branch name: "
        [[ -z "$branch_name" ]] && { echo "Cancelled."; return 1; }
        is_existing=false
        ;;
    esac
  fi

  # ── Check if already on this branch ──
  local current=$(git branch --show-current 2>/dev/null)
  if [[ "$current" == "$branch_name" ]]; then
    echo "Already on branch: $branch_name"
    return 0
  fi

  # ── Guard: branch exists locally but isn't an "existing remote" checkout ──
  if [[ "$is_existing" == false ]]; then
    git show-ref --verify --quiet "refs/heads/$branch_name" && {
      echo "Branch '$branch_name' already exists locally"
      return 1
    }
  fi

  # ── Create worktree ──
  local worktree_path="${WORKTREES_DIR}/${repo}/${branch_name##*/}"
  mkdir -p "${WORKTREES_DIR}/${repo}"

  if [[ "$is_existing" == true ]]; then
    echo "Creating worktree from existing branch..."

    # Ensure local branch tracks remote
    if git rev-parse --verify "origin/$branch_name" >/dev/null 2>&1; then
      if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        git branch --track "$branch_name" "origin/$branch_name" --quiet
      fi
    fi

    git worktree add "$worktree_path" "$branch_name" || return 1

    # Ensure upstream is the feature branch, not main
    if git rev-parse --verify "origin/$branch_name" >/dev/null 2>&1; then
      echo "Setting upstream to origin/$branch_name..."
      (cd "$worktree_path" && git branch --set-upstream-to="origin/$branch_name" "$branch_name")
      echo "Pulling latest changes..."
      (cd "$worktree_path" && git pull --quiet)
    fi
  else
    echo "Creating worktree with new branch..."
    git worktree add -b "$branch_name" "$worktree_path" "$base" || return 1

    echo "Pushing and setting upstream to origin/$branch_name..."
    (cd "$worktree_path" && git push -u origin "$branch_name" --quiet)
  fi

  # Symlink .env if it exists in the main repo
  local main_root
  main_root=$(_repo_root)
  [[ -f "$main_root/.env" ]] && ln -sf "$main_root/.env" "$worktree_path/.env"
  [[ -d "$main_root/.vercel" ]] && ln -sf "$main_root/.vercel" "$worktree_path/.vercel"

  echo ""
  echo "Worktree ready at: $worktree_path"
  echo "Branch: $branch_name"

  # WezTerm: if on default branch with a single pane, cd directly
  if [[ "$current" == "$base" ]]; then
    local pane_count=$(wezterm cli list --format json 2>/dev/null \
      | jq "[.[] | select(.tab_id == ((.[] | select(.pane_id == $WEZTERM_PANE)) .tab_id))] | length" 2>/dev/null)
    [[ "${pane_count:-1}" -eq 1 ]] && {
      builtin cd "$worktree_path"
      return
    }
  fi

  echo "Run:  cd $worktree_path"
}

# ── worktrees / wtl: list all worktrees ──
# Usage: worktrees       (list all)
#        worktrees 3     (cd into worktree #3)
worktrees() {
  local idx="${1:-}"
  [[ ! -d "$WORKTREES_DIR" ]] && { echo "No worktrees"; return; }

  # Scope to current repo if inside a worktree
  local scoped_repo=""
  local cwd="$PWD"
  if [[ "$cwd" == "${WORKTREES_DIR}/"* ]]; then
    local rel="${cwd#${WORKTREES_DIR}/}"
    scoped_repo="${rel%%/*}"
  fi

  local entries=()
  if [[ -n "$scoped_repo" ]]; then
    for wt_dir in "$WORKTREES_DIR/$scoped_repo"/*/; do
      [[ ! -d "$wt_dir" ]] && continue
      local mtime
      mtime=$(stat -f %m "$wt_dir" 2>/dev/null) || continue
      entries+=("${mtime}|${wt_dir%/}")
    done
  else
    for repo_dir in "$WORKTREES_DIR"/*/; do
      [[ ! -d "$repo_dir" ]] && continue
      for wt_dir in "$repo_dir"/*/; do
        [[ ! -d "$wt_dir" ]] && continue
        local mtime
        mtime=$(stat -f %m "$wt_dir" 2>/dev/null) || continue
        entries+=("${mtime}|${wt_dir%/}")
      done
    done
  fi

  [[ ${#entries[@]} -eq 0 ]] && { echo "No worktrees"; return; }

  local sorted=($(printf '%s\n' "${entries[@]}" | sort -t'|' -k1 -rn))

  if [[ -n "$idx" ]]; then
    [[ ! "$idx" =~ ^[0-9]+$ ]] || [[ "$idx" -lt 1 ]] || [[ "$idx" -gt ${#sorted[@]} ]] && {
      echo "No worktree at index $idx"
      return 1
    }
    local target="${sorted[$idx]#*|}"
    builtin cd "$target"
    return
  fi

  local i=0
  for entry in "${sorted[@]}"; do
    local mtime="${entry%%|*}"
    local wt_path="${entry#*|}"
    ((i++))
    local repo_name=$(basename "$(dirname "$wt_path")")
    local wt_name=$(basename "$wt_path")
    local time_ago=$(_time_ago "$mtime")
    local dirty=""
    if [[ -d "$wt_path/.git" || -f "$wt_path/.git" ]]; then
      local changes=$(git -C "$wt_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      [[ "$changes" -gt 0 ]] && dirty=" ${changes}∆"
    fi
    if [[ -n "$scoped_repo" ]]; then
      printf "%2d. %-13s %-40s%s\n" "$i" "$time_ago" "$wt_name" "$dirty"
    else
      printf "%2d. %-13s \e[34m%-14s\e[0m %-40s%s\n" "$i" "$time_ago" "$repo_name" "$wt_name" "$dirty"
    fi
  done
}

# ── wtr: remove a worktree ──
# Usage: wtr <name>
wtr() {
  local name="$1"
  local repo
  repo=$(_repo_name) || { echo "Not a git repo"; return 1; }

  [[ -z "$name" ]] && { echo "Usage: wtr <name>"; return 1; }

  local wt_path="${WORKTREES_DIR}/${repo}/${name}"
  if [[ ! -d "$wt_path" ]]; then
    echo "No worktree at: $wt_path"
    return 1
  fi

  git worktree remove "$wt_path" && git branch -d "$name" 2>/dev/null
  echo "Removed worktree: $name"
}

# ── delete_old_branches: interactive cleanup of merged branches ──
delete_old_branches() {
  local default
  default=$(_default_branch)
  local repo
  repo=$(_repo_name) || return

  git worktree prune 2>/dev/null

  local branches=()
  local merge_types=()

  for branch in $(git branch | tr -d "*+ " | grep -v "^$default$"); do
    local is_merged=false merge_type=""

    if [[ -z "$(git log "$default..$branch" 2>/dev/null)" ]]; then
      is_merged=true
      merge_type="merged"
    elif [[ -z "$(git cherry "$default" "$branch" 2>/dev/null | grep '^+')" ]]; then
      is_merged=true
      merge_type="squash-merged"
    fi

    [[ "$is_merged" != true ]] && continue
    branches+=("$branch")
    merge_types+=("$merge_type")
  done

  if [[ ${#branches[@]} -eq 0 ]]; then
    echo "No merged branches to clean up."
    return
  fi

  echo "Merged branches:"
  echo ""
  local i=0
  for branch in "${branches[@]}"; do
    ((i++))
    local wt_path="${WORKTREES_DIR}/${repo}/${branch##*/}"
    local wt_marker=""
    [[ -d "$wt_path" ]] && wt_marker=" [worktree]"

    local dirty=""
    if [[ -d "$wt_path" ]] && [[ -d "$wt_path/.git" || -f "$wt_path/.git" ]]; then
      local changes=$(git -C "$wt_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      [[ "$changes" -gt 0 ]] && dirty=" ${changes}∆"
    fi

    printf "  %2d. %-50s (%s)%s%s\n" "$i" "$branch" "${merge_types[$i]}" "$wt_marker" "$dirty"
  done

  echo ""
  echo "Enter numbers to delete (space-separated), 'all', or 'q' to quit:"
  read "selection?"

  [[ "$selection" == "q" || -z "$selection" ]] && { echo "Cancelled."; return; }

  local indices=()
  if [[ "$selection" == "all" ]]; then
    for ((j=1; j<=${#branches[@]}; j++)); do indices+=($j); done
  else
    indices=(${=selection})
  fi

  for idx in "${indices[@]}"; do
    if [[ ! "$idx" =~ ^[0-9]+$ ]] || [[ "$idx" -lt 1 ]] || [[ "$idx" -gt ${#branches[@]} ]]; then
      echo "Skipping invalid index: $idx"
      continue
    fi

    local branch="${branches[$idx]}"
    local mt="${merge_types[$idx]}"
    local wt_path="${WORKTREES_DIR}/${repo}/${branch##*/}"

    # Remove worktree if it exists
    if [[ -d "$wt_path" ]]; then
      echo "Removing worktree for $mt branch $branch"
      if ! git worktree remove "$wt_path" 2>/dev/null && ! git worktree remove --force "$wt_path"; then
        echo "Warning: Failed to remove worktree at $wt_path — skipping branch $branch"
        continue
      fi
    fi

    echo "Deleting $mt branch $branch"
    if [[ "$mt" == "merged" ]]; then
      git branch -d "$branch"
    else
      git branch -D "$branch"
    fi
  done

  echo "Done."
}

# ── Aliases ──
alias worktree='wt'
alias wtl='worktrees'

# ── clean <subcommand>: cleanup dispatcher ──
# Usage: clean trees
clean() {
  if [[ "$1" == "trees" ]]; then
    /Users/Shared/dotfiles/scripts/clean-worktrees.sh
  else
    echo "Usage: clean trees" >&2
    return 1
  fi
}
