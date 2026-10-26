#!/usr/bin/env bash
# install.sh — Instalação dos cyberpunk-dotfiles (Arch + Hyprland)

set -euo pipefail

# ─── Cores ──────────────────────────────────────────────────
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m' NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────
log()     { printf "%b\n" "$1"; }
ok()      { log "${GREEN}✔${NC} $1"; }
warn()    { log "${YELLOW}⚠${NC} $1"; }
err()     { log "${RED}✖${NC} $1"; }
section() { log "\n${BLUE}── $1 ──${NC}"; }

# ─── Caminhos ───────────────────────────────────────────────
readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
readonly CONFIG_DIR="$HOME/.config"

readonly PKGS=(
    hyprland waybar foot thunar wofi mako hyprpaper
    playerctl brightnessctl wireplumber pipewire
    ttf-jetbrains-mono-nerd ttf-font-awesome git rsync
    papirus-icon-theme noto-fonts-emoji
    hyprlock qt5-wayland qt6-wayland dconf
    python-gobject python-cairo gtk3 xdg-user-dirs
)

# ─── 1. Verificar pré-requisitos ─────────────────────────────
check_prereqs() {
    section "Verificando pré-requisitos"

    if [[ ! -f /etc/arch-release ]]; then
        warn "Este script foi feito para Arch Linux."
    fi

    if ! command -v git &>/dev/null; then
        err "git não encontrado."
        exit 1
    fi

    ok "Pré-requisitos verificados."
}

# ─── 2. Instalar pacotes ────────────────────────────────────
install_packages() {
    section "Instalando pacotes"

    local missing=()
    for pkg in "${PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if ((${#missing[@]})); then
        log "Pacotes faltando: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
        ok "Pacotes instalados."
    else
        ok "Todos os pacotes já estão instalados."
    fi
}

# ─── 3. Backup de configs existentes ────────────────────────
backup_existing() {
    section "Backup de configs existentes"

    local has_backup=false
    for dir in hypr waybar foot mako wofi hyprpaper colors dotfiles gtk-3.0 neon; do
        local target="$CONFIG_DIR/$dir"
        if [[ -e "$target" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "$target" "$BACKUP_DIR/"
            has_backup=true
            warn "Backup: $target"
        fi
    done

    if $has_backup; then
        ok "Backup salvo em $BACKUP_DIR"
    else
        ok "Sem backups necessários."
    fi
}

# ─── 4. Copiar configurações ────────────────────────────────
copy_config() {
    section "Copiando configurações"

    mkdir -p "$CONFIG_DIR"

    for dir in hypr waybar foot mako wofi hyprpaper colors dotfiles gtk-3.0 neon; do
        local src="$REPO_DIR/.config/$dir"
        local dst="$CONFIG_DIR/$dir"

        if [[ -d "$src" ]]; then
            # Sincroniza no lugar (sem apagar a pasta) para o autoreload do
            # Hyprland nunca encontrar a config ausente no meio da cópia.
            # Ficam de fora arquivos gerados ou pessoais (idioma do waybar,
            # favoritos do Thunar/GTK, cor do neon escolhida)
            rsync -a --delete \
                --exclude "i18n/current.jsonc" \
                --exclude "/bookmarks" \
                --exclude "/color" \
                "$src/" "$dst/"
            ok "Copiado: $dir"
        else
            warn "Pasta não encontrada: $src"
        fi
    done
}

# ─── 5. Pastas pessoais no idioma do sistema ────────────────
setup_user_dirs() {
    section "Pastas pessoais no idioma do sistema"

    if ! command -v xdg-user-dirs-update &>/dev/null; then
        warn "xdg-user-dirs não encontrado."
        return
    fi

    # Nomes padrão em inglês, usados quando a pasta ainda não está configurada
    local -A english=(
        [DESKTOP]=Desktop [DOWNLOAD]=Downloads [TEMPLATES]=Templates
        [PUBLICSHARE]=Public [DOCUMENTS]=Documents [MUSIC]=Music
        [PICTURES]=Pictures [VIDEOS]=Videos
    )

    # Nomes no idioma do sistema
    # (--dummy-output só gera a lista, sem criar nem mover nada)
    local localized
    localized=$(mktemp)
    xdg-user-dirs-update --force --dummy-output "$localized" >/dev/null

    local pattern='^XDG_([A-Z]+)_DIR="\$HOME/(.*)"$'
    local line key new old
    while IFS= read -r line; do
        [[ "$line" =~ $pattern ]] || continue
        key="${BASH_REMATCH[1]}"
        new="$HOME/${BASH_REMATCH[2]}"

        # Pasta atual: a configurada ou, sem configuração, a padrão em inglês
        old=$(xdg-user-dir "$key")
        if [[ "$old" == "$HOME" && -n "${english[$key]:-}" ]]; then
            old="$HOME/${english[$key]}"
        fi

        if [[ "$old" != "$new" && -d "$old" ]]; then
            if [[ -e "$new" ]]; then
                warn "Mantida: ${old#"$HOME/"} (${new#"$HOME/"} já existe)"
                xdg-user-dirs-update --set "$key" "$old"
                continue
            fi
            mv "$old" "$new"
            ok "Renomeada: ${old#"$HOME/"} → ${new#"$HOME/"}"
        fi

        mkdir -p "$new"
        xdg-user-dirs-update --set "$key" "$new"
    done < "$localized"

    rm -f "$localized"
    ok "Pastas pessoais configuradas."
}

# ─── 6. Ajustes finais ──────────────────────────────────────
post_install() {
    section "Ajustes finais"

    chmod +x "$REPO_DIR/install.sh"

    # Reaplica a cor do neon salva (a cópia acima volta os arquivos ao branco)
    if "$CONFIG_DIR/neon/apply.sh" --no-reload; then
        ok "Cor do neon aplicada: #$(<"$CONFIG_DIR/neon/color")"
    else
        warn "Não foi possível aplicar a cor do neon."
    fi
    mkdir -p "$HOME/Pictures/screenshots"

    # Tema GTK: no Wayland os apps leem o gsettings, não o settings.ini
    if command -v gsettings &>/dev/null; then
        local iface="org.gnome.desktop.interface"
        if gsettings set "$iface" gtk-theme    "Adwaita-dark" &&
           gsettings set "$iface" color-scheme "prefer-dark" &&
           gsettings set "$iface" icon-theme   "Papirus-Dark" &&
           gsettings set "$iface" font-name    "JetBrainsMono Nerd Font 10"; then
            ok "Tema GTK aplicado."
        else
            warn "Não foi possível aplicar o tema GTK via gsettings."
        fi
    fi

    # Aplica a config na sessão atual, se o Hyprland estiver rodando
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload >/dev/null
        pkill -x waybar || true
        setsid -f "$CONFIG_DIR/waybar/launch.sh" >/dev/null 2>&1
        ok "Hyprland e Waybar recarregados."
    fi

    ok "Instalação concluída."
}

# ─── 7. Resumo ──────────────────────────────────────────────
summary() {
    log "\n${GREEN}════════════════════════════════════${NC}"
    log "${GREEN}  Dotfiles instalados com sucesso!  ${NC}"
    log "${GREEN}════════════════════════════════════${NC}"
    log ""
    log "Para testar:"
    log "  ${BLUE}hyprctl reload${NC}"
    log "  ${BLUE}killall -SIGUSR2 waybar${NC}"
    log ""
    log "Se algo deu errado, restaure o backup:"
    log "  ${BLUE}cp -r $BACKUP_DIR/* ~/.config/${NC}"
}

# ─── Main ───────────────────────────────────────────────────
main() {
    log "${BLUE}╔══════════════════════════════════════╗${NC}"
    log "${BLUE}║   Cyberpunk Dotfiles Installer       ║${NC}"
    log "${BLUE}╚══════════════════════════════════════╝${NC}"

    check_prereqs
    install_packages
    backup_existing
    copy_config
    setup_user_dirs
    post_install
    summary
}

main "$@"