#!/bin/bash
# Rebuild the gitignored private overlay and its local exclude block.

set -euo pipefail

DOTFILES="/Users/Shared/dotfiles"
PRIVATE_DIR="$DOTFILES/private"
BEGIN_MARKER="# BEGIN dotfiles private overlay"
END_MARKER="# END dotfiles private overlay"

[ -d "$PRIVATE_DIR" ] || exit 0

EXCLUDE_FILE="$(git -C "$DOTFILES" rev-parse --git-path info/exclude)"
paths_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-overlay-paths.XXXXXX")"
base_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-overlay-base.XXXXXX")"
clean_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-overlay-clean.XXXXXX")"
output_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-overlay-output.XXXXXX")"
trap 'rm -f "$paths_file" "$base_file" "$clean_file" "$output_file"' EXIT

# Remove links created by an earlier overlay pass. This also prunes links whose
# private source was renamed or deleted.
while IFS= read -r -d '' link; do
    target="$(readlink "$link")"
    case "$target" in
        "$PRIVATE_DIR"/*) rm -f "$link" ;;
    esac
done < <(find "$DOTFILES" \
    \( -path "$DOTFILES/.git" -o -path "$PRIVATE_DIR" \) -prune \
    -o -type l -print0)

# Recreate links for every current private file and record their public paths.
while IFS= read -r -d '' private_file; do
    rel="${private_file#"$PRIVATE_DIR/"}"
    mirror="$DOTFILES/$rel"
    mkdir -p "$(dirname "$mirror")"
    ln -s "$private_file" "$mirror"
    printf '%s\n' "$rel" >> "$paths_file"
done < <(find "$PRIVATE_DIR" -type f -print0)

# Remove the previous managed block. During migration from the old append-only
# format, also remove duplicate entries for files in the current overlay.
awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
' "$EXCLUDE_FILE" > "$base_file"

awk 'NR == FNR { overlay[$0] = 1; next } !($0 in overlay)' \
    "$paths_file" "$base_file" > "$clean_file"

{
    while IFS= read -r line || [ -n "$line" ]; do
        printf '%s\n' "$line"
    done < "$clean_file"
    printf '%s\n' "$BEGIN_MARKER"
    LC_ALL=C sort -u "$paths_file"
    printf '%s\n' "$END_MARKER"
} > "$output_file"

chmod 660 "$output_file"
mv "$output_file" "$EXCLUDE_FILE"
echo "Private overlay linked ($(wc -l < "$paths_file" | tr -d ' ') files)"
