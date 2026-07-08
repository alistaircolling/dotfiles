# Dotfiles

Shared configuration files for shell, Cursor, NeoVim, Claude Code, pi.dev, and terminal tools.

## Setup

Run this on each macOS user account that should share the config:

```bash
/Users/Shared/dotfiles/setup.sh
```

The script creates a timestamped backup before replacing any existing config:

```bash
~/.dotfiles-backup-YYYYMMDD-HHMMSS
```

## Structure

```
dotfiles/
├── shell/
│   ├── .zshrc
│   └── .bash_profile
├── nvim/
│   ├── init.lua
│   └── lua/
├── cursor/
│   ├── settings.json
│   ├── keybindings.json
│   └── mcp.json
├── claude/
│   ├── settings.json
│   ├── commands/
│   └── hooks (journal, log, statusline)
├── pidev/
│   ├── settings.json
│   ├── keybindings.json
│   ├── AGENTS.md
│   ├── prompts/
│   ├── skills/
│   └── extensions/
└── setup.sh
```

## Multi-user

This is designed for `/Users/Shared/` to work across multiple macOS user accounts.

### What is shared

- `~/.zshrc` and `~/.bash_profile` -> shared shell config
- `~/.config/nvim` -> shared NeoVim config
- Cursor user files (`settings.json`, `keybindings.json`, `mcp.json`) -> shared versions
- `~/.claude/settings.json` (+ commands, keybindings) -> shared Claude Code config
- `~/.pi/agent/settings.json` (+ prompts, skills, extensions) -> shared pi.dev config

### What stays per-user

**NeoVim:**

- `~/.local/share/nvim` (plugins/runtime data)
- `~/.local/state/nvim`
- `~/.cache/nvim`

This avoids cross-user plugin lock/permission issues while keeping one shared config source.

**Claude Code:** `~/.claude.json` (auth token) stays per-user.

**Pi.dev:** `~/.pi/agent/auth.json` and `~/.pi/agent/sessions/` stay per-user.

## Verify

After running setup, check links:

```bash
readlink ~/.config/nvim
readlink ~/.zshrc
```

Then open NeoVim once per user so plugins install into that user's data directory.












