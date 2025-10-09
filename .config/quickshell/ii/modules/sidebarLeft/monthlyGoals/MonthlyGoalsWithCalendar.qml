import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import "../calendar"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property int currentTab: 0
    property var tabButtonList: [
        {"icon": "flag", "name": Translation.tr("Goals")}, 
        {"icon": "calendar_month", "name": Translation.tr("Calendar")}
    ]

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                currentTab = Math.min(currentTab + 1, root.tabButtonList.length - 1)
            } else if (event.key === Qt.Key_PageUp) {
                currentTab = Math.max(currentTab - 1, 0)
            }
            event.accepted = true;
        }
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_Tab) {
                currentTab = (currentTab + 1) % root.tabButtonList.length
            } else if (event.key === Qt.Key_Backtab) {
                currentTab = (currentTab - 1 + root.tabButtonList.length) % root.tabButtonList.length
            }
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        PrimaryTabBar {
            id: tabBar
            tabButtonList: root.tabButtonList
            externalTrackedTab: root.currentTab
            function onCurrentIndexChanged(currentIndex) {
                root.currentTab = currentIndex
            }
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            
            currentIndex: root.currentTab
            onCurrentIndexChanged: {
                tabBar.enableIndicatorAnimation = true
                root.currentTab = currentIndex
            }

            clip: true

            // Monthly Goals Page
            MonthlyGoals {
                id: monthlyGoalsPage
            }

            // Calendar Page
            CalendarWidget {
                id: calendarPage
            }
        }
    }
}