#!/bin/bash

# Advanced screenshot script using grim + slurp for Hyprland
# More reliable than Flameshot on Wayland

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
TEMP_DIR="/tmp"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOTS_DIR"

# Generate filename with timestamp
FILENAME="screenshot-$(date '+%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$SCREENSHOTS_DIR/$FILENAME"

# Function for different screenshot types
screenshot_menu() {
    CHOICE=$(echo -e "🖼️  Full Screen\n📐  Select Region\n🪟  Active Window\n📱  Select Window" | fuzzel --dmenu --prompt "Screenshot: " | cut -d' ' -f3-)
    
    case "$CHOICE" in
        "Full Screen")
            grim "$FILEPATH"
            ACTION="fullscreen"
            ;;
        "Select Region")
            GEOMETRY=$(slurp 2>/dev/null)
            if [ -n "$GEOMETRY" ]; then
                grim -g "$GEOMETRY" "$FILEPATH"
                ACTION="region"
            else
                notify-send "Screenshot" "Selection cancelled" -i "camera-photo"
                exit 0
            fi
            ;;
        "Active Window")
            # Get active window geometry
            WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            grim -g "$WINDOW_GEOMETRY" "$FILEPATH"
            ACTION="window"
            ;;
        "Select Window")
            # Use slurp to select a window
            GEOMETRY=$(slurp -w 2>/dev/null)
            if [ -n "$GEOMETRY" ]; then
                grim -g "$GEOMETRY" "$FILEPATH"
                ACTION="selected window" 
            else
                notify-send "Screenshot" "Window selection cancelled" -i "camera-photo"
                exit 0
            fi
            ;;
        *)
            notify-send "Screenshot" "Cancelled" -i "camera-photo"
            exit 0
            ;;
    esac
}

# Take screenshot based on argument or show menu
case "${1:-menu}" in
    "full")
        grim "$FILEPATH"
        ACTION="fullscreen"
        ;;
    "region")
        GEOMETRY=$(slurp 2>/dev/null)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILEPATH"
            ACTION="region"
        else
            notify-send "Screenshot" "Selection cancelled" -i "camera-photo"
            exit 0
        fi
        ;;
    "window")
        WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$WINDOW_GEOMETRY" "$FILEPATH"
        ACTION="window"
        ;;
    *)
        screenshot_menu
        ;;
esac

# Copy to clipboard
wl-copy < "$FILEPATH"

# Show notification with actions
ACTION_RESULT=$(notify-send "Screenshot Saved" "📁 $FILENAME\n📋 Copied to clipboard\n🖼️ $ACTION screenshot" \
    -i "$FILEPATH" \
    -A "open=Open Image" \
    -A "folder=Open Folder" \
    -A "edit=Edit Image" \
    -t 5000)

# Handle notification actions
case "$ACTION_RESULT" in
    "open")
        xdg-open "$FILEPATH"
        ;;
    "folder")
        xdg-open "$SCREENSHOTS_DIR"
        ;;
    "edit")
        # Try to open with image editor
        if command -v gimp >/dev/null 2>&1; then
            gimp "$FILEPATH" &
        elif command -v krita >/dev/null 2>&1; then
            krita "$FILEPATH" &
        elif command -v kolourpaint >/dev/null 2>&1; then
            kolourpaint "$FILEPATH" &
        else
            xdg-open "$FILEPATH"
        fi
        ;;
esac