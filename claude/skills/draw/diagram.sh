#!/usr/bin/env bash
# diagram.sh — render a text diagram (Mermaid, Graphviz, D2, PlantUML, …) to a
# PNG via the free kroki.io service (no API key) and show it inline in WezTerm.
# Deterministic render: labels and text come out exact, not AI-approximated.
#
# Usage:
#   diagram.sh [--type TYPE] [--out FILE] [--height PCT] [--no-show] [SRCFILE]
#   echo "<diagram source>" | diagram.sh [--type mermaid]
#
# Options:
#   --type TYPE   Diagram language (default mermaid; also graphviz, d2,
#                 plantuml, ditaa, erd, …). Match it to the source you pass.
#   --out FILE    Output PNG path (default: a timestamped file in $TMPDIR)
#   --height PCT  Inline display height as % of terminal (default 60)
#   --no-show     Save only; do not render inline
#   -h, --help    Show this help
#
# Requires: curl, jq. Source comes from SRCFILE or stdin.

set -euo pipefail

TYPE=mermaid
OUT=""
HEIGHT=60
SHOW=1
SRCFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)    TYPE="$2"; shift 2;;
    --out)     OUT="$2"; shift 2;;
    --height)  HEIGHT="$2"; shift 2;;
    --no-show) SHOW=0; shift;;
    -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    -*)        echo "diagram.sh: unknown option: $1" >&2; exit 2;;
    *)         SRCFILE="$1"; shift;;
  esac
done

if [[ -n "$SRCFILE" ]]; then
  [[ -f "$SRCFILE" ]] || { echo "diagram.sh: file not found: $SRCFILE" >&2; exit 2; }
  SRC="$(cat "$SRCFILE")"
else
  SRC="$(cat)"   # read diagram source from stdin
fi

if [[ -z "${SRC// /}" ]]; then
  echo 'diagram.sh: no diagram source. Pipe Mermaid (etc.) in, or pass a file.' >&2
  exit 2
fi

for tool in curl jq; do
  command -v "$tool" >/dev/null || { echo "diagram.sh: missing required tool: $tool" >&2; exit 2; }
done

[[ -n "$OUT" ]] || OUT="${TMPDIR:-/tmp}/diagram-$(date +%Y%m%d-%H%M%S-$$).png"

body=$(jq -n --arg s "$SRC" --arg t "$TYPE" \
  '{diagram_source:$s, diagram_type:$t, output_format:"png"}')

http=$(curl -sS -o "$OUT" -w '%{http_code}' \
  -X POST https://kroki.io/ -H 'Content-Type: application/json' -d "$body")

if [[ "$http" != 2* ]]; then
  echo "diagram.sh: kroki render failed (HTTP $http):" >&2
  [[ -s "$OUT" ]] && { head -c 600 "$OUT" >&2; echo >&2; }
  rm -f "$OUT"
  exit 1
fi

# Display the result:
#  - interactive terminal (a human ran it): render inline with imgcat
#  - run as a tool inside WezTerm (no TTY): pop it into a bottom split pane
if [[ "$SHOW" == 1 ]] && command -v wezterm >/dev/null 2>&1; then
  if [[ -t 1 ]]; then
    wezterm imgcat --height "${HEIGHT}%" "$OUT" || true
  elif [[ -n "${WEZTERM_PANE:-}" ]]; then
    "$(dirname "$0")/show.sh" "$OUT" >/dev/null 2>&1 || true
  fi
fi
echo "$OUT"
