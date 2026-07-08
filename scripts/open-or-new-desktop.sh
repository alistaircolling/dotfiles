#!/bin/bash
# open-or-new-desktop — Focus an app if running, otherwise create a new desktop and open it
# Usage: open-or-new-desktop.sh "App Name"
# Requires: Accessibility permissions for your terminal in System Settings

APP_NAME="$1"

if [[ -z "$APP_NAME" ]]; then
  echo "Usage: open-or-new-desktop.sh \"App Name\""
  exit 1
fi

# Check if the app is already running
if pgrep -xq "$APP_NAME"; then
  # App is running — activate it (macOS will switch to whichever Space it's on)
  osascript -e "tell application \"$APP_NAME\" to activate"
  exit 0
fi

# App is not running — create a new desktop and open it there
osascript <<'EOF'
tell application "System Events"
    key code 126 using {control down}
end tell
delay 0.7

tell application "System Events" to tell process "Dock"
    click button 1 of group "Spaces Bar" of group 1 of group "Mission Control"
end tell
delay 0.5

tell application "System Events" to tell process "Dock"
    click (last button of list 1 of group "Spaces Bar" of group 1 of group "Mission Control")
end tell
delay 0.7
EOF

open -a "$APP_NAME"
