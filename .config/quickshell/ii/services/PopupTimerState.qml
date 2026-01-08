pragma Singleton

import QtQuick
import Quickshell

/**
 * Shared state for the popup timer
 */
QtObject {
    id: root
    
    // Timer properties
    property int hours: 0
    property int minutes: 5
    property int totalSeconds: 0
    property int remainingSeconds: 0
    property bool isRunning: false
    property bool isFinished: false
    property bool isPaused: false
    property bool shouldResetOnReload: false  // Keep state on Hyprland reload
    
    // Badge position: "top-left", "top-right", "bottom-left", "bottom-right"
    property string badgePosition: "top-left"
    
    function formatTime(totalSec) {
        let h = Math.floor(totalSec / 3600)
        let m = Math.floor((totalSec % 3600) / 60)
        let s = totalSec % 60
        
        if (h > 0) {
            return h + ":" + 
                   (m < 10 ? "0" + m : m) + ":" + 
                   (s < 10 ? "0" + s : s)
        }
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
    }
    
    function formatTimeHuman(totalSec) {
        let h = Math.floor(totalSec / 3600)
        let m = Math.floor((totalSec % 3600) / 60)
        let s = totalSec % 60
        
        if (h > 0 && m > 0) {
            return h + "h " + m + "m"
        } else if (h > 0) {
            return h + "h"
        } else if (m > 0) {
            return m + "m " + s + "s"
        }
        return s + "s"
    }
    
    function playAlertSound() {
        try {
            Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"])
        } catch(e) {
            // Silent fail
        }
    }
}

