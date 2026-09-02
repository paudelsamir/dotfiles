#!/usr/bin/env bash
set -euo pipefail

target=$(niri msg -j focused-window | jq -r '.id')

prev=$(niri msg -j windows | jq -r "[.[] | select(.id != $target)] | first | .id // empty")

if [ -z "$prev" ]; then
    exit 1
fi

niri msg action focus-window --id "$prev"
sleep 0.1
niri msg action toggle-window-rule-opacity --id "$target"
