import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Scope {
    id: root
    
    // Eye care check timer
    Timer {
        id: eyeCareCheckTimer
        interval: 100  // Check every 100ms
        repeat: true
        running: PopupStopwatchState.isRunning
        
        property int lastCheckedSeconds: 0
        
        onTriggered: {
            let totalSeconds = Math.floor(PopupStopwatchState.elapsedTime) / 100
            let cycleSeconds = Math.floor(totalSeconds) % (25 * 60 + 60)  // 25 min work + 1 min rest cycle
            let isInRest = cycleSeconds >= (25 * 60)  // Rest happens after 25 minutes
            
            PopupStopwatchState.isEyeRestTime = isInRest
            
            // Trigger sound alert when entering rest period
            if (!PopupStopwatchState.isEyeRestTime && isInRest) {
                PopupStopwatchState.playNotificationSound()
            }
            
            // Update cycle count
            if (Math.floor(totalSeconds) > 0) {
                PopupStopwatchState.cycleCount = Math.floor(totalSeconds / (25 * 60 + 60))
            }
        }
    }

    // Stopwatch badge notification
    PanelWindow {
        id: stopwatchBadge
        
        visible: PopupStopwatchState.isRunning
        screen: Quickshell.screens[0] ?? null
        
        WlrLayershell.namespace: "quickshell:stopwatchBadge"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0
        
        color: "transparent"
        implicitWidth: stopwatchText.width + 40
        implicitHeight: stopwatchText.height + 24
        
        anchors {
            left: PopupStopwatchState.badgePosition === "top-left" || PopupStopwatchState.badgePosition === "bottom-left"
            right: PopupStopwatchState.badgePosition === "top-right" || PopupStopwatchState.badgePosition === "bottom-right"
            top: PopupStopwatchState.badgePosition === "top-left" || PopupStopwatchState.badgePosition === "top-right"
            bottom: PopupStopwatchState.badgePosition === "bottom-left" || PopupStopwatchState.badgePosition === "bottom-right"
        }
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            
            // Change color based on eye rest time
            color: PopupStopwatchState.isEyeRestTime ? Appearance.colors.colErrorContainer : Appearance.colors.colSecondaryContainer
            radius: 8
            border.color: PopupStopwatchState.isEyeRestTime ? Appearance.colors.colError : Appearance.colors.colSecondary
            border.width: 1.5
            opacity: 0.6
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                
                StyledText {
                    id: stopwatchText
                    text: PopupStopwatchState.formatTime(PopupStopwatchState.elapsedTime)
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    font.family: "monospace"
                    color: PopupStopwatchState.isEyeRestTime ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnSecondaryContainer
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
