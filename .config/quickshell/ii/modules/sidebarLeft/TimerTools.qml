import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./pomodoro/"

Item {
    id: root
    
    property int currentTimerTab: 0
    property var timerTabList: [
        {"icon": "schedule", "name": "Timer"},
        {"icon": "timer", "name": "Stopwatch"},
        {"icon": "spa", "name": "Pomodoro"}
    ]
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: currentTimerTab
            
            // Timer Widget
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                TimerWidget {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                }
            }
            
            // Stopwatch Widget
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                Stopwatch {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                }
            }
            
            // Pomodoro Widget
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                PomodoroTimer {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                }
            }
        }
        
        Rectangle { // Tabbar top border
            id: tabBarTopBorder
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }
        
        Item { // Tab indicator
            id: tabIndicator
            Layout.fillWidth: true
            height: 3
            property bool enableIndicatorAnimation: false
            Connections {
                target: root
                function onCurrentTimerTabChanged() {
                    tabIndicator.enableIndicatorAnimation = true
                }
            }
            
            Rectangle {
                id: indicator
                property int tabCount: root.timerTabList.length
                property real fullTabSize: root.width / tabCount
                property real targetWidth: tabBar.contentItem.children[0].children[tabBar.currentIndex].tabContentWidth
                
                implicitWidth: targetWidth
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                
                x: tabBar.currentIndex * fullTabSize + (fullTabSize - targetWidth) / 2
                
                color: Appearance.colors.colPrimary
                radius: Appearance.rounding.full
                
                Behavior on x {
                    enabled: tabIndicator.enableIndicatorAnimation
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                
                Behavior on implicitWidth {
                    enabled: tabIndicator.enableIndicatorAnimation
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }
        
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: currentTimerTab
            onCurrentIndexChanged: currentTimerTab = currentIndex
            
            background: Item {
                WheelHandler {
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                            tabBar.currentIndex = Math.min(tabBar.currentIndex + 1, root.timerTabList.length - 1)
                        else if (event.angleDelta.y > 0)
                            tabBar.currentIndex = Math.max(tabBar.currentIndex - 1, 0)
                    }
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                }
            }
            
            Repeater {
                model: root.timerTabList
                delegate: SecondaryTabButton {
                    selected: (index == currentTimerTab)
                    buttonText: modelData.name
                    buttonIcon: modelData.icon
                }
            }
        }
    }
}
