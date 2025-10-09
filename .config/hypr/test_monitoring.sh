#!/bin/bash

echo "Testing Network and GPU Monitoring Setup"
echo "========================================"

echo "Monitoring components enabled:"
echo "✓ Memory usage"
echo "✓ CPU usage" 
echo "✓ Network download speed (fixed width)"
echo "✓ GPU usage"
echo "✗ Swap monitoring (removed)"

echo ""
echo "Network interface detection:"
cat /proc/net/dev | grep -v "lo:" | grep ":" | head -3 | while read line; do
    interface=$(echo "$line" | cut -d: -f1 | tr -d ' ')
    rx_bytes=$(echo "$line" | awk '{print $2}')
    echo "  $interface: $rx_bytes bytes received"
done

echo ""
echo "GPU detection:"

# Test NVIDIA
if command -v nvidia-smi >/dev/null 2>&1; then
    echo "✓ NVIDIA GPU detected"
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | sed 's/^/  Current usage: /' | sed 's/$/%/'
else
    echo "✗ NVIDIA GPU not found"
fi

# Test Intel GPU
if [ -f /sys/class/drm/card0/engine/rcs0/busy ]; then
    echo "✓ Intel GPU sysfs found"
    awk '{printf "  Current usage: %.0f%%\\n", ($1/1000000)*100}' /sys/class/drm/card0/engine/rcs0/busy 2>/dev/null || echo "  Unable to read usage"
else
    echo "✗ Intel GPU sysfs not found"
fi

# Test AMD GPU
if find /sys/class/drm/card*/device -name gpu_busy_percent 2>/dev/null | head -1; then
    echo "✓ AMD GPU sysfs found"
    find /sys/class/drm/card*/device -name gpu_busy_percent 2>/dev/null | head -1 | xargs cat 2>/dev/null | sed 's/^/  Current usage: /' | sed 's/$/%%/'
else
    echo "✗ AMD GPU sysfs not found"
fi

echo ""
echo "Media controls:"
echo "✓ Simplified to just control button (no text descriptions)"

echo ""
echo "To restart quickshell with changes:"
echo "  pkill quickshell && quickshell --config ~/.config/quickshell/ii"