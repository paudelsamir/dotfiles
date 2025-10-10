import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    property bool visible: false
    readonly property real widgetWidth: 260
    readonly property real widgetHeight: 110
    property real popupRounding: 6

    Loader {
        id: countdownPopupLoader
        active: GlobalStates.countdownPopupOpen

        sourceComponent: PanelWindow {
            id: countdownPopupRoot
            visible: true

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            implicitWidth: root.widgetWidth
            implicitHeight: root.widgetHeight
            color: "transparent"
            WlrLayershell.namespace: "quickshell:countdownPopup"

            anchors {
                top: !Config.options.bar.bottom || Config.options.bar.vertical
                bottom: Config.options.bar.bottom && !Config.options.bar.vertical
                left: !(Config.options.bar.vertical && Config.options.bar.bottom)
                right: Config.options.bar.vertical && Config.options.bar.bottom
            }
            margins {
                top: Config.options.bar.vertical ? ((countdownPopupRoot.screen.height / 2) - root.widgetHeight / 2) : Appearance.sizes.barHeight
                bottom: Appearance.sizes.barHeight
                left: Config.options.bar.vertical ? Appearance.sizes.barHeight : ((countdownPopupRoot.screen.width / 2) + 100)
                right: Appearance.sizes.barHeight
            }

            mask: Region { item: popupContent }

            HyprlandFocusGrab {
                windows: [countdownPopupRoot]
                active: countdownPopupLoader.active
                onCleared: () => {
                    if (!active) {
                        GlobalStates.countdownPopupOpen = false;
                    }
                }
            }

            Item {
                id: popupContent
                anchors.fill: parent
Rectangle {
    id: popupBackground
    anchors.centerIn: parent
    width: root.widgetWidth
    height: root.widgetHeight
    color: "#2E2E2E20"        // dark gray with minimal opacity (~12%)
    radius: root.popupRounding
    border.width: 1
    border.color: "#ffffffff" // grayish border with same minimal opacity

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        StyledText {
            text: "Set Goal Date"
            font.pixelSize: Appearance.font.pixelSize.normal
            color: "#FFFFFF"          // white font
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: "#3A3A3A20"         // input background dark gray minimal opacity
                border.width: 1
                border.color: "#ffffffff"  // grayish border

                TextInput {
                    id: dateInput
                    anchors.fill: parent
                    anchors.margins: 4
                    text: GlobalStates.countdownTargetDate || ""
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: "#FFFFFF"      // white text
                    horizontalAlignment: Text.AlignLeft
                    selectByMouse: true
                }
            }

            Button {
                text: "Save"
                Layout.preferredWidth: 50
                height: 32
                font.pixelSize: Appearance.font.pixelSize.normal
                background: Rectangle {
                    anchors.fill: parent
                    color: "#2E2E2E20"        // button background dark gray minimal opacity
                    border.width: 1
                    border.color: "#ffffffff" // grayish border
                }
                contentItem: Text {
                    text: parent.text
                    anchors.centerIn: parent
                    color: "#FFFFFF"        // white text
                    font.pixelSize: parent.font.pixelSize
                }
                enabled: dateInput.text.length > 0
            }
        }
    }
}


            }
        }
    }
}
