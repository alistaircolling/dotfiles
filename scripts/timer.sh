#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  timer <minutes>
  timer <mm:ss>
  timer <mm.ss>
  timer <value><unit> [<value><unit> ...]
  timer <value> <unit> [<value> <unit> ...]
  timer list
  timer kill all
  timer kill <pid> [<pid> ...]

Examples:
  timer 30
  timer 30:15
  timer 30.15
  timer 30 min
  timer 10s
  timer 1h 5m 10s
  timer list
  timer kill all
EOF
}

timer_rows() {
  local pid command elapsed

  while IFS= read -r line; do
    pid=${line%% *}
    command=${line#* }

    # Only include active timer countdown processes (exclude helper subcommands).
    if [[ "$command" != *"timer.sh"* ]]; then
      continue
    fi
    if ((pid == $$)); then
      continue
    fi
    if [[ "$command" == *" timer list"* || "$command" == *" timer kill "* || "$command" == *"timer.sh list"* || "$command" == *"timer.sh kill "* ]]; then
      continue
    fi

    elapsed=$(ps -p "$pid" -o etime= | xargs)
    printf "%s|%s|%s\n" "$pid" "$elapsed" "$command"
  done < <(ps -ax -o pid= -o command=)
}

list_timers() {
  local rows
  rows=$(timer_rows)

  if [[ -z "$rows" ]]; then
    echo "No running timers found."
    return 0
  fi

  printf "%-8s %-10s %s\n" "PID" "ELAPSED" "COMMAND"
  while IFS='|' read -r pid elapsed command; do
    printf "%-8s %-10s %s\n" "$pid" "$elapsed" "$command"
  done <<< "$rows"
}

kill_timers() {
  local pids=("$@")

  if ((${#pids[@]} == 0)); then
    echo "Provide one or more PIDs, or use: timer kill all"
    return 1
  fi

  local killed=0
  local pid
  for pid in "${pids[@]}"; do
    if [[ ! $pid =~ ^[0-9]+$ ]]; then
      echo "Skipping invalid PID: $pid"
      continue
    fi
    if kill -TERM "$pid" >/dev/null 2>&1; then
      killed=$((killed + 1))
      echo "Sent stop signal to timer PID $pid"
    else
      echo "Could not stop PID $pid"
    fi
  done

  if ((killed == 0)); then
    return 1
  fi
}

kill_all_timers() {
  local rows
  rows=$(timer_rows)

  if [[ -z "$rows" ]]; then
    echo "No running timers found."
    return 0
  fi

  local pids=()
  local pid elapsed command
  while IFS='|' read -r pid elapsed command; do
    pids+=("$pid")
  done <<< "$rows"

  kill_timers "${pids[@]}"
}

format_duration() {
  local total=$1
  local hours=$((total / 3600))
  local minutes=$(((total % 3600) / 60))
  local seconds=$((total % 60))

  printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds"
}

unit_to_seconds() {
  local value=$1
  local unit=$2

  case "$unit" in
    h|hr|hrs|hour|hours) echo $((value * 3600)) ;;
    m|min|mins|minute|minutes) echo $((value * 60)) ;;
    s|sec|secs|second|seconds) echo "$value" ;;
    *) return 1 ;;
  esac
}

parse_duration() {
  local input="$1"
  local lower
  lower=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')

  local total=0
  local whole frac

  if [[ $lower =~ ^[0-9]+$ ]]; then
    echo $((lower * 60))
    return 0
  fi

  if [[ $lower =~ ^([0-9]+):([0-9]{1,2})$ ]]; then
    whole=${BASH_REMATCH[1]}
    frac=${BASH_REMATCH[2]}
    if ((10#$frac >= 60)); then
      return 1
    fi
    echo $((10#$whole * 60 + 10#$frac))
    return 0
  fi

  if [[ $lower =~ ^([0-9]+)\.([0-9]{1,2})$ ]]; then
    whole=${BASH_REMATCH[1]}
    frac=${BASH_REMATCH[2]}
    if ((10#$frac >= 60)); then
      return 1
    fi
    echo $((10#$whole * 60 + 10#$frac))
    return 0
  fi

  local tokens=()
  read -r -a tokens <<< "$lower"

  local i=0
  local token value unit seconds
  while ((i < ${#tokens[@]})); do
    token=${tokens[$i]}

    if [[ $token =~ ^([0-9]+)([a-z]+)$ ]]; then
      value=${BASH_REMATCH[1]}
      unit=${BASH_REMATCH[2]}
      seconds=$(unit_to_seconds "$value" "$unit") || return 1
      total=$((total + seconds))
      i=$((i + 1))
      continue
    fi

    if [[ $token =~ ^[0-9]+$ ]]; then
      if ((i + 1 >= ${#tokens[@]})); then
        return 1
      fi
      unit=${tokens[$((i + 1))]}
      if ! [[ $unit =~ ^[a-z]+$ ]]; then
        return 1
      fi

      seconds=$(unit_to_seconds "$token" "$unit") || return 1
      total=$((total + seconds))
      i=$((i + 2))
      continue
    fi

    return 1
  done

  if ((total <= 0)); then
    return 1
  fi

  echo "$total"
}

notify_done() {
  local duration="$1"

  osascript <<EOF >/dev/null 2>&1 || true
display notification "Timer finished (${duration})" with title "Timer"
beep
EOF

  # Show a foreground popup as a stronger visual cue; auto-dismiss after 15 seconds.
  osascript <<EOF >/dev/null 2>&1 &
tell application "System Events"
  activate
  display alert "Timer Finished" message "Timer finished (${duration})" as informational giving up after 15
end tell
EOF

  afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 || printf '\a'
}

if (($# == 0)); then
  usage
  exit 1
fi

if [[ "$1" == "list" ]]; then
  list_timers
  exit 0
fi

if [[ "$1" == "kill" ]]; then
  shift
  if (($# == 0)); then
    echo "Usage: timer kill all | timer kill <pid> [<pid> ...]"
    exit 1
  fi

  if [[ "$1" == "all" ]]; then
    kill_all_timers
    exit 0
  fi

  kill_timers "$@"
  exit 0
fi

input="$*"
if ! total_seconds=$(parse_duration "$input"); then
  echo "Invalid duration: $input"
  echo
  usage
  exit 1
fi

if ((total_seconds <= 0)); then
  echo "Duration must be greater than zero."
  exit 1
fi

target_display=$(format_duration "$total_seconds")
echo "Timer started for ${target_display}. Press Ctrl+C to stop."

start_epoch=$(date +%s)
end_epoch=$((start_epoch + total_seconds))
remaining=$total_seconds

trap 'printf "\nStopped with %s remaining.\n" "$(format_duration "$remaining")"; exit 0' INT TERM

while ((remaining > 0)); do
  printf "\rTime left: %s" "$(format_duration "$remaining")"
  sleep 1
  now=$(date +%s)
  remaining=$((end_epoch - now))
done

printf "\rTime left: 00:00:00\n"
echo "Timer finished."
notify_done "$target_display"
