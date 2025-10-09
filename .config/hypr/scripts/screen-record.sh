#!/bin/bash

# Screen recording script for Hyprland using wf-recorder
# Usage: Super+Shift+R to start/stop recording

RECORDINGS_DIR="$HOME/Videos/Recordings"
PID_FILE="/tmp/wf-recorder.pid"
RECORDING_INDICATOR="/tmp/recording_active"

# Create recordings directory if it doesn't exist
mkdir -p "$RECORDINGS_DIR"

# Function to start recording
start_recording() {
    # Generate filename with timestamp
    FILENAME="$RECORDINGS_DIR/screen-record-$(date '+%Y-%m-%d_%H-%M-%S').mp4"
    
    # Get active monitor
    MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
    
    # Ask user what to record
    CHOICE=$(echo -e "Screen (No Audio)\nScreen (With Audio)\nRegion (No Audio)\nRegion (With Audio)\nWindow (No Audio)\nWindow (With Audio)" | fuzzel --dmenu --prompt "Record: ")
    
    # Get default audio source for recording with audio
    AUDIO_SOURCE=$(pactl get-default-source)
    
    case "$CHOICE" in
        "Screen (No Audio)")
            # Record entire screen without audio
            wf-recorder -o "$MONITOR" -f "$FILENAME" &
            echo $! > "$PID_FILE"
            ;;
        "Screen (With Audio)")
            # Record entire screen with audio
            wf-recorder -o "$MONITOR" --audio="$AUDIO_SOURCE" -f "$FILENAME" &
            echo $! > "$PID_FILE"
            ;;
        "Region (No Audio)")
            # Record selected region without audio
            GEOMETRY=$(slurp)
            if [ -n "$GEOMETRY" ]; then
                wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
                echo $! > "$PID_FILE"
            else
                notify-send "Screen Recording" "Recording cancelled" -i "media-record"
                exit
            fi
            ;;
        "Region (With Audio)")
            # Record selected region with audio
            GEOMETRY=$(slurp)
            if [ -n "$GEOMETRY" ]; then
                wf-recorder -g "$GEOMETRY" --audio="$AUDIO_SOURCE" -f "$FILENAME" &
                echo $! > "$PID_FILE"
            else
                notify-send "Screen Recording" "Recording cancelled" -i "media-record"
                exit
            fi
            ;;
        "Window (No Audio)")
            # Record active window without audio
            WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            wf-recorder -g "$WINDOW_GEOMETRY" -f "$FILENAME" &
            echo $! > "$PID_FILE"
            ;;
        "Window (With Audio)")
            # Record active window with audio
            WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            wf-recorder -g "$WINDOW_GEOMETRY" --audio="$AUDIO_SOURCE" -f "$FILENAME" &
            echo $! > "$PID_FILE"
            ;;
        *)
            notify-send "Screen Recording" "Recording cancelled" -i "media-record"
            exit
            ;;
    esac
    
    # Create recording indicator
    touch "$RECORDING_INDICATOR"
    
    # Notify user
    notify-send "Screen Recording" "Recording started\nSaving to: $(basename "$FILENAME")" -i "media-record" -t 3000
}

# Function to stop recording
stop_recording() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill -INT "$PID" 2>/dev/null
        rm -f "$PID_FILE"
        rm -f "$RECORDING_INDICATOR"
        notify-send "Screen Recording" "Recording stopped and saved!" -i "media-record" -t 3000
    else
        notify-send "Screen Recording" "No active recording found" -i "media-record"
    fi
}

# Check if already recording
if [ -f "$PID_FILE" ] && [ -f "$RECORDING_INDICATOR" ]; then
    # Stop recording
    stop_recording
else
    # Start recording
    start_recording
fi