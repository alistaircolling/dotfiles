#!/usr/bin/env bash
# tldraw.sh — draw a diagram spec onto a local, editable tldraw canvas.
#
# Reads a JSON spec (see ../SKILL.md) from stdin or a file, saves it as a named
# document, and shows it in the browser. If a tab for that document is already
# open, it updates live instead of opening another one.
#
# Usage:
#   tldraw.sh [--name NAME] [--no-open] [--print] [SPECFILE]
#   echo '{"shapes":[...]}' | tldraw.sh --name auth-flow
#
# Options:
#   --name NAME   Document name (default: "default"). Letters, digits, . _ -
#   --no-open     Update the document but never launch a browser
#   --print       Print the document's file path as well as the URL
#   --stop        Stop this user's canvas server and exit
#   -h, --help    Show this help
#
# Requires: node, curl. The canvas is built on first use (needs npm, one time).

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$SKILL_DIR/app"
DIST_DIR="$SKILL_DIR/dist"
SERVER="$SKILL_DIR/bin/server.mjs"

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tldraw-canvas"
DOCS_DIR="$DATA_DIR/docs"
LOG="$DATA_DIR/server.log"

# One server per macOS account so both users can draw at the same time.
PORT=$((3900 + $(id -u) % 60))
BASE="http://127.0.0.1:$PORT"

NAME=default
OPEN=1
PRINT=0
SPECFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)    NAME="$2"; shift 2;;
    --no-open) OPEN=0; shift;;
    --print)   PRINT=1; shift;;
    --stop)    pkill -f "node .*server\.mjs $PORT " 2>/dev/null && echo "stopped canvas server on port $PORT" || echo "no canvas server running on port $PORT"; exit 0;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    -*)        echo "tldraw.sh: unknown option: $1" >&2; exit 2;;
    *)         SPECFILE="$1"; shift;;
  esac
done

[[ "$NAME" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "tldraw.sh: bad --name '$NAME' (use letters, digits, . _ -)" >&2; exit 2; }

for tool in node curl; do
  command -v "$tool" >/dev/null || { echo "tldraw.sh: missing required tool: $tool" >&2; exit 2; }
done

# --- read and validate the spec ------------------------------------------------
if [[ -n "$SPECFILE" ]]; then
  [[ -f "$SPECFILE" ]] || { echo "tldraw.sh: file not found: $SPECFILE" >&2; exit 2; }
  SPEC="$(cat "$SPECFILE")"
else
  SPEC="$(cat)"
fi

[[ -n "${SPEC//[[:space:]]/}" ]] || { echo 'tldraw.sh: no spec on stdin. Pipe JSON in, or pass a file.' >&2; exit 2; }

if ! printf '%s' "$SPEC" | node -e '
  let s = ""
  process.stdin.on("data", (d) => (s += d)).on("end", () => {
    let spec
    try { spec = JSON.parse(s) } catch (e) { console.error("invalid JSON: " + e.message); process.exit(1) }
    if (!spec || typeof spec !== "object" || Array.isArray(spec)) { console.error("spec must be a JSON object"); process.exit(1) }
    const shapes = spec.shapes ?? []
    if (!Array.isArray(shapes) || shapes.length === 0) { console.error("spec.shapes must be a non-empty array"); process.exit(1) }
    const ids = new Set()
    for (const sh of shapes) {
      if (!sh || typeof sh.id !== "string" || !sh.id) { console.error("every shape needs a string id"); process.exit(1) }
      if (ids.has(sh.id)) { console.error("duplicate shape id: " + sh.id); process.exit(1) }
      ids.add(sh.id)
    }
    for (const a of spec.arrows ?? []) {
      if (!ids.has(a?.from) || !ids.has(a?.to)) { console.error("arrow refers to unknown shape id: " + a?.from + " -> " + a?.to); process.exit(1) }
    }
  })
'; then
  echo "tldraw.sh: spec rejected (see above)" >&2
  exit 1
fi

# --- build the canvas app on first use ----------------------------------------
if [[ ! -f "$DIST_DIR/index.html" ]]; then
  command -v npm >/dev/null || { echo "tldraw.sh: canvas not built and npm not found. Run: cd $APP_DIR && npm install && npm run build" >&2; exit 1; }
  echo "tldraw.sh: building the canvas app (one time, ~30s)…" >&2
  [[ -d "$APP_DIR/node_modules" ]] || (cd "$APP_DIR" && npm install --silent) >&2
  (cd "$APP_DIR" && npm run build --silent) >&2 \
    || { echo "tldraw.sh: build failed. Try: cd $APP_DIR && npm install && npm run build" >&2; exit 1; }
fi

# --- save the document ---------------------------------------------------------
mkdir -p "$DOCS_DIR"
DOC_FILE="$DOCS_DIR/$NAME.json"
# Write via a temp file so the server never reads a half-written spec.
printf '%s' "$SPEC" > "$DOC_FILE.tmp"
mv "$DOC_FILE.tmp" "$DOC_FILE"

# --- make sure the server is up -------------------------------------------------
server_up() { curl -fsS --max-time 2 "$BASE/api/status?doc=$NAME" 2>/dev/null; }

status="$(server_up || true)"
if [[ -z "$status" ]]; then
  # Detach fully: the harness holds the caller's pipe, so give the server its own.
  nohup node "$SERVER" "$PORT" "$DIST_DIR" "$DOCS_DIR" >>"$LOG" 2>&1 </dev/null &
  disown 2>/dev/null || true
  for _ in $(seq 1 40); do
    status="$(server_up || true)"
    [[ -n "$status" ]] && break
    sleep 0.25
  done
  [[ -n "$status" ]] || { echo "tldraw.sh: server did not start; see $LOG" >&2; exit 1; }
fi

URL="$BASE/?doc=$NAME"

# --- show it -------------------------------------------------------------------
# An open tab picks the change up over SSE, so only open a browser when none is.
if [[ "$OPEN" == 1 ]]; then
  clients="$(printf '%s' "$status" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{console.log(JSON.parse(s).clients??0)}catch{console.log(0)}})')"
  [[ "$clients" == 0 ]] && open "$URL"
fi

[[ "$PRINT" == 1 ]] && echo "$DOC_FILE"
echo "$URL"
