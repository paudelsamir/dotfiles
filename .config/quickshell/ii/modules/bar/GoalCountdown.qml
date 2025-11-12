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
    
    // Persistent storage for countdown date and events
    Settings {
        id: countdownSettings
        property string targetDate: "2025-12-31"
        property string lastCheckedDate: ""
        property string eventsJson: "[]" // JSON array of events: [{name, date, category}]
    }
    
    // Current target date (main goal)
    property string targetDate: countdownSettings.targetDate
    
    // Parse events from JSON
    property var events: {
        try {
            return JSON.parse(countdownSettings.eventsJson);
        } catch(e) {
            return [];
        }
    }
    
    // Get upcoming events sorted by date
    function getUpcomingEvents() {
        var today = new Date();
        today.setHours(0, 0, 0, 0);
        
        var upcoming = events.filter(function(event) {
            var eventDate = new Date(event.date);
            return eventDate >= today;
        }).sort(function(a, b) {
            return new Date(a.date) - new Date(b.date);
        });
        
        return upcoming;
    }
    
    // Calculate days remaining with improved accuracy
    property int daysLeft: {
        // Get dates and normalize to UTC midnight
        var today = new Date()
        today = new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()))
        
        var target = new Date(targetDate)
        target = new Date(Date.UTC(target.getFullYear(), target.getMonth(), target.getDate()))
        
        // Calculate difference in days
        var timeDiff = target.getTime() - today.getTime()
        var daysDiff = Math.floor(timeDiff / (1000 * 60 * 60 * 24))
        
        return Math.max(0, daysDiff) // Never show negative days
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
        // Update GlobalStates to match our stored values
        GlobalStates.countdownTargetDate = countdownSettings.targetDate
        GlobalStates.countdownEventsJson = countdownSettings.eventsJson
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
        function onCountdownEventsJsonChanged() {
            if (GlobalStates.countdownEventsJson !== countdownSettings.eventsJson) {
                countdownSettings.eventsJson = GlobalStates.countdownEventsJson
            }
        }
    }
    
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    MouseArea {
        id: mouseArea
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
        spacing: 4

        // Clock icon
        MaterialSymbol {
            font.weight: Font.Normal
            fill: 0
            text: "schedule"
            iconSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
        }

        // Days text  
        StyledText {
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
            text: root.daysLeft > 0 ? root.daysLeft + "d" : "0d"
        }
    }

    // Hover tooltip showing all upcoming events
    CountdownTooltip {
        hoverTarget: mouseArea
        targetDate: root.targetDate
        daysLeft: root.daysLeft
        events: root.getUpcomingEvents()
    }
}