#!/bin/bash
echo "Before lock:"
hyprctl monitors | grep -E "Monitor|@"

# Wait for lock
sleep 2

# Check resolution while locked (from another tty if needed)
echo "After 2 seconds (lock should be active):"
hyprctl monitors | grep -E "Monitor|@"
