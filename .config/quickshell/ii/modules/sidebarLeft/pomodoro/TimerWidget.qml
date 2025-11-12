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
    
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    function startTimer() {
        totalSeconds = hours * 3600 + minutes * 60
        remainingSeconds = totalSeconds
        if (remainingSeconds > 0) {
            isRunning = true
            isFinished = false
            countdownTimer.start()
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
    
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            remainingSeconds--
            if (remainingSeconds <= 0) {
                stop()
                isRunning = false
                isFinished = true
                playAlertSound()
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
                        let hours = root.hours.toString().padStart(2, '0')
                        let minutes = root.minutes.toString().padStart(2, '0')
                        return hours === "00" ? `${minutes}:00` : `${hours}:${minutes}:00`
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
                topMargin: -50
                left: parent.left
                right: parent.right
            }
            height: settingsColumn.implicitHeight + 10
            color: Appearance.colors.colLayer2
            radius: 6
            visible: root.showSettings && !root.isRunning
            
            ColumnLayout {
                id: settingsColumn
                anchors {
                    fill: parent
                    margins: 5
                }
                spacing: 0
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.alignment: Qt.AlignHCenter
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Layout.alignment: Qt.AlignHCenter
                        
                        StyledText {
                            text: "H"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer2
                            Layout.preferredWidth: 12
                        }
                        
                        RippleButton {
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: 24
                            buttonRadius: 3
                            colBackground: Appearance.colors.colLayer1
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            colRipple: Appearance.colors.colLayer1Active
                            
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "remove"
                                iconSize: 14
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            onClicked: if (root.hours > 0) root.hours--
                        }
                        
                        StyledText {
                            text: root.hours.toString().padStart(2, '0')
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Appearance.colors.colPrimary
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 20
                        }
                        
                        RippleButton {
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: 24
                            buttonRadius: 3
                            colBackground: Appearance.colors.colLayer1
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            colRipple: Appearance.colors.colLayer1Active
                            
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "add"
                                iconSize: 14
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            onClicked: if (root.hours < 23) root.hours++
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Layout.alignment: Qt.AlignHCenter
                        
                        StyledText {
                            text: "M"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer2
                            Layout.preferredWidth: 12
                        }
                        
                        RippleButton {
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: 24
                            buttonRadius: 3
                            colBackground: Appearance.colors.colLayer1
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            colRipple: Appearance.colors.colLayer1Active
                            
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "remove"
                                iconSize: 14
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            onClicked: if (root.minutes > 0) root.minutes = Math.max(0, root.minutes - 5)
                        }
                        
                        StyledText {
                            text: root.minutes.toString().padStart(2, '0')
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Appearance.colors.colPrimary
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 20
                        }
                        
                        RippleButton {
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: 24
                            buttonRadius: 3
                            colBackground: Appearance.colors.colLayer1
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            colRipple: Appearance.colors.colLayer1Active
                            
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "add"
                                iconSize: 14
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            onClicked: if (root.minutes < 59) root.minutes = Math.min(59, root.minutes + 5)
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