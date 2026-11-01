#!/usr/bin/env bash
# Sets the weather city in weather.conf, keeping the chosen units. Called by
# the city menu (right click on the weather); the bar follows weather.conf
# and updates the weather
# Usage: weather-city.sh CITY    uses that city
#        weather-city.sh         goes back to the location of the IP

readonly CONF="$HOME/.config/quickshell/weather.conf"
readonly SCRIPTS="$HOME/.config/quickshell/scripts"

units=""
[[ -f "$CONF" ]] && source "$CONF"
city="${1:-}"

{
    printf '# Leave city empty to use the location of your IP, or right click the\n'
    printf '# weather on the bar to set it from a menu\n'
    printf 'city=%q\n' "$city"
    printf '\n# metric (°C, km/h) or imperial (°F, mph); empty follows your country\n'
    printf 'units=%q\n' "$units"
} > "$CONF"

# Back to the IP: look the location up again
exec "$SCRIPTS/weather.sh" refresh
