import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts
import Qt.labs.settings 1.0
import Quickshell

Item {
    id: root

    Settings {
        id: countdownSettings
        property string targetDate: "2025-12-31"
        property string lastCheckedDate: ""
    }

    property string targetDate: countdownSettings.targetDate

    property int daysLeft: {
        var today = new Date()
        today = new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()))

        var target = new Date(targetDate)
        target = new Date(Date.UTC(target.getFullYear(), target.getMonth(), target.getDate()))

        var timeDiff = target.getTime() - today.getTime()
        var daysDiff = Math.floor(timeDiff / (1000 * 60 * 60 * 24))

        return Math.max(0, daysDiff)
    }

    Timer {
        id: dailyUpdateTimer
        interval: 60000
        running: true
        repeat: true

        onTriggered: checkForNewDay()
    }

    function checkForNewDay() {
        var today = new Date()
        var todayString = today.toDateString()

        if (countdownSettings.lastCheckedDate !== todayString) {
            countdownSettings.lastCheckedDate = todayString
            root.targetDateChanged()
        }
    }

    Component.onCompleted: {
        checkForNewDay()
        GlobalStates.countdownTargetDate = countdownSettings.targetDate
    }

    Connections {
        target: GlobalStates
        function onCountdownTargetDateChanged() {
            if (GlobalStates.countdownTargetDate !== countdownSettings.targetDate) {
                countdownSettings.targetDate = GlobalStates.countdownTargetDate
                root.targetDate = GlobalStates.countdownTargetDate
            }
        }
    }

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onPressed: {
            GlobalStates.countdownPopupOpen = !GlobalStates.countdownPopupOpen;
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            font.weight: Font.Normal
            fill: 0
            text: "schedule"
            iconSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
        }

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
            text: root.daysLeft > 0 ? root.daysLeft + "d" : "0d"
        }
    }

    EventsHoverPopup {
        hoverTarget: mouseArea
    }
}
