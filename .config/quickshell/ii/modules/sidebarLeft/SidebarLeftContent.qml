import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import "./todo/"
import "./monthlyGoals/"
import "./workout/"
import "./pomodoro/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland

Item {
    id: root
    required property var scopeRoot
    anchors.fill: parent
    property var tabButtonList: [
        {"icon": "task_alt", "name": Translation.tr("Todo")},
        {"icon": "fitness_center", "name": Translation.tr("Workout")}
    ]
    property int selectedTab: 0

    function focusActiveItem() {
        swipeView.currentItem.forceActiveFocus()
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                root.selectedTab = Math.min(root.selectedTab + 1, root.tabButtonList.length - 1)
                event.accepted = true;
            } 
            else if (event.key === Qt.Key_PageUp) {
                root.selectedTab = Math.max(root.selectedTab - 1, 0)
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Tab) {
                root.selectedTab = (root.selectedTab + 1) % root.tabButtonList.length;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Backtab) {
                root.selectedTab = (root.selectedTab - 1 + root.tabButtonList.length) % root.tabButtonList.length;
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: sidebarPadding
        spacing: sidebarPadding

        // Header Row - Quick Scratchpad App Launchers
        RowLayout {
            Layout.fillHeight: false
            spacing: 10
            Layout.margins: 10
            Layout.topMargin: 5
            Layout.bottomMargin: 0

            MaterialSymbol {
                iconSize: 16
                fill: 0
                color: Appearance.colors.colOnLayer0
                text: "apps"
            }

            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer0
                text: "Quick Apps"
            }

            Item {
                Layout.fillWidth: true
            }

            ButtonGroup {
                GroupButton {
                    baseWidth: 35
                    baseHeight: 35
                    buttonRadius: 17
                    toggled: false

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        iconSize: 18
                        fill: 0
                        color: Appearance.colors.colOnLayer1
                        text: "trending_up"
                    }

                    onClicked: {
                        Hyprland.dispatch("togglespecialworkspace", "firefox");
                        Quickshell.execDetached(["bash", "-c", "sleep 0.2 && hyprctl dispatch movetoworkspacesilent special:firefox,^(firefox)$"]);
                        Quickshell.execDetached(["firefox", "https://meroshare.cdsc.com.np/#/login", "https://keep.google.com"]);
                    }

                    StyledToolTip {
                        text: "Meroshare"
                    }
                }

                GroupButton {
                    baseWidth: 35
                    baseHeight: 35
                    buttonRadius: 17
                    toggled: false

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        iconSize: 18
                        fill: 0
                        color: Appearance.colors.colOnLayer1
                        text: "mail"
                    }

                    onClicked: {
                        Hyprland.dispatch("togglespecialworkspace", "firefox");
                        Quickshell.execDetached(["bash", "-c", "sleep 0.2 && hyprctl dispatch movetoworkspacesilent special:firefox,^(firefox)$"]);
                        Quickshell.execDetached(["firefox", "https://gmail.com"]);
                    }

                    StyledToolTip {
                        text: "Gmail"
                    }
                }

                GroupButton {
                    baseWidth: 35
                    baseHeight: 35
                    buttonRadius: 17
                    toggled: false

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        iconSize: 18
                        fill: 0
                        color: Appearance.colors.colOnLayer1
                        text: "chess"
                    }

                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "brave --new-window https://chess.com & sleep 0.3 && hyprctl dispatch fullscreen 1"]);
                    }

                    StyledToolTip {
                        text: "Chess.com"
                    }
                }

                GroupButton {
                    baseWidth: 35
                    baseHeight: 35
                    buttonRadius: 17
                    toggled: false

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        iconSize: 18
                        fill: 0
                        color: Appearance.colors.colOnLayer1
                        text: "music_note"
                    }

                    onClicked: {
                        Hyprland.dispatch("togglespecialworkspace", "spotify");
                        Quickshell.execDetached(["bash", "-c", "sleep 0.2 && hyprctl dispatch movetoworkspacesilent special:spotify,^(spotify|Spotify)$"]);
                        Quickshell.execDetached(["spotify"]);
                    }

                    StyledToolTip {
                        text: "Spotify"
                    }
                }
            }
        }

        // Quick Toggles Bar - 365 and DSA
        ButtonGroup {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5
            padding: 5
            color: Appearance.colors.colLayer1

            GroupButton {
                baseWidth: 40
                baseHeight: 40
                buttonRadius: 20
                toggled: false

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: 20
                    fill: 0
                    color: Appearance.colors.colOnLayer1
                    text: "school"
                }

                onClicked: {
                    Quickshell.execDetached(["code", "/home/sam/Github/365DaysOfData"]);
                    Quickshell.execDetached(["bash", "-c", "brave --new-window https://github.com/paudelsamir/365DaysOfData & sleep 0.3 && hyprctl dispatch fullscreen 1"]);
                }

                StyledToolTip {
                    text: "365: AI Learning & Worklog"
                }
            }

            GroupButton {
                baseWidth: 40
                baseHeight: 40
                buttonRadius: 20
                toggled: false

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: 20
                    fill: 0
                    color: Appearance.colors.colOnLayer1
                    text: "code"
                }

                onClicked: {
                    Quickshell.execDetached(["code", "/home/sam/Github/Coding-Interview-Preparation"]);
                    Quickshell.execDetached(["brave", "--new-window", "https://neetcode.io/practice", "https://leetcode.com/problemset/all/"]);
                }

                StyledToolTip {
                    text: "DSA: Interview Prep Workspace"
                }
            }
        }

        // Top Section - Todo/Monthly Goals (60% of sidebar)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.6
            color: Appearance.colors.colLayer1
            radius: Appearance.rounding.normal
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                PrimaryTabBar { // Tab strip
                    id: tabBar
                    Layout.fillHeight: false
                    tabButtonList: root.tabButtonList
                    externalTrackedTab: root.selectedTab
                    function onCurrentIndexChanged(currentIndex) {
                        root.selectedTab = currentIndex
                    }
                }

                StackLayout {
                    id: stackView
                    Layout.topMargin: 5
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    currentIndex: root.selectedTab

                    TodoWidget {}

                    WorkoutTracker {}
                }
            }
        }

        // Bottom Section - Timer Tools (40% of sidebar)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.4
            color: Appearance.colors.colLayer1
            radius: Appearance.rounding.normal
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                TimerTools {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }
}