import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    property int currentTab: 0
    property var tabButtonList: [{"icon": "flag", "name": Translation.tr("This Month")}, {"name": Translation.tr("Completed"), "icon": "check_circle"}]
    property bool showAddDialog: false
    property int dialogMargins: 20
    property int fabSize: 48
    property int fabMargins: 14
    
    // Built-in goals management
    property var goalsList: []
    property string goalsFilePath: Directories.state + "/user/monthly-goals.json"
    
    function getCurrentMonth() {
        return new Date().toLocaleDateString(Qt.locale(), "yyyy-MM")
    }
    
    function getCurrentMonthGoals() {
        const currentMonth = getCurrentMonth()
        return goalsList.filter(item => item.month === currentMonth)
    }
    
    function addGoal(content) {
        const goal = {
            "content": content,
            "done": false,
            "month": getCurrentMonth(),
            "createdAt": Date.now()
        }
        goalsList.push(goal)
        root.goalsList = goalsList.slice(0) // Trigger property change
        saveGoals()
    }
    
    function markDone(index) {
        if (index >= 0 && index < goalsList.length) {
            goalsList[index].done = true
            root.goalsList = goalsList.slice(0) // Trigger property change
            saveGoals()
        }
    }
    
    function markUnfinished(index) {
        if (index >= 0 && index < goalsList.length) {
            goalsList[index].done = false
            root.goalsList = goalsList.slice(0) // Trigger property change
            saveGoals()
        }
    }
    
    function deleteGoal(index) {
        if (index >= 0 && index < goalsList.length) {
            goalsList.splice(index, 1)
            root.goalsList = goalsList.slice(0) // Trigger property change
            saveGoals()
        }
    }
    
    function saveGoals() {
        goalsFileView.setText(JSON.stringify(goalsList))
    }
    
    function loadGoals() {
        goalsFileView.reload()
    }
    
    Component.onCompleted: {
        loadGoals()
    }
    
    FileView {
        id: goalsFileView
        path: Qt.resolvedUrl("file://" + goalsFilePath)
        onLoaded: {
            try {
                const fileContents = goalsFileView.text()
                root.goalsList = JSON.parse(fileContents)
                console.log("[Monthly Goals] File loaded with", root.goalsList.length, "goals")
            } catch (e) {
                console.log("[Monthly Goals] Error parsing file:", e)
                root.goalsList = []
            }
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                console.log("[Monthly Goals] File not found, creating new file.")
                root.goalsList = []
                saveGoals()
            } else {
                console.log("[Monthly Goals] Error loading file: " + error)
                root.goalsList = []
            }
        }
    }

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                currentTab = Math.min(currentTab + 1, root.tabButtonList.length - 1)
            } else if (event.key === Qt.Key_PageUp) {
                currentTab = Math.max(currentTab - 1, 0)
            }
            event.accepted = true;
        }
        // Open add dialog on "N" (any modifiers)
        else if (event.key === Qt.Key_N) {
            root.showAddDialog = true
            event.accepted = true;
        }
        // Close dialog on Esc if open
        else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: currentTab
            onCurrentIndexChanged: currentTab = currentIndex

            background: Item {
                WheelHandler {
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                            tabBar.currentIndex = Math.min(tabBar.currentIndex + 1, root.tabButtonList.length - 1)
                        else if (event.angleDelta.y > 0)
                            tabBar.currentIndex = Math.max(tabBar.currentIndex - 1, 0)
                    }
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                }
            }

            Repeater {
                model: root.tabButtonList
                delegate: SecondaryTabButton {
                    selected: (index == currentTab)
                    buttonText: modelData.name
                    buttonIcon: modelData.icon
                }
            }
        }

        Item { // Tab indicator
            id: tabIndicator
            Layout.fillWidth: true
            height: 3
            property bool enableIndicatorAnimation: false
            Connections {
                target: root
                function onCurrentTabChanged() {
                    tabIndicator.enableIndicatorAnimation = true
                }
            }

            Rectangle {
                id: indicator
                property int tabCount: root.tabButtonList.length
                property real fullTabSize: root.width / tabCount;
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

        Rectangle { // Tabbar bottom border
            id: tabBarBottomBorder
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            currentIndex: currentTab
            onCurrentIndexChanged: {
                tabIndicator.enableIndicatorAnimation = true
                currentTab = currentIndex
            }

            // This Month tab
            ScrollView {
                id: thisMonthScrollView
                clip: true
                
                ListView {
                    id: thisMonthList
                    model: getCurrentMonthGoals().filter(function(item) { return !item.done; })
                    spacing: 5
                    
                    delegate: Rectangle {
                        width: thisMonthList.width
                        height: 60
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer2
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            RippleButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                buttonRadius: 15
                                colBackground: "transparent"
                                colBackgroundHover: Appearance.colors.colPrimary
                                
                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "check"
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.colOnLayer2
                                }
                                
                                onClicked: {
                                    var originalIndex = root.goalsList.findIndex(goal => 
                                        goal.content === modelData.content && 
                                        goal.month === modelData.month && 
                                        goal.createdAt === modelData.createdAt
                                    )
                                    if (originalIndex >= 0) {
                                        root.markDone(originalIndex)
                                    }
                                }
                            }
                            
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.content
                                wrapMode: Text.WordWrap
                                color: Appearance.colors.colOnLayer2
                            }
                            
                            RippleButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                buttonRadius: 15
                                colBackground: "transparent"
                                colBackgroundHover: "#ef4444"
                                
                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "delete"
                                    iconSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colError
                                }
                                
                                onClicked: {
                                    var originalIndex = root.goalsList.findIndex(goal => 
                                        goal.content === modelData.content && 
                                        goal.month === modelData.month && 
                                        goal.createdAt === modelData.createdAt
                                    )
                                    if (originalIndex >= 0) {
                                        root.deleteGoal(originalIndex)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Empty state
                Item {
                    visible: getCurrentMonthGoals().filter(function(item) { return !item.done; }).length === 0
                    anchors.fill: parent
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        width: Math.min(parent.width * 0.8, 300)
                        
                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            text: "flag"
                            iconSize: 48
                            color: Appearance.colors.colOutlineVariant
                        }
                        
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: parent.width
                            text: Translation.tr("No goals this month!")
                            color: Appearance.colors.colOutlineVariant
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }
                    }
                }
            }
            
            // Completed tab
            ScrollView {
                id: completedScrollView
                clip: true
                
                ListView {
                    id: completedList
                    model: getCurrentMonthGoals().filter(function(item) { return item.done; })
                    spacing: 5
                    
                    delegate: Rectangle {
                        width: completedList.width
                        height: 60
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            RippleButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                buttonRadius: 15
                                colBackground: Appearance.colors.colSecondary
                                colBackgroundHover: "transparent"
                                
                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "check"
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: "white"
                                }
                                
                                onClicked: {
                                    var originalIndex = root.goalsList.findIndex(goal => 
                                        goal.content === modelData.content && 
                                        goal.month === modelData.month && 
                                        goal.createdAt === modelData.createdAt
                                    )
                                    if (originalIndex >= 0) {
                                        root.markUnfinished(originalIndex)
                                    }
                                }
                            }
                            
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.content
                                wrapMode: Text.WordWrap
                                color: Appearance.colors.colOutlineVariant
                                font.strikeout: true
                            }
                            
                            RippleButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                buttonRadius: 15
                                colBackground: "transparent"
                                colBackgroundHover: "#ef4444"
                                
                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "delete"
                                    iconSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colError
                                }
                                
                                onClicked: {
                                    var originalIndex = root.goalsList.findIndex(goal => 
                                        goal.content === modelData.content && 
                                        goal.month === modelData.month && 
                                        goal.createdAt === modelData.createdAt
                                    )
                                    if (originalIndex >= 0) {
                                        root.deleteGoal(originalIndex)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Empty state
                Item {
                    visible: getCurrentMonthGoals().filter(function(item) { return item.done; }).length === 0
                    anchors.fill: parent
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        width: Math.min(parent.width * 0.8, 300)
                        
                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            text: "check_circle"
                            iconSize: 48
                            color: Appearance.colors.colOutlineVariant
                        }
                        
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: parent.width
                            text: Translation.tr("Completed goals will appear here")
                            color: Appearance.colors.colOutlineVariant
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }
                    }
                }
            }
        }
    }

    // + FAB
    StyledRectangularShadow {
        target: fabButton
        radius: fabButton.buttonRadius
        blur: 0.6 * Appearance.sizes.elevationMargin
    }
    FloatingActionButton {
        id: fabButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.fabMargins
        anchors.bottomMargin: root.fabMargins

        onClicked: root.showAddDialog = true

        contentItem: MaterialSymbol {
            text: "add"
            horizontalAlignment: Text.AlignHCenter
            iconSize: Appearance.font.pixelSize.huge
            color: Appearance.m3colors.m3onPrimaryContainer
        }
    }

    Item {
        anchors.fill: parent
        z: 9999

        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0
        Behavior on opacity {
            NumberAnimation { 
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }

        onVisibleChanged: {
            if (!visible) {
                goalInput.text = ""
                fabButton.focus = true
            }
        }

        Rectangle { // Scrim
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Appearance.colors.colScrim
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }
        }

        Rectangle { // The dialog
            id: dialog
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            implicitHeight: dialogColumnLayout.implicitHeight

            color: Appearance.colors.colSurfaceContainerHigh
            radius: Appearance.rounding.normal

            function addGoal() {
                if (goalInput.text.length > 0) {
                    root.addGoal(goalInput.text)
                    goalInput.text = ""
                    root.showAddDialog = false
                    root.currentTab = 0 // Show this month's goals
                }
            }

            ColumnLayout {
                id: dialogColumnLayout
                anchors.fill: parent
                spacing: 16

                StyledText {
                    Layout.topMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignLeft
                    color: Appearance.m3colors.m3onSurface
                    font.pixelSize: Appearance.font.pixelSize.larger
                    text: Translation.tr("Add monthly goal")
                }

                TextField {
                    id: goalInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: activeFocus ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                    selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                    selectionColor: Appearance.colors.colSecondaryContainer
                    placeholderText: Translation.tr("Goal description")
                    placeholderTextColor: Appearance.m3colors.m3outline
                    focus: root.showAddDialog
                    onAccepted: dialog.addGoal()

                    background: Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.verysmall
                        border.width: 2
                        border.color: goalInput.activeFocus ? Appearance.colors.colPrimary : Appearance.m3colors.m3outline
                        color: "transparent"
                    }

                    cursorDelegate: Rectangle {
                        width: 1
                        color: goalInput.activeFocus ? Appearance.colors.colPrimary : "transparent"
                        radius: 1
                    }
                }

                RowLayout {
                    Layout.bottomMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignRight
                    spacing: 5

                    DialogButton {
                        buttonText: Translation.tr("Cancel")
                        onClicked: root.showAddDialog = false
                    }
                    DialogButton {
                        buttonText: Translation.tr("Add")
                        enabled: goalInput.text.length > 0
                        onClicked: dialog.addGoal()
                    }
                }
            }
        }
    }
}