#!/bin/bash

source "$HOME/.config/dotfiles/lang.sh"
source "$(resolve_lang "$HOME/.config/wofi/i18n" sh)"

chosen=$(printf '%s\n' "$shutdown" "$reboot" "$lock" "$logout" | wofi --dmenu --prompt "${prompt^^}" --width 300 --height 200 -i)

case "$chosen" in
  "$shutdown") systemctl poweroff ;;
  "$reboot")   systemctl reboot ;;
  "$lock")     hyprlock ;;
  "$logout")   uwsm stop ;;
esac