pragma Singleton

import QtQuick
import Quickshell

/**
 * Shared state for the popup stopwatch
 */
QtObject {
    id: root
    
    // Stopwatch properties
    property real elapsedTime: 0  // in centiseconds (like TimerService.stopwatchTime)
    property bool isRunning: false
    
    // Badge position: "top-left", "top-right", "bottom-left", "bottom-right"
    property string badgePosition: "bottom-right"
    
    // Eye care properties
    property bool isEyeRestTime: false  // Whether it's currently rest time (1 min every 25 min)
    property int cycleCount: 0  // How many 25-minute cycles completed
    
    function formatTime(centiseconds) {
        let totalSeconds = Math.floor(centiseconds) / 100
        let h = Math.floor(totalSeconds / 3600)
        let m = Math.floor((totalSeconds % 3600) / 60)
        let s = Math.floor(totalSeconds % 60)
        
        if (h > 0) {
            return h + ":" + 
                   (m < 10 ? "0" + m : m) + ":" + 
                   (s < 10 ? "0" + s : s)
        }
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
    }
    
    function playNotificationSound() {
        try {
            // Simple beep sound
            Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/message.oga"])
        } catch(e) {
            // Silent fail
        }
    }
}
