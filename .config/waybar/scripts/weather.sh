#!/usr/bin/env bash
# Weather for waybar, from Open-Meteo (no account or API key needed)
# The location comes from your IP (looked up on ipinfo.io), or from the city
# in ~/.config/waybar/weather.conf when it's set. Offline, it shows the last
# weather it got
# Usage: weather.sh            prints the module as JSON for waybar
#        weather.sh refresh    looks up the location again and updates the
#                              module now (on click)

readonly SIGNAL=9
readonly CONF="$HOME/.config/waybar/weather.conf"
readonly CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-weather"
readonly IP_LOCATION_TTL=3600  # seconds the IP location is reused

if [[ "${1:-}" == "refresh" ]]; then
    rm -f "$CACHE_DIR/ip-location"
    pkill -RTMIN+$SIGNAL -x waybar
    exit 0
fi

city=""
units=""
[[ -f "$CONF" ]] && source "$CONF"

source "$HOME/.config/dotfiles/lang.sh"
source "$(resolve_lang "$HOME/.config/waybar/i18n/weather" sh)"

mkdir -p "$CACHE_DIR"
lang="${LC_ALL:-${LC_MESSAGES:-$LANG}}"
lang="${lang%%_*}"
lang="${lang%%.*}"
[[ "$lang" =~ ^[a-z]{2,3}$ ]] || lang="en"

# Prints the JSON for waybar
output() {
    jq -cn --arg text "$1" --arg tooltip "$2" --arg class "$3" \
        '{text: $text, tooltip: ($tooltip | gsub("&"; "&amp;") | gsub("<"; "&lt;")), class: $class}'
}

# Offline or failed request: show the last weather, or hide the module
fallback() {
    [[ -f "$CACHE_DIR/last.json" ]] && cat "$CACHE_DIR/last.json"
    exit 0
}

# ─── Location ───────────────────────────────────────────────
country=""
if [[ -n "$city" ]]; then
    # City from weather.conf → coordinates (looked up once per city)
    coords="$CACHE_DIR/coords"
    if [[ ! -f "$coords" ]] || [[ "$(head -n 1 "$coords")" != "$city" ]]; then
        found=$(curl -sf --max-time 10 --get "https://geocoding-api.open-meteo.com/v1/search" \
            --data-urlencode "name=$city" --data "count=1" --data "language=$lang") || fallback

        if [[ "$(jq -r '.results | length' <<<"$found")" == "0" ]] || \
           [[ "$(jq -r '.results' <<<"$found")" == "null" ]]; then
            output $'\U000F0F2F' "$not_found: $city" "error"
            exit 0
        fi

        jq -r --arg city "$city" '.results[0] | $city, .name, .latitude, .longitude, .country_code' \
            <<<"$found" > "$coords"
    fi
    { read -r _; read -r place; read -r latitude; read -r longitude; read -r country; } < "$coords"
else
    # Location from the IP, reused for an hour (refresh looks it up again)
    location="$CACHE_DIR/ip-location"
    if [[ ! -f "$location" ]] || (( $(date +%s) - $(stat -c %Y "$location") > IP_LOCATION_TTL )); then
        if found=$(curl -sf --max-time 10 "https://ipinfo.io/json"); then
            jq -r '.city // "", (.loc // "" | split(",") | .[0] // "", .[1] // ""), .country // ""' \
                <<<"$found" > "$location.new"
            # Keep the previous location if the answer has no coordinates
            if [[ -n "$(sed -n 2p "$location.new")" ]]; then
                mv "$location.new" "$location"
            else
                rm -f "$location.new"
            fi
        fi
    fi
    [[ -f "$location" ]] || fallback
    { read -r place; read -r latitude; read -r longitude; read -r country; } < "$location"
fi
[[ -n "$latitude" && -n "$longitude" ]] || fallback

# Units: from weather.conf, or °F and mph where they're the norm
if [[ -z "$units" ]]; then
    case "$country" in
        US|LR|MM) units="imperial" ;;
        *)        units="metric" ;;
    esac
fi

# ─── Current weather ────────────────────────────────────────
if [[ "$units" == "imperial" ]]; then
    unit_params=(--data "temperature_unit=fahrenheit" --data "wind_speed_unit=mph")
    wind_unit="mph"
else
    unit_params=()
    wind_unit="km/h"
fi

weather=$(curl -sf --max-time 10 --get "https://api.open-meteo.com/v1/forecast" \
    --data "latitude=$latitude" --data "longitude=$longitude" \
    --data "current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,is_day,wind_speed_10m" \
    --data "timezone=auto" "${unit_params[@]}") || fallback

read -r temp feels humidity code is_day wind < <(jq -r '.current |
    [(.temperature_2m | round), (.apparent_temperature | round), .relative_humidity_2m,
     .weather_code, .is_day, (.wind_speed_10m | round)] | @tsv' <<<"$weather") || fallback
[[ -n "$code" && "$code" != "null" ]] || fallback

# ─── WMO weather code → icon, description and CSS class ─────
case "$code" in
    0)        icon=$'\U000F0599'; night=$'\U000F0594'; text=$clear;            class=clear ;;
    1)        icon=$'\U000F0595'; night=$'\U000F0F31'; text=$mainly_clear;     class=clear ;;
    2)        icon=$'\U000F0595'; night=$'\U000F0F31'; text=$partly_cloudy;    class=cloudy ;;
    3)        icon=$'\U000F0590';                      text=$overcast;         class=cloudy ;;
    45|48)    icon=$'\U000F0591';                      text=$fog;              class=fog ;;
    51|53|55) icon=$'\U000F0597';                      text=$drizzle;          class=rain ;;
    56|57)    icon=$'\U000F067F';                      text=$freezing_drizzle; class=rain ;;
    61|63)    icon=$'\U000F0597';                      text=$rain;             class=rain ;;
    65)       icon=$'\U000F0596';                      text=$rain;             class=rain ;;
    66|67)    icon=$'\U000F067F';                      text=$freezing_rain;    class=rain ;;
    71|73)    icon=$'\U000F0598';                      text=$snow;             class=snow ;;
    75)       icon=$'\U000F0F36';                      text=$snow;             class=snow ;;
    77)       icon=$'\U000F0598';                      text=$snow_grains;      class=snow ;;
    80|81|82) icon=$'\U000F0596';                      text=$rain_showers;     class=rain ;;
    85|86)    icon=$'\U000F0F36';                      text=$snow_showers;     class=snow ;;
    95)       icon=$'\U000F067E';                      text=$thunderstorm;     class=storm ;;
    96|99)    icon=$'\U000F0592';                      text=$hail;             class=storm ;;
    *)        icon=$'\U000F0590';                      text="";                class=cloudy ;;
esac
[[ "$is_day" == "0" && -n "${night:-}" ]] && icon=$night

tooltip="$place
$text
$feels_like: $feels°
$humidity_label: $humidity%
$wind_label: $wind $wind_unit

$refresh_hint
$change_hint"

output "$icon $temp°" "$tooltip" "$class" | tee "$CACHE_DIR/last.json"