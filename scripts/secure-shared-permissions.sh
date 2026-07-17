#!/bin/bash
# Keep the shared repository writable by both macOS accounts without exposing
# mutable config or secrets to unrelated local users.

set -u

DOTFILES="/Users/Shared/dotfiles"
STAFF_ACL='group:staff allow list,add_file,add_subdirectory,delete_child,read,write,append,delete,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit'
failures=0

if [ ! -d "$DOTFILES/.git" ]; then
    echo "secure-shared-permissions: expected repository at $DOTFILES" >&2
    exit 1
fi

set_mode() {
    local mode="$1"
    local path="$2"
    local current
    current="$(stat -f '%OLp' "$path" 2>/dev/null || true)"
    [ "$current" = "$mode" ] && return
    if ! chmod "$mode" "$path" 2>/dev/null; then
        echo "Could not set mode $mode: $path" >&2
        failures=$((failures + 1))
    fi
}

add_staff_acl() {
    local dir="$1"
    if ls -lde "$dir" 2>/dev/null | grep -qE 'group:staff (inherited )?allow .*file_inherit,directory_inherit'; then
        return
    fi
    if ! chmod +a "$STAFF_ACL" "$dir" 2>/dev/null; then
        failures=$((failures + 1))
    fi
}

secure_tree() {
    local root="$1"
    local dir_mode="$2"
    local file_mode="$3"
    local executable_mode="$4"

    [ -e "$root" ] || return

    while IFS= read -r -d '' dir; do
        set_mode "$dir_mode" "$dir"
        add_staff_acl "$dir"
    done < <(find "$root" -type d -print0)

    while IFS= read -r -d '' file; do
        if [ -x "$file" ]; then
            set_mode "$executable_mode" "$file"
        else
            set_mode "$file_mode" "$file"
        fi
    done < <(find "$root" -type f -print0)
}

# Public tracked/config files: group-writable, readable but never writable by
# other local accounts. Handle large/private trees separately below.
while IFS= read -r -d '' dir; do
    set_mode 2775 "$dir"
    add_staff_acl "$dir"
done < <(find "$DOTFILES" \
    \( -path "$DOTFILES/.git" \
       -o -path "$DOTFILES/private" \
       -o -path "$DOTFILES/scripts/.venv" \) -prune \
    -o -type d -print0)

while IFS= read -r -d '' file; do
    rel="${file#"$DOTFILES/"}"
    index_mode="$(git -C "$DOTFILES" ls-files -s -- "$rel" | awk 'NR == 1 { print $1 }')"
    case "$rel" in
        *.md|*.json|*.lua|.gitignore|*/.zshrc|*/.bash_profile)
            set_mode 664 "$file"
            ;;
        *)
            if [ "$index_mode" = "100755" ] || { [ -z "$index_mode" ] && head -c 2 "$file" 2>/dev/null | grep -q '^#!'; }; then
                set_mode 775 "$file"
            else
                set_mode 664 "$file"
            fi
            ;;
    esac
done < <(find "$DOTFILES" \
    \( -path "$DOTFILES/.git" \
       -o -path "$DOTFILES/private" \
       -o -path "$DOTFILES/scripts/.venv" \
       -o -path "$DOTFILES/shell/.secrets" \
       -o -path "$DOTFILES/scripts/.env" \) -prune \
    -o -type f -print0)

# Git internals and ignored private data are shared only with the staff group.
secure_tree "$DOTFILES/.git" 2770 660 770
secure_tree "$DOTFILES/private" 2770 660 770

for secret in "$DOTFILES/shell/.secrets" "$DOTFILES/scripts/.env"; do
    [ -f "$secret" ] && set_mode 660 "$secret"
done

# Git should create future object files with group access.
git -C "$DOTFILES" config core.sharedRepository group

if [ "$failures" -gt 0 ]; then
    echo "Permissions secured where possible; $failures item(s) belong to the other account." >&2
    echo "Run this script once from each macOS account to finish." >&2
else
    echo "Shared repository permissions are secure."
fi
