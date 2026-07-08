#!/bin/bash
# Safety-net journal hook — appends git state on Claude Code Stop.
#   - 5-min debounce prevents duplicate entries
#   - Skips if Claude already wrote a narrative entry
#   - Only captures commits, diffs, staged/untracked files
#   - Narrative context comes from Claude's proactive journaling

JOURNAL_DIR="$HOME/Development/dev-journal/entries"
DEBOUNCE_DIR="/tmp/claude-journal-debounce"
DEBOUNCE_SECONDS=300
SESSION_START_DIR="/tmp/claude-journal-session-start"

# Get project info from current directory
PROJECT_DIR="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)

# Skip if not a git repo
[ -z "$BRANCH" ] && exit 0

# Debounce: skip if we logged this project recently
mkdir -p "$DEBOUNCE_DIR"
DEBOUNCE_FILE="$DEBOUNCE_DIR/$PROJECT_NAME"
if [ -f "$DEBOUNCE_FILE" ]; then
  LAST=$(stat -f %m "$DEBOUNCE_FILE" 2>/dev/null || stat -c %Y "$DEBOUNCE_FILE" 2>/dev/null)
  NOW=$(date +%s)
  DIFF=$(( NOW - LAST ))
  [ "$DIFF" -lt "$DEBOUNCE_SECONDS" ] && exit 0
fi
touch "$DEBOUNCE_FILE"

# Skip if Claude already wrote a narrative entry for this project recently.
# Narrative entries use "## HH:MM — project:" format; hook entries don't have the colon.
TODAY=$(date +%Y-%m-%d)
ENTRY_FILE="$JOURNAL_DIR/$TODAY.md"
if [ -f "$ENTRY_FILE" ]; then
  RECENT_NARRATIVE=$(tail -50 "$ENTRY_FILE" | grep -c "^## .* — $PROJECT_NAME:" 2>/dev/null)
  [ "$RECENT_NARRATIVE" -gt 0 ] && exit 0
fi

# Determine session start time (fallback: 30 minutes ago)
mkdir -p "$SESSION_START_DIR"
SESSION_FILE="$SESSION_START_DIR/$PROJECT_NAME"
if [ -f "$SESSION_FILE" ]; then
  SESSION_SINCE=$(cat "$SESSION_FILE")
else
  SESSION_SINCE="30 minutes ago"
fi
# Reset session start for next session
date -u +"%Y-%m-%dT%H:%M:%S" > "$SESSION_FILE"

# Gather git context — commits made during this session
SESSION_COMMITS=$(git -C "$PROJECT_DIR" log --since="$SESSION_SINCE" --oneline --no-merges 2>/dev/null)
DIFF_STAT=$(git -C "$PROJECT_DIR" diff --stat HEAD 2>/dev/null)
STAGED_STAT=$(git -C "$PROJECT_DIR" diff --cached --stat 2>/dev/null)
UNTRACKED=$(git -C "$PROJECT_DIR" ls-files --others --exclude-standard 2>/dev/null | head -5)

# Skip if nothing interesting happened
[ -z "$SESSION_COMMITS" ] && [ -z "$DIFF_STAT" ] && [ -z "$STAGED_STAT" ] && [ -z "$UNTRACKED" ] && exit 0

# Build the entry
TIME=$(date +%H:%M)

mkdir -p "$JOURNAL_DIR"

# Create daily header if new file
if [ ! -f "$ENTRY_FILE" ]; then
  echo "# $TODAY" > "$ENTRY_FILE"
  echo "" >> "$ENTRY_FILE"
fi

{
  echo "## $TIME — $PROJECT_NAME ($BRANCH)"
  echo ""
  if [ -n "$SESSION_COMMITS" ]; then
    echo "**Session commits**:"
    echo '```'
    echo "$SESSION_COMMITS"
    echo '```'
    echo ""
  fi
  if [ -n "$DIFF_STAT" ]; then
    echo "**Uncommitted changes**:"
    echo '```'
    echo "$DIFF_STAT"
    echo '```'
    echo ""
  fi
  if [ -n "$STAGED_STAT" ]; then
    echo "**Staged changes**:"
    echo '```'
    echo "$STAGED_STAT"
    echo '```'
    echo ""
  fi
  if [ -n "$UNTRACKED" ]; then
    echo "**New files**: $UNTRACKED"
    echo ""
  fi
  echo "---"
  echo ""
} >> "$ENTRY_FILE"

# Auto-commit to journal repo
git -C "$HOME/Development/dev-journal" add -A 2>/dev/null
git -C "$HOME/Development/dev-journal" commit -m "auto: $PROJECT_NAME ($BRANCH) @ $TIME" --no-gpg-sign 2>/dev/null

exit 0
