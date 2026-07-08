# AGENTS.md

## Purpose

This repository contains shared dotfiles and configuration for shell (zsh), NeoVim, 
Cursor, zshrc, WezTerm, Tmux, Claude Code, and pi.dev — designed to be symlinked from `/Users/Shared/dotfiles` across multiple macOS user accounts.

The goal is to maintain a single, clean, working set of configurations that any user account on the machine can use.

## Working in this repo

When working on any task in this repository, **actively look for issues** in the files you touch — broken symlinks, syntax errors, deprecated options, missing config, inconsistencies between tools, or anything that doesn't look right.

If you encounter an issue:

1. Describe the issue clearly to the user.
2. **Ask for approval** before making any fix — do not silently fix things.
3. Only proceed with the fix once the user confirms.

This applies even if the issue is unrelated to the current task. The philosophy is: leave things better than you found them, but always with the user's knowledge and consent.

## Sudo commands

Since this repo lives in `/Users/Shared/`, some operations may require elevated privileges. **Never run `sudo` commands directly.** Instead, provide the exact command to the user and copy to their clipboard so they can run it themselves.
