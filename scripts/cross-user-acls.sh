#!/bin/zsh
# Grant bidirectional read/write ACLs between two macOS user accounts on
# their common user-data directories (Desktop, Documents, etc.). Skips
# ~/Library to avoid corrupting per-user app/keychain/browser state.
#
# Idempotent: re-running adds duplicate ACEs but does no harm (allow-allow
# entries are unioned).
#
# IMPORTANT: macOS TCC will still block access to Desktop/Documents/Downloads
# at the system level. Each user must also grant Full Disk Access to their
# terminal app in System Settings → Privacy & Security → Full Disk Access.

set -eu

if (( $# < 2 )); then
  echo "Usage: sudo $0 <user1> <user2> [more users...]" >&2
  exit 1
fi
USERS=("$@")
DIRS=(Desktop Documents Downloads Movies Music Pictures Public Development Applications)

# Full-control ACE with inheritance to new files/dirs
ACL_PERMS="read,write,execute,delete,append,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,chown,file_inherit,directory_inherit"

if [[ $EUID -ne 0 ]]; then
  echo "Must run with sudo." >&2
  exit 1
fi

for owner in "${USERS[@]}"; do
  if ! id "$owner" >/dev/null 2>&1; then
    echo "User $owner does not exist — skipping."
    continue
  fi
  home="/Users/$owner"
  [[ -d "$home" ]] || { echo "$home not found — skipping."; continue; }

  for other in "${USERS[@]}"; do
    [[ "$owner" == "$other" ]] && continue
    if ! id "$other" >/dev/null 2>&1; then continue; fi

    echo "→ Granting $other rwx on $owner's data..."

    # Home dir root (non-recursive): lets $other create top-level files
    chmod +a "user:$other allow $ACL_PERMS" "$home"

    for d in "${DIRS[@]}"; do
      path="$home/$d"
      [[ -d "$path" ]] || continue
      echo "   $path"
      chmod -R +a "user:$other allow $ACL_PERMS" "$path"
    done
  done
done

echo ""
echo "Done. Next steps:"
echo "  1. Grant Full Disk Access to your terminal app for BOTH user accounts"
echo "     (System Settings → Privacy & Security → Full Disk Access)"
echo "  2. Test: touch /Users/<other-user>/Desktop/.acl-test"
