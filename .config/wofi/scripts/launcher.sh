#!/bin/bash
# App launcher with the prompt in the system language

source "$HOME/.config/dotfiles/lang.sh"
source "$(resolve_lang "$HOME/.config/wofi/i18n" sh)"

exec wofi --show drun --prompt "${prompt^^}" "$@"
