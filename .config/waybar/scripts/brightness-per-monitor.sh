#!/bin/bash

# --- CONFIGURATION ---
STEP=5
STATE_FILE_PREFIX="/tmp/waybar_brightness"
# ---------------------

get_monitor_name() {
    if [ -n "$1" ]; then
        echo "$1"
    elif [ -n "$WAYBAR_OUTPUT_NAME" ]; then
        echo "$WAYBAR_OUTPUT_NAME"
    else
        hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
    fi
}

get_ddcutil_display() {
    local monitor_name="$1"
    case "$monitor_name" in
        "DP-7")
            echo "1"  # Ajuste conforme sua saída em 'ddcutil detect'
            ;;
        *)
            echo ""  # Sem suporte DDC/CI
            ;;
    esac
}

get_state_file() {
    local monitor="$1"
    echo "${STATE_FILE_PREFIX}_${monitor}.tmp"
}

set_brightness_ddcutil() {
    local display_num="$1"
    local brightness="$2"
    pkill -f "ddcutil.*setvcp 10"
    (ddcutil --display "$display_num" setvcp 10 "$brightness") &
}

set_brightness_laptop() {
    local brightness="$1"
    brightnessctl set "${brightness}%" > /dev/null 2>&1
}

get_current_brightness() {
    local monitor="$1"
    local display_num=$(get_ddcutil_display "$monitor")

    if [ "$monitor" = "eDP-1" ]; then
        brightnessctl get 2>/dev/null || echo "0"
    elif [ -n "$display_num" ]; then
        ddcutil --display "$display_num" getvcp 10 -t 2>/dev/null | awk '{print $4}' || echo "100"
    else
        echo "?"
    fi
}

get_max_brightness() {
    local monitor="$1"
    local display_num=$(get_ddcutil_display "$monitor")

    if [ "$monitor" = "eDP-1" ]; then
        brightnessctl max 2>/dev/null || echo "1"
    elif [ -n "$display_num" ]; then
        echo "100"
    else
        echo "1"
    fi
}

set_brightness() {
    local monitor="$1"
    local new_brightness="$2"
    local display_num=$(get_ddcutil_display "$monitor")

    if [ "$monitor" = "eDP-1" ]; then
        brightnessctl set "$new_brightness" > /dev/null 2>&1
    elif [ -n "$display_num" ]; then
        pkill -f "ddcutil.*setvcp 10" 2>/dev/null
        (ddcutil --display "$display_num" setvcp 10 "$new_brightness") &
    fi
    pkill -RTMIN+8 waybar
}   

COMMAND="$1"
MONITOR=$(get_monitor_name "$2")
current=$(get_current_brightness "$MONITOR")
max=$(get_max_brightness "$MONITOR")
step=$((max * STEP / 100))

case "$COMMAND" in
    "get")
        percent=$((current * 100 / max))
        echo "$percent"
        ;;
    "up")
        if [ "$current" != "?" ]; then
            new_brightness=$((current + step))
            if [ "$new_brightness" -gt "$max" ]; then
                new_brightness=$max
            fi
            if [ "$current" -ne "$new_brightness" ]; then
                set_brightness "$MONITOR" "$new_brightness"
            fi
        fi
        ;;
    "down")
        if [ "$current" != "?" ]; then
            new_brightness=$((current - step))
            if [ "$new_brightness" -lt 0 ]; then
                new_brightness=0
            fi
            if [ "$current" -ne "$new_brightness" ]; then
                set_brightness "$MONITOR" "$new_brightness"
            fi
        fi
        ;;
    "left_click")
        set_brightness "$MONITOR" "$max"
        ;;
    "right_click")
        set_brightness "$MONITOR" "0"
        ;;
esac
