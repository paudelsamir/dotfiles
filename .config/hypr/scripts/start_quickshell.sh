#!/bin/bash

# Kill any existing quickshell instances (more thorough)
pkill -f quickshell
killall quickshell 2>/dev/null

# Wait for cleanup
sleep 2

# Start quickshell with proper configuration
cd ~/.config/quickshell
quickshell -c ii &

# Log the PID for monitoring
echo "$(date): Quickshell started with PID: $!" >> /tmp/quickshell.log