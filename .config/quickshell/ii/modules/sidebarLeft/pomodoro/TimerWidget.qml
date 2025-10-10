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
    
    property int hours: 0
    property int minutes: 5
    property int seconds: 0
    property int totalSeconds: 0
    property int remainingSeconds: 0
    property bool isRunning: false
    property bool isFinished: false
    
    implicitHeight: contentColumn.implicitHeight
    implicitWidth: contentColumn.implicitWidth
    
    function startTimer() {
        totalSeconds = hours * 3600 + minutes * 60 + seconds
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
        // Play multiple alert sounds for better attention
        Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"])
        // Fallback sounds if the first doesn't exist
        Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga"])
        Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/bell.oga"])
        // System beep as final fallback
        Quickshell.execDetached(["speaker-test", "-t", "sine", "-f", "1000", "-l", "1"])
    }
    
    function showNotification(title, message) {
        // Minimal notification with high urgency and longer duration
        Quickshell.execDetached([
            "notify-send", 
            "--urgency=critical",
            "--expire-time=10000",
            "--icon=appointment-soon",
            "--category=timer",
            "--hint=string:desktop-entry:timer",
            title, 
            message
        ])
        
        // Also try with dunst-specific options for minimal style
        Quickshell.execDetached([
            "notify-send",
            "-u", "critical",
            "-t", "10000",
            "-i", "clock",
            "-c", "timer",
            "-h", "string:bgcolor:#1e1e2e",
            "-h", "string:fgcolor:#cdd6f4",
            "-h", "int:value:100",
            title,
            message
        ])
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
                showNotification("Timer Finished!", "Your timer has completed.")
            }
        }
    }
    
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 0
        
        // Fixed spacer to keep circle centered
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
        }
        
        // Timer circle (like pomodoro)
        CircularProgress {
            Layout.alignment: Qt.AlignHCenter
            lineWidth: 8
            value: isRunning ? (totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0) : 0
            implicitSize: 200
            enableAnimation: true
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        if (isRunning || isFinished) {
                            return formatTime(remainingSeconds)
                        } else {
                            return formatTime(hours * 3600 + minutes * 60 + seconds)
                        }
                    }
                    font.pixelSize: 40
                    color: Appearance.m3colors.m3onSurface
                }
                
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: isFinished ? Translation.tr("Finished!") : 
                          isRunning ? Translation.tr("Running") : Translation.tr("Timer")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
        
        // Fixed spacer to maintain layout consistency
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
        }
        
        // Container for presets with fixed height to prevent layout shifts
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 80
            Layout.preferredWidth: 200
            
            // Quick presets (when not running)
            GridLayout {
                anchors.centerIn: parent
                columns: 4
                columnSpacing: 4
                rowSpacing: 4
                visible: !isRunning && !isFinished
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "5m"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 0; minutes = 5; seconds = 0 }
            }
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "10m"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 0; minutes = 10; seconds = 0 }
            }
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "25m"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 0; minutes = 25; seconds = 0 }
            }
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "1h"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 1; minutes = 0; seconds = 0 }
            }
            
            // Time adjustment buttons
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colSecondaryContainer
                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "+1m"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSecondaryContainer
                }
                
                onClicked: { 
                    minutes += 1
                    if (minutes >= 60) {
                        hours += Math.floor(minutes / 60)
                        minutes = minutes % 60
                    }
                }
            }
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colSecondaryContainer
                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "+5m"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSecondaryContainer
                }
                
                onClicked: { 
                    minutes += 5
                    if (minutes >= 60) {
                        hours += Math.floor(minutes / 60)
                        minutes = minutes % 60
                    }
                }
            }
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colSecondaryContainer
                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "-1m"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSecondaryContainer
                }
                
                onClicked: { 
                    if (minutes > 0) {
                        minutes -= 1
                    } else if (hours > 0) {
                        hours -= 1
                        minutes = 59
                    }
                }
            }
            
            RippleButton {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 45
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colErrorContainerHover
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "Clear"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnErrorContainer
                }
                
                onClicked: { hours = 0; minutes = 0; seconds = 0 }
            }
        }
        }
        
        // Control buttons (like pomodoro)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            
            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                enabled: !isRunning && !isFinished && (hours > 0 || minutes > 0 || seconds > 0)
                
                colBackground: isRunning ? Appearance.colors.colSecondaryContainer : Appearance.colors.colPrimary
                colBackgroundHover: isRunning ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colPrimaryHover
                colRipple: isRunning ? Appearance.colors.colSecondaryContainerActive : Appearance.colors.colPrimaryActive
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: isRunning ? Translation.tr("Pause") : remainingSeconds === 0 ? Translation.tr("Start") : Translation.tr("Resume")
                    color: isRunning ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnPrimary
                }
                
                onClicked: isRunning ? pauseTimer() : startTimer()
            }
            
            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                enabled: isRunning || isFinished || remainingSeconds > 0
                
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colErrorContainerHover
                colRipple: Appearance.colors.colErrorContainerActive
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: Translation.tr("Reset")
                    color: Appearance.colors.colOnErrorContainer
                }
                
                onClicked: resetTimer()
            }
        }
    }
}