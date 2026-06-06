import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 0

        ClippedFilledCircularProgress {
            id: dayCircProg
            lineWidth: Appearance.rounding.unsharpen
            value: DateTime.dayProgressPercentage / 100
            implicitSize: 16
            colPrimary: Appearance.colors.colOnSecondaryContainer
            enableAnimation: false

            Item {
                anchors.centerIn: parent
                width: dayCircProg.implicitSize
                height: dayCircProg.implicitSize
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: 1
                    text: "schedule"
                    iconSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        DaysProgressTooltip {
            hoverTarget: mouseArea
            dayProgressPercentage: DateTime.dayProgressPercentage
            hoursLeft: DateTime.hoursLeft
            minutesLeft: DateTime.minutesLeft
        }
    }
}
