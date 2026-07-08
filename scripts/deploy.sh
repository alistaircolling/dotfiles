#!/bin/bash
set -euo pipefail

# Colors & symbols
Y='\033[33m' G='\033[32m' R='\033[31m'
D='\033[2m'  B='\033[1m'  X='\033[0m'
SPINNER='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

usage() {
  cat <<'EOF'
Usage: deploy

Monitor the current Vercel deployment for this branch.

Requires:
  VERCEL_TOKEN    API token (export in environment or shell/.secrets)
  .vercel/        Project linked via `vercel link`
EOF
}

case "${1:-}" in -h|--help) usage; exit 0 ;; esac

# --- Prerequisites ---
[[ -z "${VERCEL_TOKEN:-}" ]] && { echo "Error: VERCEL_TOKEN not set"; exit 1; }
command -v jq &>/dev/null || { echo "Error: jq required (brew install jq)"; exit 1; }

branch=$(git branch --show-current 2>/dev/null) || { echo "Error: not a git repo"; exit 1; }
[[ -z "$branch" ]] && { echo "Error: detached HEAD"; exit 1; }

git_root=$(git rev-parse --show-toplevel)
vercel_json="${git_root}/.vercel/project.json"

# Fallback: check main worktree (for git worktree setups)
if [[ ! -f "$vercel_json" ]]; then
  main_root=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  [[ -n "$main_root" ]] && vercel_json="${main_root}/.vercel/project.json"
fi

[[ -f "$vercel_json" ]] || { echo "Error: no .vercel/project.json — run 'vercel link'"; exit 1; }

project_id=$(jq -r '.projectId' "$vercel_json")
team_id=$(jq -r '.orgId // empty' "$vercel_json")

[[ -z "$project_id" || "$project_id" == "null" ]] && { echo "Error: bad projectId in $vercel_json"; exit 1; }

# --- API helpers ---
_api() {
  curl -sf -H "Authorization: Bearer $VERCEL_TOKEN" "https://api.vercel.com$1"
}

_find_deployment() {
  local encoded
  encoded=$(printf '%s' "$branch" | jq -sRr @uri)
  local url="/v6/deployments?projectId=${project_id}&limit=1"
  url+="&meta-githubCommitRef=${encoded}"
  [[ -n "$team_id" && "$team_id" != "null" ]] && url+="&teamId=${team_id}"
  _api "$url" | jq '.deployments[0] // empty'
}

_get_deployment() {
  _api "/v13/deployments/$1" 2>/dev/null
}

_get_logs() {
  _api "/v3/deployments/$1/events" 2>/dev/null \
    | jq -r '
        [ .[]
          | select(.type == "stdout" or .type == "command" or .type == "stderr")
          | (.text // .payload.text // .payload)
          | select(. != null and . != "")
        ] | .[-8:][]' 2>/dev/null \
    || true
}

_elapsed() {
  local now secs
  now=$(date +%s)
  secs=$((now - deploy_epoch))
  ((secs < 0)) && secs=0
  printf "%d:%02d" $((secs / 60)) $((secs % 60))
}

# --- Find deployment ---
printf "  ${D}waiting for deployment on ${X}${B}%s${X}${D}...${X}" "$branch"

deploy_json=""
for _ in $(seq 1 20); do
  deploy_json=$(_find_deployment 2>/dev/null || echo "")
  [[ -n "$deploy_json" && "$deploy_json" != "null" ]] && break
  deploy_json=""
  sleep 3
done

if [[ -z "$deploy_json" ]]; then
  printf "\n  ${R}✗${X} no deployment found for ${B}%s${X}\n" "$branch"
  exit 1
fi

deploy_id=$(echo "$deploy_json" | jq -r '.uid')
deploy_url=$(echo "$deploy_json" | jq -r '.url // empty')
deploy_created=$(echo "$deploy_json" | jq -r '.created // .createdAt // 0')
deploy_epoch=$((deploy_created / 1000))
deploy_state=$(echo "$deploy_json" | jq -r '.state // .readyState // "QUEUED"')

# Use deployment's commit SHA if available
sha=$(echo "$deploy_json" | jq -r '.meta.githubCommitSha // empty' | head -c 7)
[[ -z "$sha" ]] && sha=$(git rev-parse --short HEAD 2>/dev/null || echo "?")

# --- Display helpers ---
_show_final() {
  local state="$1" elapsed
  elapsed=$(_elapsed)
  printf '\033[u\033[J'
  case "$state" in
    READY)
      printf "  ${G}✓ ready${X}  ${B}%s${X}  ${D}%s${X}  %s\n" "$branch" "$sha" "$elapsed"
      [[ -n "$deploy_url" ]] && printf "  ${D}https://%s${X}\n" "$deploy_url"
      ;;
    ERROR)
      printf "  ${R}✗ error${X}  ${B}%s${X}  ${D}%s${X}  %s\n" "$branch" "$sha" "$elapsed"
      ;;
    CANCELED)
      printf "  ${Y}○ canceled${X}  ${B}%s${X}  ${D}%s${X}  %s\n" "$branch" "$sha" "$elapsed"
      ;;
  esac
  echo
}

# Prepare animation area
printf '\r\033[K\n'
printf '\033[s'

trap 'printf "\033[u\033[J  ${D}stopped${X}\n"; exit 0' INT TERM

# --- Already done? ---
case "$deploy_state" in
  READY|ERROR|CANCELED) _show_final "$deploy_state"; exit 0 ;;
esac

# --- Poll loop ---
spin_idx=0
logs=""

while true; do
  # Fetch state
  dep_data=$(_get_deployment "$deploy_id" || echo "")
  if [[ -n "$dep_data" ]]; then
    deploy_state=$(echo "$dep_data" | jq -r '.readyState // .state // "QUEUED"')
    new_url=$(echo "$dep_data" | jq -r '.url // empty')
    [[ -n "$new_url" ]] && deploy_url="$new_url"
  fi

  # Fetch logs while building
  if [[ "$deploy_state" == "BUILDING" || "$deploy_state" == "INITIALIZING" ]]; then
    new_logs=$(_get_logs "$deploy_id" || true)
    [[ -n "$new_logs" ]] && logs="$new_logs"
  fi

  # Done?
  case "$deploy_state" in
    READY|ERROR|CANCELED) _show_final "$deploy_state"; exit 0 ;;
  esac

  # State label
  case "$deploy_state" in
    QUEUED)       label="queued"       ; color="$Y" ;;
    INITIALIZING) label="initializing" ; color="$Y" ;;
    BUILDING)     label="building"     ; color="$Y" ;;
    *)            label="$deploy_state"; color="$D" ;;
  esac

  # Compute elapsed once per cycle
  elapsed=$(_elapsed)

  # Animate spinner for ~3 seconds, then re-poll
  for ((f=0; f<30; f++)); do
    sc="${SPINNER:$((spin_idx % ${#SPINNER})):1}"
    spin_idx=$((spin_idx + 1))

    if ((f == 0)); then
      # Full repaint with logs
      printf '\033[u\033[J'
      printf "  ${color}%s %s${X}  ${B}%s${X}  ${D}%s${X}  %s\n" \
        "$sc" "$label" "$branch" "$sha" "$elapsed"
      if [[ -n "$logs" ]]; then
        printf "\n"
        while IFS= read -r line; do
          printf "  ${D}%s${X}\n" "$line"
        done <<< "$logs"
      fi
    else
      # Spinner only
      printf '\033[u'
      printf "  ${color}%s${X}" "$sc"
    fi

    sleep 0.1
  done
done
