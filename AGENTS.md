# AGENTS.md

## Purpose

This public repository contains shared configuration for zsh, NeoVim, Cursor, WezTerm, tmux, Claude Code, and pi.dev. It is symlinked from `/Users/Shared/dotfiles` across multiple macOS user accounts.

The goal is to maintain a single, clean, working set of configurations that any user account on the machine can use.

## Working in this repo

When working on any task in this repository, **actively look for issues** in the files you touch — broken symlinks, syntax errors, deprecated options, missing config, inconsistencies between tools, or anything that doesn't look right.

If you encounter an issue:

1. Describe the issue clearly to the user.
2. **Ask for approval** before making any fix — do not silently fix things.
3. Only proceed with the fix once the user confirms.

This applies even if the issue is unrelated to the current task. The philosophy is: leave things better than you found them, but always with the user's knowledge and consent.

## Public repository safety

- Never add credentials, tokens, private URLs, customer data, or work-specific identifiers to tracked files.
- Keep work-specific material under the gitignored `private/` overlay.
- Run the configured Gitleaks check before committing security-sensitive changes.
- Do not force-add ignored files or public symlinks created by the private overlay.

## Sudo commands

Since this repo lives in `/Users/Shared/`, some operations may require elevated privileges. **Never run `sudo` commands directly.** Instead, provide the exact command to the user and copy to their clipboard so they can run it themselves.
