#!/bin/bash
while true; do
  R=$(hyprctl monitors 2>/dev/null | grep -A1 "eDP-1" | grep "@" | awk '{print $1}')
  if [[ "$R" != "1920x1080@60.00400" ]] && [[ ! -z "$R" ]]; then
    hyprctl keyword monitor ",1920x1080@60,auto,1"
    echo "[$(date)] Fixed: $R -> 1920x1080"
  fi
  sleep 0.2
done
