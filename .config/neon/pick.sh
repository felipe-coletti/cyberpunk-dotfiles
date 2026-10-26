#!/usr/bin/env bash
# Opens the color wheel and applies the chosen neon color

source "$HOME/.config/dotfiles/lang.sh"
source "$(resolve_lang "$HOME/.config/neon/i18n" sh)"

readonly dir="$HOME/.config/neon"

# Only one window at a time
pgrep -f "$dir/picker.py" >/dev/null && exit 0

export NEON_TITLE="$title" NEON_BRIGHTNESS="$brightness"
export NEON_DEFAULT="$default" NEON_CANCEL="$cancel" NEON_APPLY="$apply"

current=$(cat "$dir/color" 2>/dev/null || echo ffffff)
color=$(python3 "$dir/picker.py" "$current") || exit 0

exec "$dir/apply.sh" "$color"
