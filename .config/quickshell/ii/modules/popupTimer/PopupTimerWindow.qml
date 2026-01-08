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

    // Timer badge notification
    PanelWindow {
        id: timerBadge
        
        visible: PopupTimerState.isRunning || PopupTimerState.isFinished
        screen: Quickshell.screens[0] ?? null
        
        WlrLayershell.namespace: "quickshell:timerBadge"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0
        
        color: "transparent"
        implicitWidth: timerText.width + 40
        implicitHeight: timerText.height + 24
        
        anchors {
            left: PopupTimerState.badgePosition === "top-left" || PopupTimerState.badgePosition === "bottom-left"
            right: PopupTimerState.badgePosition === "top-right" || PopupTimerState.badgePosition === "bottom-right"
            top: PopupTimerState.badgePosition === "top-left" || PopupTimerState.badgePosition === "top-right"
            bottom: PopupTimerState.badgePosition === "bottom-left" || PopupTimerState.badgePosition === "bottom-right"
        }
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            
            color: PopupTimerState.isFinished ? Appearance.colors.colErrorContainer : Appearance.colors.colPrimaryContainer
            radius: 8
            border.color: PopupTimerState.isFinished ? Appearance.colors.colError : Appearance.colors.colPrimary
            border.width: 1
            opacity: 0.6
            
            StyledText {
                id: timerText
                anchors.centerIn: parent
                text: PopupTimerState.formatTime(PopupTimerState.remainingSeconds)
                font.pixelSize: 32
                font.weight: Font.Bold
                font.family: "monospace"
                color: PopupTimerState.isFinished ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnPrimaryContainer
            }
        }
        
        // Auto-hide after timer finishes
        Timer {
            running: PopupTimerState.isFinished
            interval: 5000
            onTriggered: {
                PopupTimerState.isFinished = false
                PopupTimerState.remainingSeconds = 0
            }
        }
    }
}
