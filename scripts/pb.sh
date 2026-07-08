#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: pb [tag1 tag2 ...]  (URL read from clipboard)" >&2
  exit 1
}

if [[ -z "${PINBOARD_API_TOKEN:-}" ]]; then
  echo "Error: PINBOARD_API_TOKEN is not set" >&2
  exit 1
fi

URL=$(pbpaste)
if [[ -z "$URL" || "$URL" != http* ]]; then
  echo "Error: clipboard does not contain a URL" >&2
  exit 1
fi

TAGS=$(IFS=','; echo "$*")

TITLE=$(curl -sL "$URL" | python3 -c "
import sys, re
html = sys.stdin.read()
m = re.search(r'<title[^>]*>(.*?)</title>', html, re.IGNORECASE | re.DOTALL)
print(m.group(1).strip() if m else '')
")
TITLE=${TITLE:-$URL}

ENCODED_URL=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$URL")
ENCODED_TAGS=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$TAGS")
ENCODED_TITLE=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$TITLE")

RESPONSE=$(curl -s "https://api.pinboard.in/v1/posts/add?auth_token=${PINBOARD_API_TOKEN}&format=json&url=${ENCODED_URL}&description=${ENCODED_TITLE}&tags=${ENCODED_TAGS}")

CODE=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('result_code','unknown'))")

if [[ "$CODE" == "done" ]]; then
  echo "Saved: $TITLE"
  [[ -n "$TAGS" ]] && echo "Tags:  $TAGS"
else
  echo "Error: $CODE" >&2
  exit 1
fi
