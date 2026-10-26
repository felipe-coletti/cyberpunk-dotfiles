#!/usr/bin/env bash
# Seleciona os textos do idioma do sistema e inicia o waybar

source "$HOME/.config/dotfiles/lang.sh"

dir="$HOME/.config/waybar/i18n"
ln -sf "$(basename "$(resolve_lang "$dir" jsonc)")" "$dir/current.jsonc"

exec waybar "$@"