#!/usr/bin/env bash
# image.sh — generate an illustration or photo from a text prompt via the free
# Pollinations API (Flux model, no API key) and show it inline in WezTerm.
#
# Usage:
#   image.sh [options] "PROMPT"
#   echo "PROMPT" | image.sh [options]
#
# Options:
#   --out FILE    Output image path (default: a timestamped .jpg in $TMPDIR)
#   --size WxH    Image dimensions (default 1024x1024)
#   --seed N      Seed for reproducible output
#   --model M     Pollinations model (default flux)
#   --height PCT  Inline display height as % of terminal (default 60)
#   --no-show     Save only; do not render inline
#   -h, --help    Show this help
#
# Requires: curl, jq. Best for photos / art / concept images — any text or
# labels rendered inside the image will be garbled. For labelled diagrams
# (flows, architecture) use diagram.sh instead.

set -euo pipefail

MODEL=flux
SIZE=1024x1024
SEED=""
HEIGHT=60
SHOW=1
OUT=""
PROMPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)     OUT="$2"; shift 2;;
    --size)    SIZE="$2"; shift 2;;
    --seed)    SEED="$2"; shift 2;;
    --model)   MODEL="$2"; shift 2;;
    --height)  HEIGHT="$2"; shift 2;;
    --no-show) SHOW=0; shift;;
    -h|--help) sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    --)        shift; PROMPT="$*"; break;;
    -*)        echo "image.sh: unknown option: $1" >&2; exit 2;;
    *)         PROMPT="${PROMPT:+$PROMPT }$1"; shift;;
  esac
done

if [[ -z "$PROMPT" && ! -t 0 ]]; then
  PROMPT="$(cat)"
fi

if [[ -z "${PROMPT// /}" ]]; then
  echo 'image.sh: no prompt. Usage: image.sh "a photo of ..."' >&2
  exit 2
fi

for tool in curl jq; do
  command -v "$tool" >/dev/null || { echo "image.sh: missing required tool: $tool" >&2; exit 2; }
done

W="${SIZE%x*}"; H="${SIZE#*x}"
[[ -n "$OUT" ]] || OUT="${TMPDIR:-/tmp}/image-$(date +%Y%m%d-%H%M%S-$$).jpg"

enc=$(jq -rn --arg p "$PROMPT" '$p|@uri')
url="https://image.pollinations.ai/prompt/${enc}?model=${MODEL}&width=${W}&height=${H}&nologo=true"
[[ -n "$SEED" ]] && url="${url}&seed=${SEED}"

http=$(curl -sS -o "$OUT" -w '%{http_code}' "$url")

if [[ "$http" != 2* ]]; then
  echo "image.sh: generation failed (HTTP $http):" >&2
  [[ -s "$OUT" ]] && { head -c 600 "$OUT" >&2; echo >&2; }
  rm -f "$OUT"
  exit 1
fi

# Guard against an error page served with a 200.
if ! file --mime-type -b "$OUT" 2>/dev/null | grep -q '^image/'; then
  echo "image.sh: response was not an image:" >&2
  head -c 600 "$OUT" >&2; echo >&2
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
