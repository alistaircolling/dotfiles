#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
dir=$(basename "$cwd")
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# Green INSERT / dim NORMAL indicator when vim mode is on
case "$vim_mode" in
  INSERT) mode='\033[32m-- INSERT --\033[0m  ' ;;
  NORMAL) mode='\033[2m-- NORMAL --\033[0m  ' ;;
  *)      mode='' ;;
esac

# Recent commands from log
LOG="$HOME/.claude-cmd-history"
if [ -f "$LOG" ]; then
  recent=$(tail -5 "$LOG" | sed 's/\[.*\] //' | while read -r cmd; do
    # Truncate long commands
    if [ ${#cmd} -gt 60 ]; then
      printf '%s...\n' "$(echo "$cmd" | cut -c1-60)"
    else
      printf '%s\n' "$cmd"
    fi
  done | paste -sd '  │  ' -)
fi

if [ -n "$branch" ]; then
  printf "$mode"'\033[34m%s\033[0m  \033[33m%s\033[0m' "$dir" "$branch"
else
  printf "$mode"'\033[34m%s\033[0m' "$dir"
fi

if [ -n "$recent" ]; then
  printf '\n\033[2m⟩ %s\033[0m' "$recent"
fi
