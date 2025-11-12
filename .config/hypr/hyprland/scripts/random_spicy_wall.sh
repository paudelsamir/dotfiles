#!/usr/bin/env bash
set -euo pipefail

# Random wallpaper picker for /home/sam/Pictures/🌶️
DIR="/home/sam/Pictures/🌶️"

mapfile -t files < <(find "$DIR" -maxdepth 1 -type f 2>/dev/null)
if [ ${#files[@]} -eq 0 ]; then
  notify-send "No wallpapers" "No files found in $DIR"
  exit 0
fi

chosen="${files[RANDOM % ${#files[@]}]}"

exec /home/sam/.config/quickshell/ii/scripts/colors/switchwall.sh --image "$chosen"
