#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
dir=$(basename "$cwd")
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')

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
  done | awk '{ if (NR > 1) printf "  │  "; printf "%s", $0 }')
fi

if [ -n "$branch" ]; then
  printf "$mode"'\033[34m%s\033[0m  \033[33m%s\033[0m' "$dir" "$branch"
else
  printf "$mode"'\033[34m%s\033[0m' "$dir"
fi

if [ -n "$model" ]; then
  printf '  \033[35m%s\033[0m' "$model"
fi

# Subscription usage for the 5-hour and 7-day windows, with time elapsed in each
# - colour by used%: green <50, yellow <80, red above
# - elapsed time shown dim after the percentage
now=$(date +%s)
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
seven=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' | cut -d. -f1)
seven_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' | cut -d. -f1)
usage_color() {
  if [ "$1" -ge 80 ]; then printf '\033[31m'
  elif [ "$1" -ge 50 ]; then printf '\033[33m'
  else printf '\033[32m'
  fi
}
time_used() {
  secs=$(( $2 - ($1 - now) ))
  [ "$secs" -lt 0 ] && secs=0
  [ "$secs" -gt "$2" ] && secs=$2
  d=$(( secs / 86400 )); h=$(( secs % 86400 / 3600 )); m=$(( secs % 3600 / 60 ))
  if [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"
  else printf '%dm' "$m"
  fi
}
if [ -n "$five" ]; then
  printf '  %s5h %s%%\033[0m' "$(usage_color "$five")" "$five"
  [ -n "$five_reset" ] && printf ' \033[2m%s\033[0m' "$(time_used "$five_reset" 18000)"
fi
if [ -n "$seven" ]; then
  printf '  %s7d %s%%\033[0m' "$(usage_color "$seven")" "$seven"
  [ -n "$seven_reset" ] && printf ' \033[2m%s\033[0m' "$(time_used "$seven_reset" 604800)"
fi

# Voice mode: green when the /voice flag file exists, dim otherwise
if [ -f "$HOME/.claude/voice/enabled" ]; then
  printf '  \033[32m♪ voice on\033[0m'
else
  printf '  \033[2m♪ voice off\033[0m'
fi

if [ -n "$recent" ]; then
  printf '\n\033[2m⟩ %s\033[0m' "$recent"
fi
