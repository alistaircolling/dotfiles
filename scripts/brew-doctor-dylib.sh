#!/bin/bash
# Check Homebrew-installed binaries for broken dylib references.
# Run after `brew upgrade` to catch library mismatches early.

set -euo pipefail

HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
CELLAR="$HOMEBREW_PREFIX/Cellar"
broken=()

for bin in "$HOMEBREW_PREFIX"/opt/*/bin/*; do
  [ -x "$bin" ] || continue
  # Only check Mach-O binaries
  file "$bin" 2>/dev/null | grep -q "Mach-O" || continue

  while IFS= read -r lib; do
    if [ ! -f "$lib" ]; then
      formula=$(echo "$bin" | sed "s|$HOMEBREW_PREFIX/opt/||;s|/.*||")
      broken+=("$formula: missing $lib (used by $bin)")
    fi
  done < <(otool -L "$bin" 2>/dev/null | awk 'NR>1 {print $1}' | grep "$HOMEBREW_PREFIX")
done

if [ ${#broken[@]} -gt 0 ]; then
  echo ""
  echo "⚠  Broken dylib links detected:"
  printf '  %s\n' "${broken[@]}"
  echo ""

  # Deduplicate formula names
  formulas=()
  for entry in "${broken[@]}"; do
    f="${entry%%:*}"
    [[ " ${formulas[*]:-} " == *" $f "* ]] || formulas+=("$f")
  done

  echo "Fix with:"
  echo "  brew reinstall ${formulas[*]}"
else
  echo "✓ No broken dylib links found."
fi
