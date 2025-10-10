import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts
import Qt.labs.settings 1.0
import Quickshell

Item {
    id: root
    
    // Persistent storage for countdown date
    Settings {
        id: countdownSettings
        property string targetDate: "2025-12-31"
        property string lastCheckedDate: ""
    }
    
    // Current target date
    property string targetDate: countdownSettings.targetDate
    
    // Calculate days remaining
    property int daysLeft: {
        var today = new Date()
        today.setHours(0, 0, 0, 0) // Normalize to start of day
        
        var target = new Date(targetDate)
        target.setHours(0, 0, 0, 0) // Normalize to start of day
        
        var diff = Math.ceil((target.getTime() - today.getTime()) / (1000 * 60 * 60 * 24))
        return Math.max(0, diff) // Never show negative days
    }
    
    // Daily update checker
    Timer {
        id: dailyUpdateTimer
        interval: 60000 // Check every minute
        running: true
        repeat: true
        
        onTriggered: {
            checkForNewDay();
        }
    }
    
    // Check if a new day has started
    function checkForNewDay() {
        var today = new Date()
        var todayString = today.toDateString()
        
        if (countdownSettings.lastCheckedDate !== todayString) {
            countdownSettings.lastCheckedDate = todayString
            // Force recalculation by triggering property change
            root.targetDateChanged()
        }
    }
    
    // Initialize on component creation
    Component.onCompleted: {
        checkForNewDay()
        // Update GlobalStates to match our stored value
        GlobalStates.countdownTargetDate = countdownSettings.targetDate
    }
    
    // Listen for changes from popup and save them
    Connections {
        target: GlobalStates
        function onCountdownTargetDateChanged() {
            if (GlobalStates.countdownTargetDate !== countdownSettings.targetDate) {
                countdownSettings.targetDate = GlobalStates.countdownTargetDate
                root.targetDate = GlobalStates.countdownTargetDate
            }
        }
    }
    
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onPressed: {
            // Toggle the countdown popup (similar to media controls)
            GlobalStates.countdownPopupOpen = !GlobalStates.countdownPopupOpen;
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 6

        // Clock icon
        StyledText {
            font.family: "Material Symbols Rounded"
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
            text: "schedule"
        }

        // Days text  
        StyledText {
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: root.daysLeft > 0 ? root.daysLeft + "d" : "Done"
        }
    }

    // Click feedback effect
    Rectangle {
        anchors.fill: parent
        radius: 4
        color: parent.pressed ? "rgba(255,255,255,0.2)" : 
               parent.containsMouse ? "rgba(255,255,255,0.1)" : "transparent"
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}