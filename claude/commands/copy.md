Copy content to the user's system clipboard using `pbcopy` on macOS.

If "$ARGUMENTS" is provided, use it to determine what to copy. For example:
- If the user references a file path, read that file and copy its contents
- If the user describes specific output (e.g. "the command output", "that code block", "the last response"), identify and copy that content
- If the user provides literal text, copy that text directly

If "$ARGUMENTS" is empty, copy the most recent substantial output or code from the conversation.

To copy, pipe the content into `pbcopy` using the Bash tool. For multi-line content, use a heredoc:

```
pbcopy <<'CLIPBOARD'
<content here>
CLIPBOARD
```

After copying, briefly confirm what was copied (e.g. "Copied 42 lines to clipboard.") with a short description of the content. Do not re-print the full content.
