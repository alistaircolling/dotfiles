#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load .env ────────────────────────────────────────────────────────────────
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line##[[:space:]]}"
    line="${line%%[[:space:]]}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    export "${key}=${value}"
  done < "$SCRIPT_DIR/.env"
fi

# ── Help ─────────────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<'EOF'
Usage: neonfindbranch <connection_string>
       echo "<connection_string>" | neonfindbranch

Resolves a Neon Postgres connection string to its Neon branch name.

Required env vars (set in scripts/.env):
  NEON_API_KEY       — Neon API key
  NEON_PROJECT_ID    — Neon project ID (e.g. misty-example-12345678)
EOF
  exit 1
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
fi

# ── Read connection string from arg or stdin ─────────────────────────────────
if [[ $# -ge 1 ]]; then
  CONN_STRING="$1"
elif [[ ! -t 0 ]]; then
  read -r CONN_STRING
else
  echo "Error: no connection string provided" >&2
  usage
fi

# ── Validate env vars ───────────────────────────────────────────────────────
if [[ -z "${NEON_API_KEY:-}" ]]; then
  echo "Error: NEON_API_KEY is not set. Add it to $(dirname "$0")/.env" >&2
  exit 1
fi

if [[ -z "${NEON_PROJECT_ID:-}" ]]; then
  echo "Error: NEON_PROJECT_ID is not set. Add it to $(dirname "$0")/.env" >&2
  exit 1
fi

# ── Extract endpoint host from connection string ─────────────────────────────
# Matches the host part: ep-something-something-XXXX.region.aws.neon.tech
ENDPOINT_HOST=$(echo "$CONN_STRING" | sed -n 's|.*@\([^/]*\)/.*|\1|p')
if [[ -z "$ENDPOINT_HOST" ]]; then
  echo "Error: could not parse host from connection string" >&2
  exit 1
fi

# Extract the endpoint ID prefix (e.g. ep-calm-frost-a4ax91zj)
ENDPOINT_ID=$(echo "$ENDPOINT_HOST" | sed -n 's|^\(ep-[^.]*\)\..*|\1|p')
if [[ -z "$ENDPOINT_ID" ]]; then
  echo "Error: could not extract endpoint ID from host: $ENDPOINT_HOST" >&2
  exit 1
fi

# ── Query Neon for endpoints ─────────────────────────────────────────────────
ENDPOINTS_JSON=$(neonctl endpoints list \
  --project-id "$NEON_PROJECT_ID" \
  --api-key "$NEON_API_KEY" \
  --output json 2>/dev/null) || {
  echo "Error: neonctl endpoints list failed" >&2
  exit 1
}

# Find the branch ID for this endpoint
BRANCH_ID=$(echo "$ENDPOINTS_JSON" | jq -r \
  --arg ep "$ENDPOINT_ID" \
  '.[] | select(.host | startswith($ep + ".")) | .branch_id' \
)

if [[ -z "$BRANCH_ID" || "$BRANCH_ID" == "null" ]]; then
  echo "Error: no branch found for endpoint $ENDPOINT_ID" >&2
  exit 1
fi

# ── Query Neon for branches ──────────────────────────────────────────────────
BRANCHES_JSON=$(neonctl branches list \
  --project-id "$NEON_PROJECT_ID" \
  --api-key "$NEON_API_KEY" \
  --output json 2>/dev/null) || {
  echo "Error: neonctl branches list failed" >&2
  exit 1
}

BRANCH_NAME=$(echo "$BRANCHES_JSON" | jq -r \
  --arg bid "$BRANCH_ID" \
  '.[] | select(.id == $bid) | .name' \
)

if [[ -z "$BRANCH_NAME" || "$BRANCH_NAME" == "null" ]]; then
  echo "Error: branch ID $BRANCH_ID not found in project branches" >&2
  exit 1
fi

echo "$BRANCH_NAME"
