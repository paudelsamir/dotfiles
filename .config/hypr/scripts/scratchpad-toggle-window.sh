#!/bin/bash
# Toggle window between scratchpad and current workspace
# Super+Alt+S: Send to scratchpad OR bring back to current workspace

# Get the active window's workspace
current_workspace=$(hyprctl activewindow -j | jq -r '.workspace.id')

if [ "$current_workspace" == "-99" ]; then
    # Window is in scratchpad (special workspace), move back to last workspace
    hyprctl dispatch movetoworkspace e+0
else
    # Window is in normal workspace, send to scratchpad (only active window)
    hyprctl dispatch movetoworkspace special
fi
