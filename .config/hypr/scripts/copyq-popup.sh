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
        # Toggle CopyQ popup overlay on/off
        copyq toggle
        ;;
esac
