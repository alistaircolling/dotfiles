#!/bin/bash
# Setup script for dotfiles
# Run this on a new machine or user account to link all configs

set -euo pipefail

DOTFILES="/Users/Shared/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "Setting up dotfiles for user: $(whoami)"
echo "Backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

link_item() {
    local source="$1"
    local target="$2"
    local label="$3"

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        echo "Skipping $label (shared target missing): $target"
        return
    fi

    mkdir -p "$(dirname "$source")"

    if [ -L "$source" ]; then
        local current_target
        current_target="$(readlink "$source")"
        if [ "$current_target" = "$target" ]; then
            echo "$label already linked"
            return
        fi
    fi

    if [ -e "$source" ] || [ -L "$source" ]; then
        local backup_name
        backup_name="$(echo "$source" | sed "s|$HOME/||; s|/|__|g")"
        mv "$source" "$BACKUP_DIR/$backup_name"
        echo "Backed up $label -> $BACKUP_DIR/$backup_name"
    fi

    ln -s "$target" "$source"
    echo "Linked $label -> $target"
}

# Shell configs
link_item "$HOME/.zshrc" "$DOTFILES/shell/.zshrc" ".zshrc"
link_item "$HOME/.bash_profile" "$DOTFILES/shell/.bash_profile" ".bash_profile"

# Cursor configs
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
link_item "$CURSOR_USER/settings.json" "$DOTFILES/cursor/settings.json" "Cursor settings.json"
link_item "$CURSOR_USER/keybindings.json" "$DOTFILES/cursor/keybindings.json" "Cursor keybindings.json"
link_item "$CURSOR_USER/mcp.json" "$DOTFILES/cursor/mcp.json" "Cursor mcp.json"

# NeoVim config (shared config; plugin data remains per-user)
link_item "$HOME/.config/nvim" "$DOTFILES/nvim" "nvim config"

# Tmux config
link_item "$HOME/.tmux.conf" "$DOTFILES/tmux/.tmux.conf" ".tmux.conf"

# WezTerm config
link_item "$HOME/.wezterm.lua" "$DOTFILES/wezterm/wezterm.lua" "WezTerm config"

# gh-dash config (GitHub PR/issue dashboard)
link_item "$HOME/.config/gh-dash/config.yml" "$DOTFILES/gh-dash/config.yml" "gh-dash config.yml"

# gh-dash extension: gh extensions install per-user under
# ~/.local/share/gh/extensions, so each account needs its own install even
# though the config above is shared. Idempotent: skip if already present.
# Pinned to v4.23.2 — v4.24.1 panics in GetMarkdownRenderer when the PR
# preview pane renders (nil deref under the bubbletea v2 migration).
GH_DASH_VERSION="v4.23.2"
if command -v gh >/dev/null 2>&1; then
    # Reconcile to the pinned version. We read the installed tag straight from
    # the extension manifest rather than `gh extension list`, whose table is
    # suppressed when stdout isn't a TTY. `--pin` writes "tag: vX.Y.Z" here.
    GH_EXT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gh/extensions/gh-dash"
    installed="$(sed -n 's/^tag: *//p' "$GH_EXT_DIR/manifest.yml" 2>/dev/null)"
    if [ -z "$installed" ]; then
        echo "Installing gh-dash extension ($GH_DASH_VERSION)..."
        gh extension install dlvhdr/gh-dash --pin "$GH_DASH_VERSION" \
            || echo "gh-dash install failed (check 'gh auth status')"
    elif [ "$installed" != "$GH_DASH_VERSION" ]; then
        echo "Reinstalling gh-dash $installed -> $GH_DASH_VERSION..."
        gh extension remove dlvhdr/gh-dash 2>/dev/null || true
        gh extension install dlvhdr/gh-dash --pin "$GH_DASH_VERSION" \
            || echo "gh-dash reinstall failed (check 'gh auth status')"
    else
        echo "gh-dash extension already at $GH_DASH_VERSION"
    fi
else
    echo "Skipping gh-dash extension (gh not found)"
fi

# Claude Code configs (auth stays per-user in ~/.claude.json)
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"
link_item "$CLAUDE_DIR/settings.json" "$DOTFILES/claude/settings.json" "Claude settings.json"
link_item "$CLAUDE_DIR/settings.local.json" "$DOTFILES/claude/settings.local.json" "Claude settings.local.json"
# These will be linked once they exist in the shared dotfiles:
for item in commands agents rules skills workflows CLAUDE.md keybindings.json; do
    if [ -e "$DOTFILES/claude/$item" ]; then
        link_item "$CLAUDE_DIR/$item" "$DOTFILES/claude/$item" "Claude $item"
    fi
done

# Pi.dev configs (auth and sessions stay per-user in ~/.pi/agent/)
PI_DIR="$HOME/.pi/agent"
mkdir -p "$PI_DIR"
link_item "$PI_DIR/settings.json" "$DOTFILES/pidev/settings.json" "Pi settings.json"
link_item "$PI_DIR/keybindings.json" "$DOTFILES/pidev/keybindings.json" "Pi keybindings.json"
link_item "$PI_DIR/AGENTS.md" "$DOTFILES/pidev/AGENTS.md" "Pi AGENTS.md"
for item in prompts skills extensions themes; do
    if [ -e "$DOTFILES/pidev/$item" ]; then
        link_item "$PI_DIR/$item" "$DOTFILES/pidev/$item" "Pi $item"
    fi
done

# Private overlay: work-specific commands/skills/scripts live in the
# gitignored private/ dir, mirroring the repo layout. Symlink each file back
# into its public location so tools pick it up, and hide the symlinks from
# git via .git/info/exclude (local-only, never published).
if [ -d "$DOTFILES/private" ]; then
    EXCLUDE_FILE="$(git -C "$DOTFILES" rev-parse --git-path info/exclude)"
    while IFS= read -r -d '' priv; do
        rel="${priv#"$DOTFILES/private/"}"
        mirror="$DOTFILES/$rel"
        mkdir -p "$(dirname "$mirror")"
        ln -sfn "$priv" "$mirror"
        grep -qxF "$rel" "$EXCLUDE_FILE" 2>/dev/null || echo "$rel" >> "$EXCLUDE_FILE"
    done < <(find "$DOTFILES/private" -type f -print0)
    echo "Private overlay linked ($(find "$DOTFILES/private" -type f | wc -l | tr -d ' ') files)"
fi

# Git: include shared config (safe.directory list, etc.) from this user's
# ~/.gitconfig. Identity and credentials stay per-user.
SHARED_GITCONFIG="$DOTFILES/git/shared.gitconfig"
if git config --global --get-all include.path 2>/dev/null | grep -qxF "$SHARED_GITCONFIG"; then
    echo "Shared git config already included"
else
    git config --global --add include.path "$SHARED_GITCONFIG"
    echo "Linked shared git config (include.path -> $SHARED_GITCONFIG)"
fi

# Live-reload: notify open shells/nvim when shared dotfiles change.
# - git hooks (shared via core.hooksPath) run scripts/dotfiles-reload.sh on
#   commit/pull, which touches a sentinel (shells) and pings nvim sockets.
# - nvim() in .zshrc launches editors with a socket in this dir.
mkdir -p "$HOME/.cache/nvim/sockets"
chmod +x "$DOTFILES"/.githooks/* "$DOTFILES"/scripts/dotfiles-reload.sh "$DOTFILES"/scripts/dotfiles-watch.sh 2>/dev/null || true
git -C "$DOTFILES" config core.hooksPath .githooks
echo "Configured live-reload (core.hooksPath=.githooks)"

# Optional fswatch watcher: also catches UNCOMMITTED local edits (git hooks
# only fire on commit/pull). Needs `brew install fswatch`; degrades gracefully
# until then. Installed as a per-user launchd agent.
WATCH_PLIST_DST="$HOME/Library/LaunchAgents/com.dotfiles.watch.plist"
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
sed "s|__HOME__|$HOME|g" "$DOTFILES/scripts/com.dotfiles.watch.plist" > "$WATCH_PLIST_DST"
launchctl unload "$WATCH_PLIST_DST" 2>/dev/null || true
launchctl load -w "$WATCH_PLIST_DST" 2>/dev/null || true
if command -v fswatch >/dev/null 2>&1; then
    echo "Live-reload watcher loaded (fswatch found)"
else
    echo "Live-reload watcher loaded — run 'brew install fswatch' to activate it"
fi

# Weekly check for a fixed gh-dash release (currently pinned to v4.23.2 to
# avoid the v4.24.1 markdown panic). Notifies when a release > v4.24.1 ships.
chmod +x "$DOTFILES"/scripts/gh-dash-update-check.sh 2>/dev/null || true
GHDASH_PLIST_DST="$HOME/Library/LaunchAgents/com.dotfiles.gh-dash-update.plist"
sed "s|__HOME__|$HOME|g" "$DOTFILES/scripts/com.dotfiles.gh-dash-update.plist" > "$GHDASH_PLIST_DST"
launchctl unload "$GHDASH_PLIST_DST" 2>/dev/null || true
launchctl load -w "$GHDASH_PLIST_DST" 2>/dev/null || true
echo "Loaded weekly gh-dash update check (Mondays 10:00)"

# Cross-user clipboard sync (text + images) between the two macOS accounts.
# macOS pasteboards are per-GUI-session, so there is no shared clipboard to
# configure — instead each user runs a launchd agent that mirrors its clipboard
# through /Users/Shared/clipboard-sync. Needs /usr/bin/swift (Xcode CLT).
CLIP_DIR="/Users/Shared/clipboard-sync"
mkdir -p "$CLIP_DIR"
chgrp staff "$CLIP_DIR" 2>/dev/null || true
chmod 2770 "$CLIP_DIR" 2>/dev/null || true   # setgid so both staff users own new files
CLIP_PLIST_DST="$HOME/Library/LaunchAgents/com.dotfiles.clipboard-sync.plist"
sed "s|__HOME__|$HOME|g" "$DOTFILES/scripts/com.dotfiles.clipboard-sync.plist" > "$CLIP_PLIST_DST"
launchctl unload "$CLIP_PLIST_DST" 2>/dev/null || true
launchctl load -w "$CLIP_PLIST_DST" 2>/dev/null || true
if command -v swift >/dev/null 2>&1; then
    echo "Clipboard sync agent loaded"
else
    echo "Clipboard sync agent loaded — run 'xcode-select --install' to activate it"
fi

# Multi-user write access in shared dotfiles via group permissions.
# Both user accounts share the "staff" group on macOS.
# chgrp may fail on files owned by the other user, so we best-effort it.
chgrp -R staff "$DOTFILES" 2>/dev/null || true
chmod -R g+rwX "$DOTFILES" 2>/dev/null || true

echo ""
echo "Verification:"
for path in \
    "$HOME/.zshrc" \
    "$HOME/.bash_profile" \
    "$HOME/.tmux.conf" \
    "$HOME/.config/nvim" \
    "$HOME/.wezterm.lua" \
    "$HOME/.config/gh-dash/config.yml" \
    "$HOME/Library/Application Support/Cursor/User/settings.json" \
    "$HOME/.claude/settings.json" \
    "$HOME/.pi/agent/settings.json"
do
    if [ -L "$path" ]; then
        echo "  $path -> $(readlink "$path")"
    else
        echo "  $path (not symlink)"
    fi
done

echo ""
echo "Setup complete."
echo "Backups were saved in: $BACKUP_DIR"








