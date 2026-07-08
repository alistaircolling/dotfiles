#!/bin/bash
# End-of-day summary for dev journal
# Reads the day's log entries and uses Claude CLI to generate a separate summary file

JOURNAL_DIR="$HOME/Development/dev-journal/entries"
SUMMARY_DIR="$HOME/Development/dev-journal/summaries"
TODAY=$(date +%Y-%m-%d)
ENTRY_FILE="$JOURNAL_DIR/$TODAY.md"
SUMMARY_FILE="$SUMMARY_DIR/$TODAY.md"

# Nothing to summarize if no entries today
[ ! -f "$ENTRY_FILE" ] && exit 0

# Skip if already summarized
[ -f "$SUMMARY_FILE" ] && exit 0

mkdir -p "$SUMMARY_DIR"

ENTRIES=$(cat "$ENTRY_FILE")

# Use Claude CLI to generate a concise summary
SUMMARY=$(claude -p "You are summarizing a developer's work journal for the day. Be concise and direct. Output ONLY the summary markdown, nothing else.

Given these journal entries for $TODAY, write a brief daily summary with:
- A one-line overview of the day
- Bullet points of key accomplishments (group by project if multiple)
- Any notable items that need follow-up
- Hours/time active (estimate from timestamps in the entries)

Keep it short — 10-15 lines max.

---
$ENTRIES" 2>/dev/null)

# Skip if Claude failed
[ -z "$SUMMARY" ] && exit 0

# Write to separate summary file
{
  echo "# Daily Summary — $TODAY"
  echo ""
  echo "$SUMMARY"
  echo ""
  echo "---"
  echo "*Generated from [entries/$TODAY.md](../entries/$TODAY.md)*"
} > "$SUMMARY_FILE"

# Commit
git -C "$HOME/Development/dev-journal" add -A 2>/dev/null
git -C "$HOME/Development/dev-journal" commit -m "summary: $TODAY" --no-gpg-sign 2>/dev/null

exit 0
