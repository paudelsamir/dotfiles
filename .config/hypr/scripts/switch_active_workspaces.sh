#!/bin/bash

# Super+Tab: Cycle through active workspaces (max 5)
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

# Calculate next workspace index (cycle through)
if [ ${#workspace_array[@]} -gt 0 ]; then
    if [ $current_index -eq -1 ]; then
        # Current workspace not in active list, go to first active
        next_workspace=${workspace_array[0]}
    else
        # Go to next workspace in the cycle
        next_index=$(( (current_index + 1) % ${#workspace_array[@]} ))
        next_workspace=${workspace_array[$next_index]}
    fi
    
    # Switch to next workspace
    hyprctl dispatch workspace "$next_workspace"
else
    # No active workspaces found, stay on current
    echo "No active workspaces found"
fi