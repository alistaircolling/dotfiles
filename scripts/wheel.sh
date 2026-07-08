#!/bin/bash

# wheel - randomly pick a winner from a list of names
# Usage: wheel Alice Bob Charlie Dave
#        echo -e "Alice\nBob\nCharlie" | wheel

set -euo pipefail

# ── colours ──────────────────────────────────────────────────────────────────
RESET=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
RED=$'\e[31m'
YELLOW=$'\e[33m'
GREEN=$'\e[32m'
CYAN=$'\e[36m'
MAGENTA=$'\e[35m'
WHITE=$'\e[97m'
BG_BLACK=$'\e[40m'

COLORS=($RED $YELLOW $GREEN $CYAN $MAGENTA $WHITE)

# ── helpers ───────────────────────────────────────────────────────────────────
die() { printf '%s\n' "$*" >&2; exit 1; }

hide_cursor()  { printf '\e[?25l'; }
show_cursor()  { printf '\e[?25h'; }
clear_line()   { printf '\r\e[2K'; }

cleanup() { show_cursor; tput cnorm 2>/dev/null || true; printf '\n'; }
trap cleanup EXIT INT TERM

# ── collect names ─────────────────────────────────────────────────────────────
names=()

if [[ $# -gt 0 ]]; then
  names=("$@")
elif ! [ -t 0 ]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && names+=("$line")
  done
fi

[[ ${#names[@]} -eq 0 ]] && die "Usage: wheel <name1> <name2> ... [name3 ...]
       echo -e 'Alice\nBob\nCharlie' | wheel"

[[ ${#names[@]} -eq 1 ]] && {
  printf "\n  🏆  ${BOLD}${GREEN}%s${RESET}  — only one name, already a winner!\n\n" "${names[0]}"
  exit 0
}

# ── pick winner ───────────────────────────────────────────────────────────────
winner_idx=$(( RANDOM % ${#names[@]} ))
winner="${names[$winner_idx]}"

# ── spinning animation ────────────────────────────────────────────────────────
hide_cursor

# compute display width (max name length + padding)
max_len=0
for n in "${names[@]}"; do
  (( ${#n} > max_len )) && max_len=${#n}
done
box_width=$(( max_len + 8 ))  # 4 padding each side

print_box() {
  local label="$1"
  local color="$2"
  local pad=$(( (box_width - ${#label}) / 2 ))
  local pad_r=$(( box_width - ${#label} - pad ))

  local top_border="${color}${BOLD}╔$(printf '═%.0s' $(seq 1 $((box_width + 2))))╗${RESET}"
  local mid_line="${color}${BOLD}║${RESET} $(printf '%*s' $pad '')${BOLD}${WHITE}${label}${RESET}$(printf '%*s' $pad_r '') ${color}${BOLD}║${RESET}"
  local bot_border="${color}${BOLD}╚$(printf '═%.0s' $(seq 1 $((box_width + 2))))╝${RESET}"

  printf '\n  %s\n  %s\n  %s\n' "$top_border" "$mid_line" "$bot_border"
}

# header
printf '\n  %s🎡  W H E E L  O F  N A M E S%s\n' "${BOLD}${CYAN}" "${RESET}"
printf '  %s%s names entered%s\n' "${DIM}" "${#names[@]}" "${RESET}"

# Phase 1: fast spin (many frames)
# Phase 2: slow down (fewer frames, longer delays)
# Phase 3: final result

total_frames=45
frame=0
idx=0

for (( frame=0; frame<total_frames; frame++ )); do
  idx=$(( (idx + 1) % ${#names[@]} ))
  color="${COLORS[$((RANDOM % ${#COLORS[@]}))]}"
  name="${names[$idx]}"

  # move cursor up 4 lines to overwrite the box
  if (( frame > 0 )); then
    printf '\e[4A'
  fi

  print_box "$name" "$color"

  # delay: start fast, slow down as we approach the end
  if   (( frame < 20 )); then sleep 0.04
  elif (( frame < 30 )); then sleep 0.08
  elif (( frame < 38 )); then sleep 0.15
  elif (( frame < 42 )); then sleep 0.25
  else                        sleep 0.40
  fi
done

# ── hard-land on the winner ───────────────────────────────────────────────────
# spin until we naturally reach the winner index
steps=0
while [[ "${names[$idx]}" != "$winner" ]] || (( steps == 0 )); do
  idx=$(( (idx + 1) % ${#names[@]} ))
  (( steps++ ))
  printf '\e[4A'
  print_box "${names[$idx]}" "${COLORS[$((RANDOM % ${#COLORS[@]}))]}"
  sleep 0.50
  (( steps >= ${#names[@]} * 2 )) && break  # safety valve
done

# ── reveal ────────────────────────────────────────────────────────────────────
printf '\e[4A'
print_box "$winner" "${GREEN}"

printf '\n  %s🏆  %s%s%s  is the winner!%s\n\n' \
  "${BOLD}" "${BOLD}${GREEN}" "$winner" "${RESET}${BOLD}" "${RESET}"
