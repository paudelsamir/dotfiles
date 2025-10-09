import qs.modules.common
import qs.modules.common.widgets
import qs
import qs.services
import "./calendar"
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1
    clip: true
    implicitHeight: collapsed ? collapsedBottomWidgetGroupRow.implicitHeight : bottomWidgetGroupRow.implicitHeight
    property int selectedTab: Persistent.states.sidebar.bottomGroup.tab
    property bool collapsed: Persistent.states.sidebar.bottomGroup.collapsed
    property var tabs: []

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    function setCollapsed(state) {
        Persistent.states.sidebar.bottomGroup.collapsed = state
        if (collapsed) {
            bottomWidgetGroupRow.opacity = 0
        }
        else {
            collapsedBottomWidgetGroupRow.opacity = 0
        }
        collapseCleanFadeTimer.start()
    }

    Timer {
        id: collapseCleanFadeTimer
        interval: Appearance.animation.elementMove.duration / 2
        repeat: false
        onTriggered: {
            if(collapsed) collapsedBottomWidgetGroupRow.opacity = 1
            else bottomWidgetGroupRow.opacity = 1
        }
    }

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp)
            && event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                root.selectedTab = Math.min(root.selectedTab + 1, root.tabs.length - 1)
            } else if (event.key === Qt.Key_PageUp) {
                root.selectedTab = Math.max(root.selectedTab - 1, 0)
            }
            event.accepted = true;
        }
    }

    // The thing when collapsed - just show current date
    RowLayout {
        id: collapsedBottomWidgetGroupRow
        opacity: collapsed ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                id: collapsedBottomWidgetGroupRowFade
                duration: Appearance.animation.elementMove.duration / 2
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
            }
        }

        spacing: 15
        
        CalendarHeaderButton {
            Layout.margins: 10
            Layout.rightMargin: 0
            forceCircle: true
            onClicked: {
                root.setCollapsed(false)
            }
            contentItem: MaterialSymbol {
                text: "keyboard_arrow_up"
                iconSize: Appearance.font.pixelSize.larger
                horizontalAlignment: Text.AlignHCenter
                color: Appearance.colors.colOnLayer1
            }
        }

        StyledText {
            Layout.margins: 10
            Layout.leftMargin: 0
            text: DateTime.collapsedCalendarFormat
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
        }
    }

    // The thing when expanded - just show the calendar
    ColumnLayout {
        id: bottomWidgetGroupRow
        anchors.fill: parent
        anchors.margins: 10

        opacity: collapsed ? 0 : 1
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                id: bottomWidgetGroupRowFade
                duration: Appearance.animation.elementMove.duration / 2
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
            }
        }

        spacing: 5
        
        // Collapse button
        RowLayout {
            Layout.fillWidth: true
            
            Item {
                Layout.fillWidth: true
            }
            
            CalendarHeaderButton {
                forceCircle: true
                onClicked: {
                    root.setCollapsed(true)
                }
                contentItem: MaterialSymbol {
                    text: "keyboard_arrow_down"
                    iconSize: Appearance.font.pixelSize.larger
                    horizontalAlignment: Text.AlignHCenter
                    color: Appearance.colors.colOnLayer1
                }
            }
        }

        // Calendar content
        CalendarWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }




}