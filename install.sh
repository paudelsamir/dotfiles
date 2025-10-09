#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    print_warning "This script is designed for Arch-based systems. You may need to adapt package installation commands."
fi

print_status "Starting dotfiles installation..."

# Create backup of existing configs
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
if [ -d "$HOME/.config" ]; then
    print_status "Creating backup at $BACKUP_DIR"
    cp -r "$HOME/.config" "$BACKUP_DIR"
    print_success "Backup created successfully"
fi

# Check for required packages
print_status "Checking for required packages..."

REQUIRED_PACKAGES=(
    "hyprland"
    "quickshell" 
    "dolphin"
    "code"
    "flameshot"
    "wf-recorder"
    "clipse"
    "kitty"
    "fuzzel"
    "btop"
)

MISSING_PACKAGES=()

for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! pacman -Qi "$package" &> /dev/null; then
        MISSING_PACKAGES+=("$package")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -ne 0 ]; then
    print_warning "Missing packages: ${MISSING_PACKAGES[*]}"
    read -p "Would you like to install missing packages? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing missing packages..."
        sudo pacman -S --needed "${MISSING_PACKAGES[@]}"
    else
        print_warning "Some features may not work without the required packages."
    fi
fi

# Install font if not present
print_status "Checking for JetBrains Mono font..."
if ! fc-list | grep -i "jetbrains" &> /dev/null; then
    print_warning "JetBrains Mono font not found"
    if [ -d "fonts" ]; then
        print_status "Installing fonts from local directory..."
        mkdir -p "$HOME/.local/share/fonts"
        cp -r fonts/* "$HOME/.local/share/fonts/"
        fc-cache -fv
        print_success "Fonts installed successfully"
    else
        print_warning "No local fonts directory found. Please install JetBrains Mono font manually."
    fi
fi

# Install configurations
print_status "Installing configuration files..."

# Core configs
mkdir -p "$HOME/.config"
cp -r .config/* "$HOME/.config/"

# Make scripts executable
if [ -d "$HOME/.config/hypr/scripts" ]; then
    chmod +x "$HOME/.config/hypr/scripts"/*
    print_success "Made Hypr scripts executable"
fi

# Create necessary directories
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/.config/quickshell/ii/data/user"

# Create template files for user-specific configs
if [ ! -f "$HOME/.config/hypr/monitors.conf" ]; then
    echo "# Monitor configuration - customize this for your setup" > "$HOME/.config/hypr/monitors.conf"
    echo "monitor=,preferred,auto,1" >> "$HOME/.config/hypr/monitors.conf"
fi

if [ ! -f "$HOME/.config/hypr/workspaces.conf" ]; then
    echo "# Workspace configuration" > "$HOME/.config/hypr/workspaces.conf"
fi

print_success "Configuration files installed successfully"

# Install wallpapers if available
if [ -d "wallpapers" ] && [ "$(ls -A wallpapers 2>/dev/null)" ]; then
    print_status "Installing wallpapers..."
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp wallpapers/* "$HOME/Pictures/Wallpapers/"
    print_success "Wallpapers installed to ~/Pictures/Wallpapers/"
fi

print_success "Installation complete!"
echo
print_status "Next steps:"
echo "1. Log out of your current session"
echo "2. Select 'Hyprland' in your display manager"
echo "3. Log in and enjoy your new setup!"
echo
print_warning "If you encounter issues:"
echo "- Press Super + Shift + Q to restart Quickshell"
echo "- Check the troubleshooting section in README.md"
echo "- Your old config is backed up at: $BACKUP_DIR"