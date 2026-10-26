#!/usr/bin/env bash
# Aplica a cor do neon em todo o tema (waybar, wofi, GTK, Hyprland e hyprlock)
# Uso: apply.sh [RRGGBB] [--no-reload]
#   sem cor: reaplica a cor salva (ou o branco padrão)

set -euo pipefail

readonly CONFIG_DIR="$HOME/.config"
readonly STATE="$CONFIG_DIR/neon/color"
readonly DEFAULT="ffffff"

reload=true
hex=""
for arg in "$@"; do
    case "$arg" in
        --no-reload) reload=false ;;
        *)           hex="$arg" ;;
    esac
done

if [[ -z "$hex" && -f "$STATE" ]]; then
    hex=$(<"$STATE")
fi
hex="${hex:-$DEFAULT}"
hex="${hex#\#}"
hex="${hex,,}"

if [[ ! "$hex" =~ ^[0-9a-f]{6}$ ]]; then
    echo "Cor inválida: '$hex' (use o formato RRGGBB)" >&2
    exit 1
fi

printf '%s\n' "$hex" > "$STATE"

# ─── Arquivos gerados ───────────────────────────────────────
# Todos têm uma versão padrão (branca) no repositório

cat > "$CONFIG_DIR/colors/neon.css" <<CSS
/* Gerado por ~/.config/neon/apply.sh */
@define-color neon #$hex;
CSS

cat > "$CONFIG_DIR/hypr/neon.lua" <<LUA
-- Gerado por ~/.config/neon/apply.sh
neon = "$hex"
LUA

cat > "$CONFIG_DIR/hypr/neon.conf" <<CONF
# Gerado por ~/.config/neon/apply.sh
\$neon       = rgb($hex)
\$neon_dim   = rgba(${hex}80)
\$neon_faint = rgba(${hex}40)
\$neon_glow  = rgba(${hex}aa)
CONF

# ─── Recarregar ─────────────────────────────────────────────
# O wofi e o hyprlock leem a cor ao abrir; apps GTK já abertos (Thunar)
# só mudam ao reiniciar
if $reload; then
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload >/dev/null
    fi
    pkill -SIGUSR2 -x waybar || true
fi
