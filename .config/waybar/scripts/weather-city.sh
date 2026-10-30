#!/usr/bin/env bash
# Asks for the weather city on wofi (right click on the weather module).
# Typing a city sets it in weather.conf; the automatic option goes back to
# the location of the IP

source "$HOME/.config/dotfiles/lang.sh"
source "$(resolve_lang "$HOME/.config/waybar/i18n/weather" sh)"

readonly CONF="$HOME/.config/waybar/weather.conf"
readonly SCRIPTS="$HOME/.config/waybar/scripts"

city=""
units=""
[[ -f "$CONF" ]] && source "$CONF"

# Only one menu at a time
pgrep -x wofi >/dev/null && exit 0

chosen=$(printf '%s\n' "$automatic" |
    wofi --dmenu --prompt "${city_prompt^^}" --width 400 --height 120 -i) || exit 0

if [[ "$chosen" == "$automatic" ]]; then
    city=""
else
    city="$chosen"
fi

# Rewrites weather.conf with the new city, keeping the chosen units
{
    printf '# Leave city empty to use the location of your IP, or right click the\n'
    printf '# weather on waybar to set it from a menu\n'
    printf 'city=%q\n' "$city"
    printf '\n# metric (°C, km/h) or imperial (°F, mph); empty follows your country\n'
    printf 'units=%q\n' "$units"
} > "$CONF"

exec "$SCRIPTS/weather.sh" refresh