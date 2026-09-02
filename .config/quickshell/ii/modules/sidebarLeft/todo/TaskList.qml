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
    required property var taskList;
    property string emptyPlaceholderIcon
    property string emptyPlaceholderText
    property int todoListItemSpacing: 3
    property int todoListItemPadding: 5
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
            Repeater {
                model: ScriptModel {
                    values: taskList
                }
                delegate: Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    spacing: 0
                    
                    // Show block header only once per block (when blockName changes)
                    Item {
                        visible: index === 0 || modelData.blockName !== taskList[index - 1].blockName
                        width: parent.width
                        implicitHeight: visible ? (index === 0 ? 32 : 42) : 0
                        
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 32
                            color: Appearance.colors.colPrimary
                            radius: Appearance.rounding.small
                        
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 6
                                
                                MaterialSymbol {
                                    text: "schedule"
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: Appearance.m3colors.m3onPrimary
                                }
                                
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.m3colors.m3onPrimary
                                    text: modelData.blockName || ""
                                }
                            }
                        }
                    }
                    
                    // Task item
                    Item {
                        id: todoItem
                        property bool pendingDoneToggle: false
                        property bool pendingDelete: false
                        property bool enableHeightAnimation: false

                        width: parent.width
                        implicitHeight: todoItemRectangle.implicitHeight + todoListItemSpacing
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
                            todoItem.implicitHeight = 0
                            actionTimer.start()
                        }

                        Timer {
                            id: actionTimer
                            interval: Appearance.animation.elementMoveFast.duration
                            repeat: false
                            onTriggered: {
                                if (todoItem.pendingDelete) {
                                    Todo.deleteItem(modelData.originalIndex)
                                } else if (todoItem.pendingDoneToggle) {
                                    if (!modelData.done) Todo.markDone(modelData.originalIndex)
                                    else Todo.markUnfinished(modelData.originalIndex)
                                }
                            }
                        }

                        Rectangle {
                            id: todoItemRectangle
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            implicitHeight: todoContentRowLayout.implicitHeight
                            color: Appearance.colors.colLayer2
                            radius: Appearance.rounding.small
                            
                            // Hover effect
                            border.width: 1
                            border.color: Appearance.colors.colOutlineVariant
                            
                            ColumnLayout {
                                id: todoContentRowLayout
                                anchors.left: parent.left
                                anchors.right: parent.right

                                StyledText {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 10
                                    Layout.rightMargin: 10
                                    Layout.topMargin: 8
                                    id: todoContentText
                                    text: modelData.content
                                    wrapMode: Text.Wrap
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnLayer2
                                }
                                RowLayout {
                                    Layout.leftMargin: 10
                                    Layout.rightMargin: 10
                                    Layout.bottomMargin: 6
                                    spacing: 5
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    TodoItemActionButton {
                                        Layout.fillWidth: false
                                        onClicked: {
                                            todoItem.pendingDoneToggle = true
                                            todoItem.startAction()
                                        }
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            text: modelData.done ? "remove_done" : "check"
                                            iconSize: Appearance.font.pixelSize.normal
                                            color: Appearance.colors.colOnLayer1
                                        }
                                    }
                                    TodoItemActionButton {
                                        Layout.fillWidth: false
                                        visible: modelData.done && !modelData.isDaily
                                        onClicked: {
                                            todoItem.pendingDelete = true
                                            todoItem.startAction()
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

            }
            // Bottom padding
            Item {
                implicitHeight: listBottomPadding
            }
        }
    }
    
    Item { // Placeholder when list is empty
        visible: opacity > 0
        opacity: taskList.length === 0 ? 1 : 0
        anchors.fill: parent

        Behavior on opacity {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                iconSize: 55
                color: Appearance.m3colors.m3outline
                text: emptyPlaceholderIcon
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3outline
                horizontalAlignment: Text.AlignHCenter
                text: emptyPlaceholderText
            }
        }
    }
}