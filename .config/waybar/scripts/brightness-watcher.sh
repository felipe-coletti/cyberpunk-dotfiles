#!/usr/bin/env bash
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

prev=$(brightnessctl get 2>/dev/null)
while true; do
    sleep 0.3
    current=$(brightnessctl get 2>/dev/null)
    if [ "$current" != "$prev" ]; then
        prev="$current"
        pkill -RTMIN+8 waybar
    fi
done   
