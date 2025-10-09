#!/bin/bash

# Simple and reliable Quickshell startup/restart script

# Kill any existing instances
pkill -f quickshell 2>/dev/null
killall quickshell 2>/dev/null

# Wait for cleanup
sleep 1

# Start Quickshell in the background
cd ~/.config/quickshell
nohup quickshell -c ii > /tmp/quickshell.log 2>&1 &

# Get the PID
QUICKSHELL_PID=$!

# Log the startup
echo "$(date): Quickshell started with PID: $QUICKSHELL_PID" >> /tmp/quickshell_restarts.log

# Check if it started successfully
sleep 2
if kill -0 $QUICKSHELL_PID 2>/dev/null; then
    echo "Quickshell started successfully (PID: $QUICKSHELL_PID)"
else
    echo "Error: Quickshell failed to start" >&2
    exit 1
fi