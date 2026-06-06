import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    Loader {
        id: countdownPopupLoader
        active: GlobalStates.countdownPopupOpen

        sourceComponent: PanelWindow {
            id: countdownPopupRoot
            visible: true
            color: "transparent"

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            WlrLayershell.namespace: "quickshell:countdownPopup"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                left: !Config.options.bar.vertical || (Config.options.bar.vertical && !Config.options.bar.bottom)
                right: Config.options.bar.vertical && Config.options.bar.bottom
                top: Config.options.bar.vertical || (!Config.options.bar.vertical && !Config.options.bar.bottom)
                bottom: !Config.options.bar.vertical && Config.options.bar.bottom
            }

            implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2
            implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2

            margins {
                left: {
                    if (!Config.options.bar.vertical) {
                        return (countdownPopupRoot.screen.width / 2);
                    }
                    return Appearance.sizes.verticalBarWidth;
                }
                top: {
                    if (!Config.options.bar.vertical) return Appearance.sizes.barHeight;
                    return countdownPopupRoot.screen.height / 2 - popupBackground.implicitHeight / 2;
                }
                right: Appearance.sizes.verticalBarWidth
                bottom: Appearance.sizes.barHeight
            }

            mask: Region { item: popupBackground }

            HyprlandFocusGrab {
                windows: [countdownPopupRoot]
                active: countdownPopupLoader.active
                onCleared: () => {
                    if (!active) {
                        GlobalStates.countdownPopupOpen = false;
                    }
                }
            }

            StyledRectangularShadow {
                target: popupBackground
            }

            Rectangle {
                id: popupBackground
                implicitWidth: 290
                implicitHeight: contentColumn.implicitHeight + 20
                x: Appearance.sizes.elevationMargin
                y: Appearance.sizes.elevationMargin
                color: ColorUtils.applyAlpha(Appearance.colors.colSurfaceContainer, 1 - Appearance.backgroundTransparency)
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.colors.colLayer0Border

                ColumnLayout {
                    id: contentColumn
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 20

                    Column {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 6

                        Row {
                            spacing: 5
                            anchors.horizontalCenter: parent.horizontalCenter

                            MaterialSymbol {
                                anchors.verticalCenter: parent.verticalCenter
                                fill: 0
                                font.weight: Font.Medium
                                text: "event"
                                iconSize: Appearance.font.pixelSize.large
                                color: Appearance.colors.colOnSurfaceVariant
                            }

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Translation.tr("Set Target Date")
                                font {
                                    weight: Font.Medium
                                    pixelSize: Appearance.font.pixelSize.normal
                                }
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                        }
                    }

                    Column {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        Layout.fillWidth: true

                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter

                            MaterialSymbol {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "schedule"
                                iconSize: Appearance.font.pixelSize.large
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Translation.tr("Target: ") + (GlobalStates.countdownTargetDate || "Not set")
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                        }

                        Rectangle {
                            width: 250
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Appearance.colors.colLayer0Border
                            opacity: 0.3
                        }

                        RowLayout {
                            spacing: 6
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                Layout.preferredWidth: 190
                                Layout.preferredHeight: 32
                                color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                radius: Appearance.rounding.extraSmall
                                border.width: 1
                                border.color: dateInput.activeFocus ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                TextInput {
                                    id: dateInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: GlobalStates.countdownTargetDate || ""
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    horizontalAlignment: Text.AlignHCenter
                                    selectByMouse: true
                                    inputMask: "9999-99-99"

                                    property bool isValidDate: {
                                        if (text.length !== 10) return false;
                                        var parts = text.split('-');
                                        if (parts.length !== 3) return false;

                                        var year = parseInt(parts[0]);
                                        var month = parseInt(parts[1]);
                                        var day = parseInt(parts[2]);

                                        if (isNaN(year) || isNaN(month) || isNaN(day)) return false;
                                        if (month < 1 || month > 12) return false;
                                        if (day < 1 || day > 31) return false;

                                        var date = new Date(year, month - 1, day);
                                        return date.getMonth() === month - 1 && date.getDate() === day;
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "YYYY-MM-DD"
                                        color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                        visible: parent.text.length === 0 && !parent.activeFocus
                                        font.pixelSize: parent.font.pixelSize
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 70
                                Layout.preferredHeight: 32
                                radius: Appearance.rounding.extraSmall
                                color: saveButton.enabled ?
                                       (saveButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.3) :
                                        saveButton.hovered ? ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2) :
                                        ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.15)) :
                                       ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.1)
                                border.width: 1
                                border.color: saveButton.enabled ?
                                             ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.2) :
                                             ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, 0.2)

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: saveButton
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: dateInput.text.length === 10 && dateInput.isValidDate
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                    onClicked: {
                                        var inputDate = new Date(dateInput.text)
                                        var today = new Date()
                                        today.setHours(0,0,0,0)

                                        if (inputDate >= today && !isNaN(inputDate.getTime())) {
                                            GlobalStates.countdownTargetDate = dateInput.text
                                            GlobalStates.countdownPopupOpen = false
                                        }
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: Translation.tr("Update")
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Medium
                                        color: parent.enabled ? Appearance.colors.colOnSurfaceVariant :
                                               ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
