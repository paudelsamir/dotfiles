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
    
    Item {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        
        // Time Display (centered and larger)
        Rectangle {
            id: timeDisplayContainer
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width * 0.9
            height: 80
            radius: Appearance.rounding.normal
            color: isFinished ? Appearance.colors.colError : 
                   isRunning ? Appearance.colors.colPrimary : 
                   Appearance.colors.colLayer2
            border.width: 1
            border.color: isFinished ? Appearance.colors.colError : 
                          isRunning ? Appearance.colors.colPrimary : 
                          Appearance.colors.colLayer2Border
            
            Behavior on color {
                ColorAnimation { duration: 300 }
            }
            
            StyledText {
                anchors.centerIn: parent
                font.pixelSize: 48
                font.family: "monospace"
                font.weight: Font.Bold
                color: isFinished || isRunning ? "white" : Appearance.colors.colOnLayer2
                text: {
                    if (isRunning || isFinished) {
                        return formatTime(remainingSeconds); // Reverse countdown
                    } else {
                        return formatTime(hours * 3600 + minutes * 60 + seconds); // Set time
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
        
        // Quick Timer Presets (visible when not running)
        GridLayout {
            id: quickPresets
            anchors {
                top: timeDisplayContainer.bottom
                bottom: controlButtons.top
                left: parent.left
                right: parent.right
                topMargin: 16
                bottomMargin: 16
            }
            columns: 2
            rowSpacing: 8
            columnSpacing: 8
            visible: !isRunning && !isFinished
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "5 min"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 0; minutes = 5; seconds = 0 }
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "10 min"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 0; minutes = 10; seconds = 0 }
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "25 min"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 0; minutes = 25; seconds = 0 }
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colLayer2Active
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: "1 hour"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: { hours = 1; minutes = 0; seconds = 0 }
            }
            
            // Custom time adjusters
            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                spacing: 4
                
                RippleButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    colBackground: Appearance.colors.colSecondaryContainer
                    colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                    buttonRadius: Appearance.rounding.small
                    
                    contentItem: StyledText {
                        horizontalAlignment: Text.AlignHCenter
                        text: "+1m"
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    
                    onClicked: { minutes = Math.min(minutes + 1, 59) }
                }
                
                RippleButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
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
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
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
        
        // Progress indicator (when running)
        Item {
            anchors {
                top: timeDisplayContainer.bottom
                bottom: controlButtons.top
                left: parent.left
                right: parent.right
                topMargin: 16
                bottomMargin: 16
            }
            visible: isRunning
            
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.8, parent.height * 0.8)
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 6
                border.color: Appearance.colors.colLayer2
                
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 12
                    height: parent.height - 12
                    radius: width / 2
                    color: "transparent"
                    rotation: -90
                    
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            
                            // Draw progress arc
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = (width - 8) / 2;
                            var progress = totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0;
                            var angle = 2 * Math.PI * progress;
                            
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, angle);
                            ctx.lineWidth = 6;
                            ctx.strokeStyle = Appearance.colors.colPrimary;
                            ctx.stroke();
                        }
                        
                        Connections {
                            target: root
                            function onRemainingSecondsChanged() {
                                parent.requestPaint();
                            }
                        }
                    }
                }
                
                // Progress text in center
                StyledText {
                    anchors.centerIn: parent
                    text: totalSeconds > 0 ? Math.round((totalSeconds - remainingSeconds) / totalSeconds * 100) + "%" : "0%"
                    font.pixelSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colPrimary
                    font.weight: Font.Bold
                }
            }
        }
        
        // Control Buttons (bottom like stopwatch)
        RowLayout {
            id: controlButtons
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 6
            }
            spacing: 4
            
            RippleButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                enabled: !isRunning && !isFinished && (hours > 0 || minutes > 0 || seconds > 0)
                
                colBackground: isRunning ? Appearance.colors.colSecondaryContainer : Appearance.colors.colPrimary
                colBackgroundHover: isRunning ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colPrimaryHover
                colRipple: isRunning ? Appearance.colors.colSecondaryContainerActive : Appearance.colors.colPrimaryActive
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    color: isRunning ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnPrimary
                    text: isRunning ? Translation.tr("Pause") : remainingSeconds === 0 ? Translation.tr("Start") : Translation.tr("Resume")
                }
                
                onClicked: isRunning ? pauseTimer() : startTimer()
                visible: !isFinished
            }
            
            RippleButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                enabled: isRunning || isFinished || remainingSeconds > 0
                
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colErrorContainerHover
                colRipple: Appearance.colors.colErrorContainerActive
                
                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: Translation.tr("Reset")
                    color: Appearance.colors.colOnErrorContainer
                }
                
                onClicked: resetTimer()
            }
        }
    }
}