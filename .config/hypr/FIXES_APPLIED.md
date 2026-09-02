# Hyprland Crash Fixes Applied

## Issue 1: Division by Zero in CReservedArea
**Symptom**: Hyprland crashes with SIGABRT during monitor layer arrangement
**Fix**: Updated PAM configuration for hyprlock
- File: `/etc/pam.d/hyprlock`
- Added complete PAM sections (auth, account, session)

## Issue 2: XWayland Scaling / Zoom Issues
**Symptom**: Everything appears zoomed in, especially when locking
**Fixes Applied**:
1. Monitor resolution: Changed from `preferred` to explicit `1920x1080@60` with `1.5x` scaling
2. XWayland: Added `force_zero_scaling = true` to prevent X11 scaling issues
3. Quickshell: Added zoom reset on screen lock

## Issue 3: DPMS Crash (AMD GPU)
**Symptom**: System crashes when DPMS turns off displays
**Fix**: Disabled DPMS off in hypridle.conf
- File: `~/.config/hypr/hypridle.conf`
- Commented out: `on-timeout = hyprctl dispatch dpms off`

## Issue 4: Missing Components
**Installed**:
- hyprpolkitagent (authentication agent)
- mako (notification daemon)  
- hyprlauncher (launcher - disabled, using fuzzel instead)

## Issue 5: Authentication / PAM
**Symptom**: PAM errors and crashes during locking
**Fixes**:
- Installed proper PAM configuration
- All auth/account/session sections properly configured

## How to Apply Fixes
1. Changes already applied to config files
2. Run: `hyprctl reload` to reload without restarting
3. For full application: Log out and back in

## Testing
- Lock/unlock screen: `Super + Escape`
- Check zoom: Should be normal size
- Monitor crashes: All active listeners disabled DPMS

## Files Modified
- `~/.config/hypr/hyprland/general.conf` - Monitor resolution & xwayland
- `~/.config/hypr/hypridle.conf` - Disabled DPMS
- `~/.config/quickshell/ii/GlobalStates.qml` - Reset zoom on lock
- `/etc/pam.d/hyprlock` - Complete PAM config
- `~/.config/hypr/custom/execs.conf` - Added services
- `~/.config/hypr/custom/env.conf` - Added XDG variables
