#!/bin/bash
# Speak a short summary of Claude's last reply when voice mode is on.
# - Gated by flag file ~/.claude/voice/enabled (toggle with /voice)
# - Summarises the reply with Haiku via `claude -p`
# - Speaks the summary locally with Kokoro via mlx-audio

# Guard against recursion: the nested `claude -p` call below fires this
# same Stop hook when it finishes.
[ -n "$CLAUDE_VOICE_HOOK" ] && exit 0
export CLAUDE_VOICE_HOOK=1

VOICE_DIR="$HOME/.claude/voice"
[ -f "$VOICE_DIR/enabled" ] || exit 0
[ -x "$VOICE_DIR/venv/bin/python" ] || exit 0

transcript=$(jq -r '.transcript_path // empty')
[ -f "$transcript" ] || exit 0

# Last text block from the last assistant message in the transcript
text=$(jq -rs '[.[] | select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text] | last // empty' "$transcript")
[ -n "$text" ] || exit 0

summary=$(printf '%s' "$text" | claude -p --model claude-haiku-4-5-20251001 \
  "Rewrite the assistant reply above as a 1-2 sentence spoken summary. First person, plain conversational words, no markdown, no code, no file paths. Output only the summary." 2>/dev/null)
[ -n "$summary" ] || summary=$(printf '%s' "$text" | head -c 300)

wav="$VOICE_DIR/last"
rm -f "$wav.wav"
"$VOICE_DIR/venv/bin/python" -m mlx_audio.tts.generate \
  --model prince-canuma/Kokoro-82M --voice af_heart \
  --text "$summary" --file_prefix "$wav" --join_audio >/dev/null 2>&1

# Stop any still-playing previous summary before starting this one
pkill -f "afplay $wav.wav" 2>/dev/null
[ -f "$wav.wav" ] && afplay "$wav.wav"
