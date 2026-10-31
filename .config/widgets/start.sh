#!/usr/bin/env bash
# Starts the desktop widgets listed in widgets.conf, restarting them if
# they're already running. Started by Hyprland on login (see
# hypr/autostart.lua). Each widget is a folder with a main.py
readonly dir="$HOME/.config/widgets"

# Stop every widget, also the ones just removed from widgets.conf
pkill -f "^python3 $dir/[^/]+/main\.py"

while read -r name _ || [[ -n "$name" ]]; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ -f "$dir/$name/main.py" ]]; then
        python3 "$dir/$name/main.py" &
    else
        echo "widgets: no widget called \"$name\" in $dir" >&2
    fi
done < "$dir/widgets.conf"
