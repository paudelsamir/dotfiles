# My Personal Dotfiles

My Hyprland setup based on end-4/dots-hyprland with my productivity tweaks.

## What This Is
Private backup of my Linux desktop config. When my laptop dies or I need to set up on a new machine, this gets me back to my setup quickly.

## Key Stuff I Added
- GPU monitoring in status bar
- Network speeds display  
- Pomodoro timer (25/5/15 min cycles)
- Todo system that persists
- Monthly goals tracker
- Better keybinds for screenshots/recording

## 🎮 Keybindings

### System Controls
- `Super + Q` - Close window
- `Super + M` - Exit Hyprland  
- `Super + E` - File manager (Dolphin)
- `Super + R` - VS Code
- `Super + V` - Toggle clipboard
- `Super + Space` - App launcher
- `Super + Tab` - Overview/window switcher

### Screenshots & Recording
- `Super + Shift + S` - Screenshot (Flameshot)
- `Super + Shift + R` - Screen recording toggle

### Workspaces
- `Super + [1-0]` - Switch to workspace
- `Super + Shift + [1-0]` - Move window to workspace  
- `Super + Mouse_wheel` - Cycle workspaces

### Productivity
- `N` - Quick add todo/goal (when in sidebar)
- `PageUp/PageDown` - Switch tabs in widgets
- `Esc` - Cancel dialogs

## 🎨 Interface Layout

### Left Sidebar
- Todo System (daily tasks)
- Monthly Goals (long-term tracking)
- Tabbed interface with keyboard navigation
- Timer/Pomodoro controls
- Stopwatch functionality

### Right Sidebar  
- System notifications
- Calendar (standard + optional Nepali)
- Audio output controls

## 💾 Data Persistence
- **Todo items**: `~/.config/quickshell/ii/data/user/todo.json`
- **Monthly goals**: `~/.config/quickshell/ii/data/user/monthly-goals.json`
- **Auto-backup**: File system watches for changes
- **Error handling**: Graceful fallbacks for corrupted data

## 🚀 Installation

### Prerequisites
Make sure you have these packages installed:
```bash
# Core components
hyprland waybar quickshell

# Applications
dolphin code flameshot wf-recorder clipse

# Optional but recommended
btop cava fuzzel kitty
```

### Installation Steps

1. **Clone the repository**:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Backup your current config** (important!):
```bash
cp -r ~/.config ~/.config.backup
```

3. **Install the configuration**:
```bash
chmod +x install.sh
./install.sh
```

4. **Log out and select Hyprland** in your display manager

### Manual Installation
If you prefer to install manually:

```bash
# Core configs
cp -r .config/hypr ~/.config/
cp -r .config/quickshell ~/.config/
cp -r .config/waybar ~/.config/

# Terminal & Tools  
cp -r .config/kitty ~/.config/
cp -r .config/btop ~/.config/
cp -r .config/fuzzel ~/.config/

# Optional configs
cp -r .config/cava ~/.config/
cp .config/starship.toml ~/.config/
```

## 🛠️ Troubleshooting

### Quickshell Issues
1. **Quick fix**: Press `Super + Shift + Q` (kills old + starts new)
2. **Check if running**: `ps aux | grep quickshell`
3. **Manual start**: `cd ~/.config/quickshell && quickshell -c ii &`
4. **Logs**: Check `/tmp/quickshell.log` for errors

### Common Issues
- **Missing dependencies**: Install packages listed in prerequisites
- **Fonts not working**: Install JetBrains Mono font
- **Scripts not executable**: Run `chmod +x ~/.config/hypr/scripts/*`

## 📁 Directory Structure
```
├── .config/
│   ├── hypr/                 # Hyprland configuration
│   │   ├── hyprland.conf    # Main config file
│   │   ├── custom/          # Your customizations
│   │   └── scripts/         # Helper scripts
│   ├── quickshell/          # Quickshell (status bar/widgets)
│   │   └── ii/              # Custom theme
│   ├── kitty/               # Terminal configuration
│   ├── fuzzel/              # App launcher
│   ├── btop/                # System monitor themes
│   └── cava/                # Audio visualizer
├── fonts/                   # Required fonts
├── wallpapers/             # Background images
└── scripts/                # Installation helpers
```

## 🎨 Customization

### Changing Colors
Edit these files to customize your theme:
- `.config/hypr/hyprland/colors.conf` - Window/border colors
- `.config/quickshell/ii/` - Widget colors and styling

### Adding Keybindings  
Add custom keybinds in:
- `.config/hypr/custom/keybinds.conf`

### Modifying Widgets
Widget configurations are in:
- `.config/quickshell/ii/modules/`

## 🙏 Credits & Attribution

- **Base Configuration**: [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- **Hyprland**: [hyprwm/Hyprland](https://github.com/hyprwm/Hyprland)  
- **Quickshell**: [outfoxxed/quickshell](https://github.com/outfoxxed/quickshell)

## 📄 License

This configuration is provided as-is. Please respect the licenses of the original projects this builds upon.

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

---
⭐ **If you found this helpful, consider giving it a star!**