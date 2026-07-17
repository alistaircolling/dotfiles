# Dotfiles

Shared config for shell, NeoVim, WezTerm, tmux, git, Cursor, Claude Code, pi.dev, and AeroSpace.

## Setup

Run this on each macOS user account that should share the config:

```bash
/Users/Shared/dotfiles/setup.sh
```

It links each config into the user's home dir, backing up anything it replaces to `~/.dotfiles-backup-YYYYMMDD-HHMMSS`. Safe to re-run — it's idempotent.

## Structure

```
dotfiles/
├── aerospace/    # stable workspaces and desktop switcher
├── shell/        # .zshrc, .bash_profile
├── nvim/         # NeoVim config (init.lua, lua/)
├── wezterm/      # wezterm.lua
├── tmux/         # .tmux.conf
├── git/          # shared.gitconfig (included, not replaced)
├── gh-dash/      # config.yml (extension pinned to v4.23.2)
├── cursor/       # settings.json, keybindings.json, mcp.json
├── claude/       # settings, commands, skills, workflows, hooks
├── pidev/        # settings, prompts, skills, extensions
├── scripts/      # helper scripts + launchd agents
└── setup.sh
```

## Multi-user

Designed to live in `/Users/Shared/` and work across multiple macOS accounts (all in the `staff` group).

**Shared** (symlinked from home): shell, NeoVim, WezTerm, tmux, gh-dash, Cursor, Claude Code, pi.dev, and AeroSpace configs. Git uses `include.path` so identity/credentials stay per-user.

**Per-user:**

- NeoVim plugin/runtime data (`~/.local/share|state/nvim`, `~/.cache/nvim`) — avoids cross-user lock/permission issues.
- Auth: `~/.claude.json`, `~/.pi/agent/auth.json`, and pi.dev sessions.

## Automation

`setup.sh` also loads per-user launchd agents:

- **Live-reload** — git hooks + an fswatch watcher notify open shells/nvim when shared config changes (`brew install fswatch` to activate).
- **Clipboard sync** — mirrors text/images between accounts via `/Users/Shared/clipboard-sync` (needs `xcode-select --install`).
- **gh-dash update check** — weekly check for a release past the pinned version.

## Verify

```bash
readlink ~/.zshrc
readlink ~/.config/nvim
```

Then open NeoVim once per user so plugins install into that user's data dir.
