#!/bin/bash
# Lançador de apps com o prompt no idioma do sistema

source "$HOME/.config/dotfiles/lang.sh"
source "$(resolve_lang "$HOME/.config/wofi/i18n" sh)"

exec wofi --show drun --prompt "${prompt^^}" "$@"