#!/bin/bash

# Super+Shift+Tab: Cycle through active workspaces in reverse (max 5)
# Shows workspace switcher overlay

# Get current workspace
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Get list of active workspaces (with windows), limit to 5, sorted
active_workspaces=$(hyprctl workspaces -j | jq -r '
    [.[] | select(.windows > 0) | .id] 
    | sort_by(. | tonumber) 
    | .[0:5] 
    | .[]'
)

# Convert to array
workspace_array=($active_workspaces)

# Find current workspace index
current_index=-1
for i in "${!workspace_array[@]}"; do
    if [[ "${workspace_array[$i]}" == "$current_workspace" ]]; then
        current_index=$i
        break
    fi
done

# Calculate previous workspace index (cycle through in reverse)
if [ ${#workspace_array[@]} -gt 0 ]; then
    if [ $current_index -eq -1 ]; then
        # Current workspace not in active list, go to last active
        next_workspace=${workspace_array[-1]}
    else
        # Go to previous workspace in the cycle (reverse direction)
        if [ $current_index -eq 0 ]; then
            # If at first workspace, wrap to last
            next_index=$((${#workspace_array[@]} - 1))
        else
            # Go to previous workspace
            next_index=$((current_index - 1))
        fi
        next_workspace=${workspace_array[$next_index]}
    fi
    
    # Switch to previous workspace
    hyprctl dispatch workspace "$next_workspace"
else
    # No active workspaces found, stay on current
    echo "No active workspaces found"
fi
