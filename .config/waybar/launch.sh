#!/usr/bin/env bash
# Selects the texts for the system language and starts waybar

source "$HOME/.config/dotfiles/lang.sh"

dir="$HOME/.config/waybar/i18n"
ln -sf "$(basename "$(resolve_lang "$dir" jsonc)")" "$dir/current.jsonc"

exec waybar "$@"