#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
FONT_DIR="$HOME/.local/share/fonts"

echo "Creating backup at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r "$CONFIG_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true

echo "Installing packages..."
sudo pacman -S --needed hyprland quickshell kitty fuzzel hyprpaper hyprlock hypridle starship flameshot wf-recorder btop dolphin cava qt5ct qt6ct kvantum

echo "Installing configuration files..."
cp -r "$REPO_DIR/.config"/* "$CONFIG_DIR/"

echo "Making scripts executable..."
chmod +x "$CONFIG_DIR/hypr/scripts"/* 2>/dev/null || true

echo "Installing fonts..."
mkdir -p "$FONT_DIR"
unzip -q "$REPO_DIR/fonts/JetBrainsMono.zip" -d "$FONT_DIR"
fc-cache -fv

echo "Installing wallpapers..."
mkdir -p "$WALLPAPER_DIR"
cp "$REPO_DIR/wallpapers"/* "$WALLPAPER_DIR/"

echo "Creating required directories..."
mkdir -p "$CONFIG_DIR/quickshell/ii/data/user"
mkdir -p "$HOME/Pictures/Screenshots"

echo "Setup complete!"
echo "Backup saved at: $BACKUP_DIR"
echo "Log out and select Hyprland to start using your new rice!"
