#!/bin/bash

# Restart Quickshell properly via systemd
# This ensures only one instance runs

echo "$(date): Restarting Quickshell..." >> /tmp/quickshell.log

# Stop systemd service (this will kill the process)
systemctl --user stop quickshell.service

# Kill any remaining instances
pkill -f quickshell
killall quickshell 2>/dev/null

# Wait for cleanup
sleep 2

# Start systemd service (preferred method)
systemctl --user start quickshell.service

echo "$(date): Quickshell restart completed" >> /tmp/quickshell.log