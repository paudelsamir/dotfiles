import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    property int hours: 1
    property int minutes: 0
    property int totalSeconds: 0
    property int remainingSeconds: 0
    property bool isRunning: false
    property bool isFinished: false
    property bool showSettings: false
    property bool isPaused: false
    property bool useTimeOfDay: false
    property int targetHour: 21
    property int targetMinute: 0
    
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    function getSecondsUntilTime() {
        let now = new Date()
        let currentSeconds = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()
        let targetSeconds = targetHour * 3600 + targetMinute * 60
        
        let secondsLeft = targetSeconds - currentSeconds
        
        // If target time is in the past today, set for tomorrow
        if (secondsLeft <= 0) {
            secondsLeft += 86400 // 24 hours in seconds
        }
        
        return secondsLeft
    }
    
    function startTimer() {
        if (useTimeOfDay) {
            totalSeconds = getSecondsUntilTime()
            remainingSeconds = totalSeconds
        } else {
            totalSeconds = hours * 3600 + minutes * 60
            remainingSeconds = totalSeconds
        }
        
        if (remainingSeconds > 0) {
            isRunning = true
            isFinished = false
            countdownTimer.start()
            // Sync to PopupTimerState
            PopupTimerState.hours = useTimeOfDay ? 0 : hours
            PopupTimerState.minutes = useTimeOfDay ? 0 : minutes
            PopupTimerState.totalSeconds = totalSeconds
            PopupTimerState.remainingSeconds = remainingSeconds
            PopupTimerState.isRunning = true
            PopupTimerState.isFinished = false
        }
    }
    
    function pauseTimer() {
        isRunning = false
        countdownTimer.stop()
    }
    
    function resetTimer() {
        isRunning = false
        isFinished = false
        countdownTimer.stop()
        remainingSeconds = 0
        showSettings = false
        isPaused = false
        // Reset PopupTimerState as well
        PopupTimerState.isRunning = false
        PopupTimerState.isFinished = false
        PopupTimerState.remainingSeconds = 0
    }
    
    function formatTime(totalSec) {
        var h = Math.floor(totalSec / 3600)
        var m = Math.floor((totalSec % 3600) / 60)
        var s = totalSec % 60
        if (h > 0) {
            return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
        }
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
    }
    
    function playAlertSound() {
        Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"])
    }
    
    // Restore timer state on reload (don't reset)
    Component.onCompleted: {
        if (PopupTimerState.remainingSeconds > 0 && PopupTimerState.isRunning) {
            // Restore from PopupTimerState
            remainingSeconds = PopupTimerState.remainingSeconds
            isRunning = PopupTimerState.isRunning
            isFinished = PopupTimerState.isFinished
            isPaused = PopupTimerState.isPaused
            
            // Restart the timer if it was running
            if (isRunning && remainingSeconds > 0) {
                countdownTimer.start()
            }
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            remainingSeconds--
            // Sync with PopupTimerState
            PopupTimerState.remainingSeconds = remainingSeconds
            PopupTimerState.isRunning = root.isRunning
            
            if (remainingSeconds <= 0) {
                stop()
                isRunning = false
                isFinished = true
                playAlertSound()
                // Sync finish state
                PopupTimerState.isFinished = true
                PopupTimerState.isRunning = false
                PopupTimerState.playAlertSound()
            }
        }
    }
    
    Item {
        anchors {
            fill: parent
            topMargin: 8
            leftMargin: 16
            rightMargin: 16
        }
        
        // Timer display
        RowLayout {
            id: timerDisplay
            anchors {
                top: parent.top
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            
            StyledText {
                font.pixelSize: 40
                color: root.isFinished ? "#d34d3d" : Appearance.m3colors.m3onSurface
                text: {
                    if (root.isRunning || root.isFinished) {
                        let totalSeconds = root.remainingSeconds
                        let hours = Math.floor(totalSeconds / 3600).toString().padStart(2, '0')
                        let minutes = Math.floor((totalSeconds % 3600) / 60).toString().padStart(2, '0')
                        let seconds = Math.floor(totalSeconds % 60).toString().padStart(2, '0')
                        return hours === "00" ? `${minutes}:${seconds}` : `${hours}:${minutes}:${seconds}`
                    } else {
                        if (root.useTimeOfDay) {
                            return `Until ${root.targetHour.toString().padStart(2, '0')}:${root.targetMinute.toString().padStart(2, '0')}`
                        } else {
                            let hours = root.hours.toString().padStart(2, '0')
                            let minutes = root.minutes.toString().padStart(2, '0')
                            return hours === "00" ? `${minutes}:00` : `${hours}:${minutes}:00`
                        }
                    }
                }
            }
        }
        
        // Circular progress indicator
        CircularProgress {
            id: circularProgress
            anchors {
                top: timerDisplay.bottom
                topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            lineWidth: 5
            value: {
                let total = root.hours * 3600 + root.minutes * 60
                if (total === 0) return 0
                if (root.isRunning || root.isFinished) {
                    return 1 - (root.remainingSeconds / total)
                } else {
                    return 0
                }
            }
            implicitSize: 100
            enableAnimation: true
        }
        
        // Settings (hidden initially)
        Rectangle {
            id: settingsPanel
            anchors {
                top: circularProgress.bottom
                topMargin: -210
                left: parent.left
                right: parent.right
                bottom: controlButtons.top
                bottomMargin: 8
            }
            color: Appearance.colors.colLayer2
            radius: 6
            visible: root.showSettings && !root.isRunning
            
            ColumnLayout {
                id: settingsColumn
                anchors {
                    fill: parent
                    margins: 8
                }
                spacing: 12
                
                // Mode selector
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    RippleButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        buttonRadius: 4
                        colBackground: !root.useTimeOfDay ? Appearance.colors.colPrimary : Appearance.colors.colLayer1
                        colBackgroundHover: !root.useTimeOfDay ? Appearance.colors.colPrimaryHover : Appearance.colors.colLayer1Hover
                        colRipple: !root.useTimeOfDay ? Appearance.colors.colPrimaryActive : Appearance.colors.colLayer1Active
                        
                        contentItem: StyledText {
                            text: "Duration"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: !root.useTimeOfDay ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer1
                        }
                        
                        onClicked: root.useTimeOfDay = false
                    }
                    
                    RippleButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        buttonRadius: 4
                        colBackground: root.useTimeOfDay ? Appearance.colors.colPrimary : Appearance.colors.colLayer1
                        colBackgroundHover: root.useTimeOfDay ? Appearance.colors.colPrimaryHover : Appearance.colors.colLayer1Hover
                        colRipple: root.useTimeOfDay ? Appearance.colors.colPrimaryActive : Appearance.colors.colLayer1Active
                        
                        contentItem: StyledText {
                            text: "Time of Day"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: root.useTimeOfDay ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer1
                        }
                        
                        onClicked: root.useTimeOfDay = true
                    }
                }
                
                // Duration time input area (shown when useTimeOfDay is false)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 180 : 0
                    visible: !root.useTimeOfDay
                    clip: true
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        // Time input area
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 16
                            
                            // Hours spinbox
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                StyledText {
                                    text: "Hours"
                                    font.pixelSize: 9
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colSubtext
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "remove"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.hours > 0) root.hours--
                                    }
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: Appearance.colors.colLayer1
                                        radius: 6
                                        border.color: Appearance.colors.colPrimary
                                        border.width: 1.5
                                        
                                        TextInput {
                                            anchors {
                                                fill: parent
                                                margins: 8
                                            }
                                            text: root.hours.toString().padStart(2, '0')
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            font.family: "monospace"
                                            color: Appearance.colors.colPrimary
                                            horizontalAlignment: Text.AlignHCenter
                                            validator: IntValidator { bottom: 0; top: 23 }
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                if (text !== "" && !isNaN(text)) {
                                                    root.hours = Math.min(23, Math.max(0, parseInt(text)))
                                                }
                                            }
                                        }
                                    }
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "add"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.hours < 23) root.hours++
                                    }
                                }
                            }
                            
                            // Minutes spinbox
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                StyledText {
                                    text: "Minutes"
                                    font.pixelSize: 9
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colSubtext
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "remove"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.minutes > 0) root.minutes--
                                    }
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: Appearance.colors.colLayer1
                                        radius: 6
                                        border.color: Appearance.colors.colPrimary
                                        border.width: 1.5
                                        
                                        TextInput {
                                            anchors {
                                                fill: parent
                                                margins: 8
                                            }
                                            text: root.minutes.toString().padStart(2, '0')
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            font.family: "monospace"
                                            color: Appearance.colors.colPrimary
                                            horizontalAlignment: Text.AlignHCenter
                                            validator: IntValidator { bottom: 0; top: 59 }
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                if (text !== "" && !isNaN(text)) {
                                                    root.minutes = Math.min(59, Math.max(0, parseInt(text)))
                                                }
                                            }
                                        }
                                    }
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "add"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.minutes < 59) root.minutes++
                                    }
                                }
                            }
                        }
                        
                        // Quick presets
                        GridLayout {
                            columns: 4
                            columnSpacing: 4
                            rowSpacing: 4
                            Layout.fillWidth: true
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "5m"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.hours = 0; root.minutes = 5 }
                            }
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "15m"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.hours = 0; root.minutes = 15 }
                            }
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "30m"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.hours = 0; root.minutes = 30 }
                            }
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "1h"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.hours = 1; root.minutes = 0 }
                            }
                        }
                    }
                }
                
                // Time of Day input (shown when useTimeOfDay is true)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 120 : 0
                    visible: root.useTimeOfDay
                    clip: true
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            // Target Hour
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                StyledText {
                                    text: "Hour"
                                    font.pixelSize: 9
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colSubtext
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "remove"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.targetHour > 0) root.targetHour--
                                    }
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: Appearance.colors.colLayer1
                                        radius: 6
                                        border.color: Appearance.colors.colPrimary
                                        border.width: 1.5
                                        
                                        TextInput {
                                            anchors {
                                                fill: parent
                                                margins: 8
                                            }
                                            text: root.targetHour.toString().padStart(2, '0')
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            font.family: "monospace"
                                            color: Appearance.colors.colPrimary
                                            horizontalAlignment: Text.AlignHCenter
                                            validator: IntValidator { bottom: 0; top: 23 }
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                if (text !== "" && !isNaN(text)) {
                                                    root.targetHour = Math.min(23, Math.max(0, parseInt(text)))
                                                }
                                            }
                                        }
                                    }
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "add"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.targetHour < 23) root.targetHour++
                                    }
                                }
                            }
                            
                            // Target Minute
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                StyledText {
                                    text: "Minute"
                                    font.pixelSize: 9
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colSubtext
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "remove"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.targetMinute > 0) root.targetMinute--
                                    }
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: Appearance.colors.colLayer1
                                        radius: 6
                                        border.color: Appearance.colors.colPrimary
                                        border.width: 1.5
                                        
                                        TextInput {
                                            anchors {
                                                fill: parent
                                                margins: 8
                                            }
                                            text: root.targetMinute.toString().padStart(2, '0')
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            font.family: "monospace"
                                            color: Appearance.colors.colPrimary
                                            horizontalAlignment: Text.AlignHCenter
                                            validator: IntValidator { bottom: 0; top: 59 }
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                if (text !== "" && !isNaN(text)) {
                                                    root.targetMinute = Math.min(59, Math.max(0, parseInt(text)))
                                                }
                                            }
                                        }
                                    }
                                    
                                    RippleButton {
                                        Layout.preferredHeight: 32
                                        Layout.preferredWidth: 32
                                        buttonRadius: 4
                                        colBackground: Appearance.colors.colLayer1
                                        colBackgroundHover: Appearance.colors.colLayer1Hover
                                        colRipple: Appearance.colors.colLayer1Active
                                        
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "add"
                                            iconSize: 16
                                            color: Appearance.colors.colOnLayer1
                                        }
                                        
                                        onClicked: if (root.targetMinute < 59) root.targetMinute++
                                    }
                                }
                            }
                        }
                        
                        // Quick time presets
                        GridLayout {
                            columns: 4
                            columnSpacing: 4
                            rowSpacing: 4
                            Layout.fillWidth: true
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "7 AM"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.targetHour = 7; root.targetMinute = 0 }
                            }
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "11 AM"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.targetHour = 11; root.targetMinute = 0 }
                            }
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "3 PM"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.targetHour = 15; root.targetMinute = 0 }
                            }
                            
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                buttonRadius: 4
                                colBackground: Appearance.colors.colSecondaryContainer
                                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                                colRipple: Appearance.colors.colSecondaryContainerActive
                                
                                contentItem: StyledText {
                                    text: "8 PM"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnSecondaryContainer
                                }
                                
                                onClicked: { root.targetHour = 20; root.targetMinute = 0 }
                            }
                        }
                    }
                }
            }
        }
        
        // Control buttons
        RowLayout {
            id: controlButtons
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 40
            }
            spacing: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            
            RippleButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 35
                buttonRadius: 4
                enabled: !root.isRunning && !root.isFinished && (root.hours > 0 || root.minutes > 0 || root.isPaused)
                colBackground: Appearance.colors.colPrimary
                colBackgroundHover: Appearance.colors.colPrimaryHover
                colRipple: Appearance.colors.colPrimaryActive
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "play_arrow"
                    iconSize: 18
                    color: Appearance.colors.colOnPrimary
                }
                
                onClicked: {
                    if (root.isPaused) {
                        root.isPaused = false
                        root.isRunning = true
                        root.countdownTimer.start()
                    } else {
                        root.startTimer()
                    }
                }
            }
            
            RippleButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 35
                buttonRadius: 4
                enabled: root.isRunning || root.isFinished
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colErrorContainerHover
                colRipple: Appearance.colors.colErrorContainerActive
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "restart_alt"
                    iconSize: 18
                    color: Appearance.colors.colOnErrorContainer
                }
                
                onClicked: {
                    root.resetTimer()
                    root.isPaused = false
                }
            }
            
            RippleButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 35
                buttonRadius: 4
                enabled: !root.isRunning
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.showSettings ? "close" : "edit"
                    iconSize: 18
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: root.showSettings = !root.showSettings
            }
        }
    }
}