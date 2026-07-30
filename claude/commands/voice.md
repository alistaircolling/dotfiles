---
allowed-tools: Bash(touch:*), Bash(rm:*), Bash(test:*), Bash(ls:*)
description: Toggle spoken summaries of Claude's replies (local Kokoro TTS)
---

Toggle voice mode. The flag file is `~/.claude/voice/enabled` — when it exists, a Stop hook speaks a short summary of each reply.

- If "$ARGUMENTS" is "on": `touch ~/.claude/voice/enabled`
- If "$ARGUMENTS" is "off": `rm -f ~/.claude/voice/enabled`
- If "$ARGUMENTS" is empty: toggle — remove the flag if it exists, otherwise create it.

Then confirm in one short line whether voice mode is now ON or OFF.
