Based on [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) with extensive productivity-focused customizations.

## Key Customizations Made
- Removed all AI widgets from sidebars
- Cleaned up AI-related components from navigation
- **GPU Usage**: Real-time GPU monitoring in status bar
- **Network Speed**: Live upload/download speeds
- **Pomodoro Timer**: 25/5/15 minute cycles
- **Custom Timer**: Set any duration with presets
- **Stopwatch**: Basic time tracking
- **Audio Alerts**: Multiple notification sounds
- **Visual Progress**: Circular progress indicators
- **Todo System**: Daily task tracking with persistence
- **Monthly Goals**: Long-term goal tracking (monthly scope)
- **Temperature Control for night light**: Adjustable color temperature (1000K-6500K)
- **Screenshots**: `Super + Shift + S` (Flameshot GUI)
- **Screen Recording**: `Super + Shift + R` (wf-recorder)
- **Auto-save**: Screenshots to `~/Pictures/Screenshots/`

## Keybindings
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

## Data Persistence
- **Todo items**: Stored in `~/.config/quickshell/ii/data/user/todo.json`
- **Monthly goals**: Stored in `~/.config/quickshell/ii/data/user/monthly-goals.json`
- **Auto-backup**: File system watches for changes
- **Error handling**: Graceful fallbacks for corrupted data


## Troubleshooting

### Quickshell disappeared/not starting (FIXED)
1. **Quick fix**: Press `Super + Shift + Q` (kills old + starts new)
2. **Check if running**: `ps aux | grep quickshell`
3. **Manual start**: `cd ~/.config/quickshell && quickshell -c ii &`
4. **Logs**: Check `/tmp/quickshell.log` for errors

### Startup Method (CURRENT)
- **Primary**: Hyprland starts Quickshell automatically on boot
- **Backup**: Secondary check starts it if main method fails
- **Restart**: Keybinding kills all instances before starting new one
- **Reliable**: No more systemd complications, simple process management