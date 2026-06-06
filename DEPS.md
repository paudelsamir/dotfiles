# niri-setup

Personal Niri + Quickshell desktop configuration.

## Structure

```
├── setup.sh            # Install script (copies everything into place)
├── shell/              # Quickshell QML desktop shell (based on iNiR, customized)
│   ├── shell.qml       # Entry point — runs via: quickshell shell.qml
│   ├── modules/        # Bar, sidebars, overlays, settings
│   ├── services/       # Backend singletons (audio, network, notifications, etc.)
│   ├── scripts/        # Launcher (`inir`), helpers
│   ├── assets/         # Icons, desktop entries
│   ├── defaults/       # Default config.json
│   ├── dots/           # Dotfile templates (reference)
│   └── version.json    # Install manifest
├── niri/               # Niri compositor config
│   ├── config.kdl
│   └── config.d/       # Modular config files
├── foot/               # Foot terminal
├── kitty/              # Kitty terminal (alternative)
├── fuzzel/             # Application launcher
├── gtk-3.0/            # GTK theme settings
├── matugen/            # Material You color templates
├── fish/               # Fish shell config
├── starship.toml       # Shell prompt
└── mimeapps.list       # Default application associations
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `niri` | Wayland compositor (window manager) |
| `quickshell` | QML shell runtime — runs `shell.qml` |
| `foot` | Primary terminal emulator |
| `kitty` | Alternative terminal emulator |
| `fuzzel` | Application launcher |
| `fish` | Shell (default for foot/kitty) |
| `starship` | Prompt theme |
| `qt6-wayland` | Qt Wayland support for Quickshell |
| `qt6-svg` | SVG icon support |
| `qt6-imageformats` | Additional image format support |
| `python` | Required by color generation scripts |
| `matugen` | Material You color generation (optional, for theming) |

### Fonts

| Font | Used by |
|------|---------|
| `ttf-jetbrains-mono-nerd` | Terminal, fuzzel, UI |
| `ttf-font-awesome` | Icon support |
| `noto-fonts` | Fallback/CJK |

## Quick Start

```sh
# 1. Install dependencies
sudo pacman -S niri quickshell foot fuzzel fish starship \
               qt6-wayland qt6-svg qt6-imageformats

# 2. Run setup
chmod +x setup.sh
./setup.sh

# 3. Start niri and the shell
niri-session
# or if already in a TTY:
inir run
```

## Manual Install

```sh
# Shell config
cp -r shell/* ~/.config/quickshell/inir/

# Niri config
cp niri/config.kdl ~/.config/niri/
cp niri/config.d/*.kdl ~/.config/niri/config.d/

# Other configs
cp foot/* ~/.config/foot/
cp fuzzel/* ~/.config/fuzzel/
cp starship.toml ~/.config/
# etc.
```

## Updating

Pull changes from GitHub, then re-run `./setup.sh`. It's idempotent — safe to run repeatedly.
