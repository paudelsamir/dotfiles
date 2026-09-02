#!/bin/bash
# Debug script to capture Hyprland crash details

echo "=== Hyprland Debug Monitoring Started ==="
echo "If Hyprland crashes, this script will capture logs and crash info."
echo ""

# Monitor for crashes in background
while true; do
    if [ -f ~/.cache/hyprland/hyprlandCrashReport*.txt ]; then
        CRASH_FILE=$(ls -t ~/.cache/hyprland/hyprlandCrashReport*.txt | head -1)
        echo "[$(date)] ⚠️ CRASH DETECTED: $CRASH_FILE"
        
        # Copy to a debug folder
        mkdir -p ~/.config/hypr/crash_logs
        cp "$CRASH_FILE" ~/.config/hypr/crash_logs/
        
        # Get last log
        LOG_FILE=$(cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ 2>/dev/null | head -n 1)/hyprland.log 2>/dev/null)
        if [ -n "$LOG_FILE" ]; then
            echo "$LOG_FILE" > ~/.config/hypr/crash_logs/last_hyprland.log
        fi
        
        echo "[$(date)] ✓ Crash logs saved to ~/.config/hypr/crash_logs/"
        break
    fi
    sleep 1
done
