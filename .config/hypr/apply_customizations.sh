#!/bin/bash

# Hyprland Dotfiles Customization Summary
# Shows the current customization status

echo "Hyprland Dotfiles Customization Status"
echo "======================================"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Current Configuration:${NC}"
echo "✓ AI features: ENABLED (restored)"
echo "✓ Network download speed: ADDED (fixed width display)"
echo "✓ GPU usage monitoring: ADDED (supports NVIDIA/AMD/Intel)"
echo "✓ Original navbar layout: RESTORED"
echo "✓ Swap monitoring: REMOVED"
echo "✓ Media controls: SIMPLIFIED (button only, no text)"

echo ""
echo -e "${BLUE}Enhanced Features:${NC}"
echo "• Fixed-width network speed display (prevents bar jumping)"
echo "• Monospace font for consistent network speed formatting"
echo "• Removed swap monitoring (Memory, CPU, Network, GPU only)"
echo "• Simplified media controls (control button without descriptions)"

echo ""
echo -e "${BLUE}Files Modified:${NC}"
echo "• ~/.config/hypr/hyprland/scripts/ai/ - AI scripts restored"
echo "• ~/.config/hypr/hyprland/keybinds.conf - AI keybind restored"
echo "• ~/.config/quickshell/ii/services/ResourceUsage.qml - Enhanced monitoring"
echo "• ~/.config/quickshell/ii/modules/bar/Resources.qml - Added network/GPU"
echo "• ~/.config/quickshell/ii/modules/bar/NetworkDownloadResource.qml - New component"
echo "• ~/.config/quickshell/ii/modules/common/Config.qml - AI re-enabled"

echo ""
echo -e "${YELLOW}To apply changes:${NC}"
echo "  pkill quickshell"
echo "  quickshell --config ~/.config/quickshell/ii"

echo ""
echo -e "${YELLOW}Test monitoring:${NC}"
echo "  ~/.config/hypr/test_monitoring.sh"

echo ""
echo -e "${GREEN}Customization Summary:${NC}"
echo "• Original functionality maintained"
echo "• Network download speed monitoring added"
echo "• GPU usage monitoring added (auto-detects hardware)"
echo "• AI features fully restored and working"