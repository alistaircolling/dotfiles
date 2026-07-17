# Dotfiles

Shared macOS configuration for zsh, Neovim, WezTerm, tmux, git, Cursor, Claude Code, and pi.dev.

## Setup

Run this from each macOS account that should share the configuration:

```bash
/Users/Shared/dotfiles/setup.sh
```

The script links configuration into the current home directory and backs up anything it replaces to `~/.dotfiles-backup-YYYYMMDD-HHMMSS`. It is safe to re-run.

## Structure

```text
dotfiles/
├── claude/       # Claude settings, commands, tool-specific skills, workflows
├── cursor/       # Cursor settings, keybindings, and MCP config
├── gh-dash/      # GitHub dashboard config
├── git/          # Shared git config (identity remains per-user)
├── nvim/         # Neovim config
├── pidev/        # pi settings, prompts, tool-specific skills, extensions
├── private/      # Gitignored work/private overlay
├── scripts/      # Helper scripts and per-user launchd agents
├── shell/        # zsh and bash configuration
├── skills/       # Portable Agent Skills shared by Claude and pi
├── themes/       # Shared terminal/editor themes
├── tmux/         # tmux config
├── wezterm/      # WezTerm config
├── AGENTS.md     # Repository instructions for coding agents
├── CLAUDE.md     # Claude import of AGENTS.md
└── setup.sh
```

## Multi-user model

The repository lives at `/Users/Shared/dotfiles`. Both intended accounts belong to the macOS `staff` group.

**Shared through symlinks:** shell, Neovim, WezTerm, tmux, gh-dash, Cursor, Claude Code, pi.dev, and agent configuration.

**Per-user:**

- Authentication: `~/.claude.json` and `~/.pi/agent/auth.json`
- pi sessions and other runtime state
- pi package files under `~/.pi/agent/npm`
- Neovim plugins/state/cache under `~/.local` and `~/.cache`
- Generated launchd files under `~/Library/LaunchAgents`

The shared `pidev/settings.json` pins every pi package to an exact version. Each account keeps its own package files, and pi installs or reconciles them from the shared package list when it starts. This avoids cross-account npm write races while keeping both accounts on the same package set and versions.

`scripts/secure-shared-permissions.sh` gives both accounts write access, removes access for unrelated local users from private data, and installs inheritable `staff` ACLs. `setup.sh` runs it automatically; run setup once from each account after a new checkout.

## Shared skills

Portable Agent Skills live in `skills/`. Claude discovers them through links under `claude/skills/`; pi loads the shared directory from `pidev/settings.json`.

Harness-specific skills remain under `claude/skills/` or `pidev/skills/`. A skill belongs in `skills/` only when it avoids harness-only tools such as Claude workflows, MCP integrations, or plugin commands.

## Private overlay

Work-specific and sensitive files belong under the gitignored `private/` directory, mirroring their public destination. `setup.sh` links each private file into the corresponding tool directory and adds the public link to `.git/info/exclude`.

Never force-add `private/`, `shell/.secrets`, `scripts/.env`, or overlay-generated links. The pre-commit hook uses Gitleaks when installed.

## Automation

`setup.sh` installs per-user automation:

- **Live reload:** git hooks notify open shells and Neovim after shared config changes.
- **Clipboard sync:** mirrors text and images between GUI sessions through `/Users/Shared/clipboard-sync`.
- **gh-dash update check:** checks weekly for a safe release newer than the pinned version.
- **Renovate:** runs weekly against `pidev/settings.json` and opens PRs when pi package pins can be updated.

## Verify

```bash
readlink ~/.zshrc
readlink ~/.config/nvim
readlink ~/.claude/skills
readlink ~/.pi/agent/settings.json
```

Open Neovim once per account so plugins install into that account's runtime directory.
