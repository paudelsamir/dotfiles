#!/bin/bash

# Clipse popup clipboard manager
# This script creates a floating popup that closes when clicking outside

case "$1" in
    "clear")
        clipse -clear
        notify-send "📋 Clipboard" "History cleared" -t 1500
        ;;
    "clear-all")
        clipse -clear-all
        notify-send "📋 Clipboard" "All history cleared" -t 1500
        ;;
    *)
        # Create a floating popup window for clipse
        # The window will be positioned in center and auto-close when focus is lost
        
        # Kill any existing clipse popup
        pkill -f "clipse-popup"
        
        # Launch clipse in a floating terminal with custom class for window rules
        if command -v kitty >/dev/null 2>&1; then
            kitty --class="clipse-popup" --title="📋 Clipboard Manager" \
                  -o initial_window_width=900 \
                  -o initial_window_height=600 \
                  -o background_opacity=0.95 \
                  -o window_padding_width=10 \
                  -e bash -c "clipse; pkill -f clipse-popup" &
        elif command -v alacritty >/dev/null 2>&1; then
            alacritty --class="clipse-popup" --title="📋 Clipboard Manager" \
                     --option window.opacity=0.95 \
                     -e bash -c "clipse; pkill -f clipse-popup" &
        elif command -v foot >/dev/null 2>&1; then
            foot --app-id="clipse-popup" --title="📋 Clipboard Manager" \
                 bash -c "clipse; pkill -f clipse-popup" &
        else
            # Fallback to default terminal
            $TERMINAL -e bash -c "clipse; pkill -f clipse-popup" &
        fi
        
        # Auto-close after 30 seconds if no interaction
        (sleep 30 && pkill -f "clipse-popup") &
        ;;
esac