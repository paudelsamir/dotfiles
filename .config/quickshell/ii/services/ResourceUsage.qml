pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, CPU, Network download speed, and GPU usage.
 */
Singleton {
	property double memoryTotal: 1
	property double memoryFree: 1
	property double memoryUsed: memoryTotal - memoryFree
    property double memoryUsedPercentage: memoryUsed / memoryTotal
    property double swapTotal: 1
	property double swapFree: 1
	property double swapUsed: swapTotal - swapFree
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property double cpuUsage: 0
    property var previousCpuStats
    
    // Network monitoring (download only)
    property double networkDownSpeed: 0  // bytes per second
    property var previousNetworkStats
    property string primaryNetworkInterface: ""
    
    // GPU monitoring
    property double gpuUsage: -1  // -1 means not available, 0-1 means percentage
    
    Component.onCompleted: {
        // Start GPU monitoring immediately
        gpuUpdateTimer.start()
        gpuCheckProcess.running = true
    }

    function formatNetworkSpeed(bytesPerSecond) {
        // Format with padding: 1 digit = "01", 2 digits = "12", 3 digits = "123"
        const padNumber = (num) => {
            const rounded = num.toFixed(0);
            return rounded.length === 1 ? '0' + rounded : rounded;
        };
        
        if (bytesPerSecond < 1024) return padNumber(bytesPerSecond) + "B/s";
        if (bytesPerSecond < 1024 * 1024) return padNumber(bytesPerSecond / 1024) + "K/s";
        if (bytesPerSecond < 1024 * 1024 * 1024) return padNumber(bytesPerSecond / (1024 * 1024)) + "M/s";
        return padNumber(bytesPerSecond / (1024 * 1024 * 1024)) + "G/s";
    }

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            // Reload files
            fileMeminfo.reload()
            fileStat.reload()
            fileNetDev.reload()

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            // Parse CPU usage
            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            // Parse network usage (download only)
            const textNetDev = fileNetDev.text()
            const lines = textNetDev.split('\n')
            let primaryInterface = ""
            let maxBytes = 0
            
            // Find the most active network interface (excluding loopback)
            for (let i = 2; i < lines.length; i++) {
                const line = lines[i].trim()
                if (!line) continue
                
                const parts = line.split(/\s+/)
                const interfaceName = parts[0].replace(':', '')
                
                if (interfaceName === 'lo') continue // Skip loopback
                
                const rxBytes = Number(parts[1])
                const totalBytes = rxBytes
                
                if (totalBytes > maxBytes) {
                    maxBytes = totalBytes
                    primaryInterface = interfaceName
                    primaryNetworkInterface = interfaceName
                    
                    if (previousNetworkStats && previousNetworkStats.interface === interfaceName) {
                        const timeDiff = (Date.now() - previousNetworkStats.timestamp) / 1000
                        if (timeDiff > 0) {
                            const rxDiff = rxBytes - previousNetworkStats.rxBytes
                            networkDownSpeed = Math.max(0, rxDiff / timeDiff)
                        }
                    }
                    
                    previousNetworkStats = {
                        interface: interfaceName,
                        rxBytes: rxBytes,
                        timestamp: Date.now()
                    }
                }
            }

            // Update GPU usage periodically (less frequently than other metrics)
            if (!gpuUpdateTimer.running) {
                gpuUpdateTimer.start()
            }
            
            interval = Config.options?.resources?.updateInterval ?? 3000
        }
	}

    Timer {
        id: gpuUpdateTimer
        interval: 3000 // Update GPU every 3 seconds
        running: false
        repeat: true
        onTriggered: {
            // Try different GPU monitoring methods
            gpuCheckProcess.running = true
        }
    }

    Process {
        id: gpuCheckProcess
        command: ["bash", "-c", `
            # Try nvidia-smi first (most reliable)
            if command -v nvidia-smi >/dev/null 2>&1; then
                USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
                if [[ "$USAGE" =~ ^[0-9]+$ ]]; then
                    echo "$USAGE"
                    exit 0
                fi
            fi
            
            # Try AMD GPU with sysfs
            for file in /sys/class/drm/card*/device/gpu_busy_percent; do
                if [ -f "$file" ]; then
                    cat "$file" 2>/dev/null && exit 0
                fi
            done
            
            # Try Intel GPU
            if [ -f /sys/class/drm/card0/engine/rcs0/busy ]; then
                awk '{printf "%.0f", ($1/1000000)*100}' /sys/class/drm/card0/engine/rcs0/busy 2>/dev/null && exit 0
            fi
            
            # Fallback - no GPU detected
            echo "-1"
        `]
        stdout: SplitParser {
            onRead: data => {
                if (data.length > 0) {
                    const value = Number(data.trim())
                    if (value >= 0) {
                        gpuUsage = value / 100.0
                    } else {
                        gpuUsage = -1 // GPU monitoring not available
                    }
                }
            }
        }
    }

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }
    FileView { id: fileNetDev; path: "/proc/net/dev" }
}
