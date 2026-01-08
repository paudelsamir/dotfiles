import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    required property var goalsList
    property string emptyPlaceholderIcon
    property string emptyPlaceholderText
    property int goalsListItemSpacing: 5
    property int goalsListItemPadding: 8
    property int listBottomPadding: 80

    StyledFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: columnLayout.height

        clip: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: flickable.width
                height: flickable.height
                radius: Appearance.rounding.small
            }
        }

        ColumnLayout {
            id: columnLayout
            width: parent.width
            spacing: 0
            
            // Empty state
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: flickable.height * 0.6
                visible: root.goalsList.length === 0
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    MaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.emptyPlaceholderIcon
                        iconSize: 40
                        color: Appearance.colors.colOutlineVariant
                    }
                    
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.emptyPlaceholderText
                        font.pixelSize: 12
                        color: Appearance.colors.colOutlineVariant
                    }
                }
            }
            
            Repeater {
                model: ScriptModel {
                    values: root.goalsList
                }
                delegate: Item {
                    id: goalItem
                    property bool pendingDelete: false
                    property bool pendingComplete: false
                    property bool enableHeightAnimation: false

                    Layout.fillWidth: true
                    implicitHeight: goalItemRectangle.implicitHeight + goalsListItemSpacing
                    height: implicitHeight
                    clip: true

                    Behavior on implicitHeight {
                        enabled: enableHeightAnimation
                        NumberAnimation {
                            duration: Appearance.animation.elementMoveFast.duration
                            easing.type: Appearance.animation.elementMoveFast.type
                            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                        }
                    }

                    function startAction() {
                        enableHeightAnimation = true
                        goalItem.implicitHeight = 0
                        actionTimer.start()
                    }

                    Timer {
                        id: actionTimer
                        interval: Appearance.animation.elementMoveFast.duration
                        repeat: false
                        onTriggered: {
                            if (goalItem.pendingDelete) {
                                MonthlyGoalsState.deleteGoal(modelData.id)
                            } else if (goalItem.pendingComplete) {
                                if (modelData.progress < 100) {
                                    MonthlyGoalsState.updateGoalProgress(modelData.id, 100)
                                } else {
                                    MonthlyGoalsState.updateGoalProgress(modelData.id, 0)
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: goalItemRectangle
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        implicitHeight: goalContentRowLayout.implicitHeight
                        color: Appearance.colors.colLayer2
                        radius: Appearance.rounding.small
                        
                        ColumnLayout {
                            id: goalContentRowLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: goalsListItemPadding

                            // Title and Progress
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: goalsListItemPadding
                                spacing: 8
                                
                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    wrapMode: Text.Wrap
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                }
                                
                                StyledText {
                                    text: modelData.progress + "%"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colPrimary
                                    Layout.alignment: Qt.AlignRight
                                }
                            }

                            // Progress Bar
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 4
                                Layout.topMargin: 6
                                color: Appearance.colors.colLayer1
                                radius: 2

                                Rectangle {
                                    height: parent.height
                                    width: parent.width * (modelData.progress / 100)
                                    color: Appearance.colors.colPrimary
                                    radius: 2

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }
                            }

                            // Action Buttons
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                Layout.bottomMargin: goalsListItemPadding
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                }

                                // Complete Button
                                RippleButton {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    buttonRadius: Appearance.rounding.small
                                    colBackground: Appearance.colors.colLayer1
                                    colBackgroundHover: Appearance.colors.colLayer1Hover
                                    colRipple: Appearance.colors.colLayer1Active
                                    
                                    onClicked: {
                                        goalItem.pendingComplete = true
                                        goalItem.startAction()
                                    }
                                    
                                    contentItem: MaterialSymbol {
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData.progress === 100 ? "radio_button_checked" : "radio_button_unchecked"
                                        iconSize: Appearance.font.pixelSize.larger
                                        color: modelData.progress === 100 ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                                    }
                                }

                                // Delete Button
                                RippleButton {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    buttonRadius: Appearance.rounding.small
                                    colBackground: Appearance.colors.colLayer1
                                    colBackgroundHover: Appearance.colors.colLayer1Hover
                                    colRipple: Appearance.colors.colLayer1Active
                                    
                                    onClicked: {
                                        goalItem.pendingDelete = true
                                        goalItem.startAction()
                                    }
                                    
                                    contentItem: MaterialSymbol {
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        text: "delete_forever"
                                        iconSize: Appearance.font.pixelSize.larger
                                        color: Appearance.colors.colOnLayer1
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Bottom padding
            Item {
                implicitHeight: listBottomPadding
            }
        }
    }
}
