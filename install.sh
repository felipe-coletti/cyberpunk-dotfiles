#!/usr/bin/env bash
# install.sh — cyberpunk-dotfiles installer (Arch + Hyprland)

set -euo pipefail

# ─── Colors ─────────────────────────────────────────────────
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m' NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────
log()     { printf "%b\n" "$1"; }
ok()      { log "${GREEN}✔${NC} $1"; }
warn()    { log "${YELLOW}⚠${NC} $1"; }
err()     { log "${RED}✖${NC} $1"; }
section() { log "\n${BLUE}── $1 ──${NC}"; }

# ─── Paths ──────────────────────────────────────────────────
readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
readonly CONFIG_DIR="$HOME/.config"
readonly SDDM_THEME_DIR="/usr/share/sddm/themes/cyberpunk"

readonly PKGS=(
    hyprland kitty thunar yazi hyprpaper libnotify
    playerctl brightnessctl wireplumber pipewire
    ttf-jetbrains-mono-nerd ttf-font-awesome git rsync
    papirus-icon-theme noto-fonts-emoji
    noto-fonts noto-fonts-cjk
    hyprlock qt5-wayland qt6-wayland dconf sddm neovim
    python-gobject python-cairo gtk3 xdg-user-dirs jq gtk-layer-shell
    ffmpeg 7zip poppler fd ripgrep fzf zoxide imagemagick
)

# ─── 1. Check prerequisites ──────────────────────────────────
check_prereqs() {
    section "Checking prerequisites"

    if [[ ! -f /etc/arch-release ]]; then
        warn "This script was made for Arch Linux."
    fi

    if ! command -v git &>/dev/null; then
        err "git not found."
        exit 1
    fi

    ok "Prerequisites checked."
}

# ─── 2. Install packages ────────────────────────────────────
install_packages() {
    section "Installing packages"

    local missing=()
    for pkg in "${PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if ((${#missing[@]})); then
        log "Missing packages: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
        ok "Packages installed."
    else
        ok "All packages are already installed."
    fi

    install_quickshell
}

# The bar is made with Quickshell, which is on the AUR: pacman is used if it's
# in the official repositories, otherwise yay or paru
install_quickshell() {
    if pacman -Qi quickshell &>/dev/null; then
        ok "Quickshell is already installed."
    elif pacman -Si quickshell &>/dev/null; then
        sudo pacman -S --needed --noconfirm quickshell
        ok "Quickshell installed."
    elif command -v yay &>/dev/null; then
        yay -S --needed --noconfirm quickshell
        ok "Quickshell installed (AUR)."
    elif command -v paru &>/dev/null; then
        paru -S --needed --noconfirm quickshell
        ok "Quickshell installed (AUR)."
    else
        warn "Quickshell not found: install it from the AUR (with yay, for example) for the bar to show up."
    fi
}

# ─── 3. Back up existing configs ────────────────────────────
backup_existing() {
    section "Backing up existing configs"

    local has_backup=false
    for dir in hypr quickshell kitty yazi hyprpaper colors dotfiles gtk-3.0 neon widgets; do
        local target="$CONFIG_DIR/$dir"
        if [[ -e "$target" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "$target" "$BACKUP_DIR/"
            has_backup=true
            warn "Backup: $target"
        fi
    done

    if $has_backup; then
        ok "Backup saved to $BACKUP_DIR"
    else
        ok "No backup needed."
    fi
}

# ─── 4. Copy configs ────────────────────────────────────────
copy_config() {
    section "Copying configs"

    mkdir -p "$CONFIG_DIR"

    for dir in hypr quickshell kitty yazi hyprpaper colors dotfiles gtk-3.0 neon widgets; do
        local src="$REPO_DIR/.config/$dir"
        local dst="$CONFIG_DIR/$dir"

        if [[ -d "$src" ]]; then
            # Sync in place (without deleting the folder) so Hyprland's
            # autoreload never finds the config missing halfway through.
            # Personal files are left out (Thunar/GTK bookmarks, chosen
            # neon color, weather city)
            rsync -a --delete \
                --exclude "/bookmarks" \
                --exclude "/color" \
                --exclude "/weather.conf" \
                "$src/" "$dst/"
            ok "Copied: $dir"
        else
            warn "Folder not found: $src"
        fi
    done

    # The weather city is kept on reinstall; the default one (empty, so the
    # location comes from the IP) is only copied the first time. The city set
    # with the waybar of version 1 is carried over
    if [[ ! -f "$CONFIG_DIR/quickshell/weather.conf" ]]; then
        if [[ -f "$CONFIG_DIR/waybar/weather.conf" ]]; then
            cp "$CONFIG_DIR/waybar/weather.conf" "$CONFIG_DIR/quickshell/weather.conf"
        else
            cp "$REPO_DIR/.config/quickshell/weather.conf" "$CONFIG_DIR/quickshell/weather.conf"
        fi
    fi
}

# ─── 5. Neovim colorscheme ──────────────────────────────────
install_nvim_theme() {
    section "Neovim colorscheme"

    # Only the colorscheme is copied, so an existing Neovim config is kept
    local nvim_dir="$CONFIG_DIR/nvim"
    mkdir -p "$nvim_dir/colors"
    cp "$REPO_DIR/.config/nvim/colors/cyberpunk.lua" "$nvim_dir/colors/"
    ok "Colorscheme installed: $nvim_dir/colors/cyberpunk.lua"

    if [[ ! -e "$nvim_dir/init.lua" && ! -e "$nvim_dir/init.vim" ]]; then
        cp "$REPO_DIR/.config/nvim/init.lua" "$nvim_dir/init.lua"
        ok "Minimal Neovim config created with the theme."
    elif grep -qs "cyberpunk" "$nvim_dir/init.lua" "$nvim_dir/init.vim"; then
        ok "Your Neovim config already uses the theme."
    else
        warn "Your Neovim config was kept. To use the theme, add to it:"
        log "  ${BLUE}vim.cmd.colorscheme(\"cyberpunk\")${NC}"
    fi
}

# ─── 6. Home folders in the system language ─────────────────
setup_user_dirs() {
    section "Home folders in the system language"

    if ! command -v xdg-user-dirs-update &>/dev/null; then
        warn "xdg-user-dirs not found."
        return
    fi

    # Default English names, used when a folder is not configured yet
    local -A english=(
        [DESKTOP]=Desktop [DOWNLOAD]=Downloads [TEMPLATES]=Templates
        [PUBLICSHARE]=Public [DOCUMENTS]=Documents [MUSIC]=Music
        [PICTURES]=Pictures [VIDEOS]=Videos
    )

    # Names in the system language
    # (--dummy-output only prints the list, without creating or moving anything)
    local localized
    localized=$(mktemp)
    xdg-user-dirs-update --force --dummy-output "$localized" >/dev/null

    local pattern='^XDG_([A-Z]+)_DIR="\$HOME/(.*)"$'
    local line key new old
    while IFS= read -r line; do
        [[ "$line" =~ $pattern ]] || continue
        key="${BASH_REMATCH[1]}"
        new="$HOME/${BASH_REMATCH[2]}"

        # Current folder: the configured one or, if unset, the English default
        old=$(xdg-user-dir "$key")
        if [[ "$old" == "$HOME" && -n "${english[$key]:-}" ]]; then
            old="$HOME/${english[$key]}"
        fi

        if [[ "$old" != "$new" && -d "$old" ]]; then
            if [[ -e "$new" ]]; then
                warn "Kept: ${old#"$HOME/"} (${new#"$HOME/"} already exists)"
                xdg-user-dirs-update --set "$key" "$old"
                continue
            fi
            mv "$old" "$new"
            ok "Renamed: ${old#"$HOME/"} → ${new#"$HOME/"}"
        fi

        mkdir -p "$new"
        xdg-user-dirs-update --set "$key" "$new"
    done < "$localized"

    rm -f "$localized"
    ok "Home folders set up."
}

# ─── 7. Login screen (SDDM) ─────────────────────────────────
install_sddm() {
    section "Login screen (SDDM)"

    # Theme, keeping the neon color the user already picked (theme.conf.user)
    sudo mkdir -p "$SDDM_THEME_DIR"
    sudo rsync -a --delete --exclude "theme.conf.user" \
        "$REPO_DIR/sddm/cyberpunk/" "$SDDM_THEME_DIR/"

    # The greeter can't read ~/.config, so apply.sh writes the neon color
    # here; the file belongs to the user so it can do that without sudo
    sudo touch "$SDDM_THEME_DIR/theme.conf.user"
    sudo chown "$USER" "$SDDM_THEME_DIR/theme.conf.user"
    ok "Theme installed: $SDDM_THEME_DIR"

    sudo mkdir -p /etc/sddm.conf.d
    printf '[Theme]\nCurrent=cyberpunk\n' |
        sudo tee /etc/sddm.conf.d/cyberpunk.conf >/dev/null

    # /etc/sddm.conf is read last and would override the theme set above
    if [[ -f /etc/sddm.conf ]] &&
       grep '^Current=' /etc/sddm.conf | grep -qvx 'Current=cyberpunk'; then
        mkdir -p "$BACKUP_DIR"
        cp /etc/sddm.conf "$BACKUP_DIR/sddm.conf"
        sudo sed -i 's/^Current=.*/Current=cyberpunk/' /etc/sddm.conf
        warn "Theme set in /etc/sddm.conf too (backup in $BACKUP_DIR)"
    fi
    ok "Theme selected."

    # Enable SDDM, replacing any other display manager
    local current
    current=$(readlink /etc/systemd/system/display-manager.service 2>/dev/null || true)
    current=$(basename "$current" .service)

    if [[ "$current" == "sddm" ]]; then
        ok "SDDM is already enabled."
    else
        if [[ -n "$current" ]]; then
            sudo systemctl disable "$current"
            warn "Disabled $current"
        fi
        sudo systemctl enable sddm
        ok "SDDM enabled (it starts on the next boot)."
    fi
}

# ─── 8. Final touches ───────────────────────────────────────
post_install() {
    section "Final touches"

    chmod +x "$REPO_DIR/install.sh"

    # Reapply the saved neon color (the copy above resets the files to white)
    if "$CONFIG_DIR/neon/apply.sh" --no-reload; then
        ok "Neon color applied: #$(<"$CONFIG_DIR/neon/color")"
    else
        warn "Could not apply the neon color."
    fi

    # GTK theme: on Wayland, apps read gsettings, not settings.ini
    if command -v gsettings &>/dev/null; then
        local iface="org.gnome.desktop.interface"
        if gsettings set "$iface" gtk-theme    "Adwaita-dark" &&
           gsettings set "$iface" color-scheme "prefer-dark" &&
           gsettings set "$iface" icon-theme   "Papirus-Dark" &&
           gsettings set "$iface" font-name    "JetBrainsMono Nerd Font 10"; then
            ok "GTK theme applied."
        else
            warn "Could not apply the GTK theme via gsettings."
        fi
    fi

    # Apply the config to the current session if Hyprland is running
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload >/dev/null
        # The bar and notifications of version 1, if they're still running
        # (mako would keep the notification service)
        pkill -x waybar || true
        pkill -x mako || true
        pkill -x quickshell || true
        setsid -f quickshell >/dev/null 2>&1
        ok "Hyprland and Quickshell reloaded."
    fi

    ok "Installation complete."
}

# ─── 9. Summary ─────────────────────────────────────────────
summary() {
    log "\n${GREEN}════════════════════════════════════${NC}"
    log "${GREEN}  Dotfiles installed successfully!  ${NC}"
    log "${GREEN}════════════════════════════════════${NC}"
    log ""
    log "To test:"
    log "  ${BLUE}hyprctl reload${NC}"
    log "  ${BLUE}pkill -x quickshell; setsid -f quickshell${NC}"
    log ""
    log "If something went wrong, restore the backup:"
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
    install_nvim_theme
    setup_user_dirs
    install_sddm
    post_install
    summary
}

main "$@"