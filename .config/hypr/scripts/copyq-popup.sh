#!/bin/bash

# CopyQ clipboard manager popup script
# Creates a small floating popup overlay for clipboard access
# Works similar to scratchpad but for clipboard

case "$1" in
    "clear")
        # Clear clipboard history
        copyq clear
        notify-send "📋" "History cleared" -t 1500
        ;;
    "clear-all")
        # Clear all clipboard history including unclipped items
        copyq clear
        notify-send "📋" "All history cleared" -t 1500
        ;;
    *)
        # Open CopyQ and start the server first if it is not already running.
        if ! pgrep -x copyq >/dev/null 2>&1; then
            copyq &
            for _ in 1 2 3 4 5; do
                pgrep -x copyq >/dev/null 2>&1 && break
                sleep 0.1
            done
        fi

        copyq show
        ;;
esac
