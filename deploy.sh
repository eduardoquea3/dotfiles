#!/usr/bin/env bash

set -e

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

echo "=== Dotfiles Deploy Script ==="
echo "Config directory: $CONFIG_DIR"
echo "Backup directory: $BACKUP_DIR"
echo ""

mkdir -p "$BACKUP_DIR"

deploy_config() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ ! -L "$dest" ]; then
            echo "Backing up $dest"
            mkdir -p "$(dirname "$BACKUP_DIR$dest")"
            cp -r "$dest" "$BACKUP_DIR$dest"
        fi
        rm -rf "$dest"
    fi
    
    echo "Linking $src -> $dest"
    ln -sf "$src" "$dest"
}

echo "Deploying dotfiles..."

deploy_config "$CONFIG_DIR/ghostty" "$HOME/.config/ghostty"
deploy_config "$CONFIG_DIR/hypr" "$HOME/.config/hypr"
deploy_config "$CONFIG_DIR/kitty" "$HOME/.config/kitty"
deploy_config "$CONFIG_DIR/nvim" "$HOME/.config/nvim"
deploy_config "$CONFIG_DIR/zsh" "$HOME/.config/zsh"
deploy_config "$CONFIG_DIR/rofi" "$HOME/.config/rofi"
deploy_config "$CONFIG_DIR/mako" "$HOME/.config/mako"
deploy_config "$CONFIG_DIR/wlogout" "$HOME/.config/wlogout"
deploy_config "$CONFIG_DIR/btop" "$HOME/.config/btop"
deploy_config "$CONFIG_DIR/dconf" "$HOME/.config/dconf"
deploy_config "$CONFIG_DIR/gtk-3.0" "$HOME/.config/gtk-3.0"
deploy_config "$CONFIG_DIR/gtk-4.0" "$HOME/.config/gtk-4.0"
deploy_config "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
deploy_config "$CONFIG_DIR/git" "$HOME/.config/git"
deploy_config "$CONFIG_DIR/quickshell" "$HOME/.config/quickshell"

deploy_config "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
deploy_config "$CONFIG_DIR/git/.gitconfig" "$HOME/.gitconfig"

if [ -d "$CONFIG_DIR/systemd" ]; then
    echo "Installing systemd user services..."
    USER_SYSTEMD="$HOME/.config/systemd/user"
    mkdir -p "$USER_SYSTEMD"
    for service in "$CONFIG_DIR/systemd"/*.service; do
        if [ -f "$service" ]; then
            svc_name=$(basename "$service")
            echo "  Linking $service -> $USER_SYSTEMD/$svc_name"
            ln -sf "$service" "$USER_SYSTEMD/$svc_name"
        fi
    done
    systemctl --user daemon-reload
fi

echo ""
echo "=== Deployed successfully! ==="
echo "Backup saved to: $BACKUP_DIR"
