#!/bin/bash
# new-desktop — Create a new macOS desktop and open a WezTerm window there
# Requires: Accessibility permissions for your terminal in System Settings

osascript <<'EOF'
tell application "System Events"
    -- Open Mission Control
    key code 126 using {control down}
end tell
delay 0.7

-- Add a new desktop
tell application "System Events" to tell process "Dock"
    click button 1 of group "Spaces Bar" of group 1 of group "Mission Control"
end tell
delay 0.5

-- Switch to the new (last) desktop
tell application "System Events" to tell process "Dock"
    click (last button of list 1 of group "Spaces Bar" of group 1 of group "Mission Control")
end tell
delay 0.7
EOF

# Spawn a new WezTerm window on the new desktop
wezterm cli spawn --new-window > /dev/null 2>&1
