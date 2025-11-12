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
                        // Position countdown popup to align under its widget
                        // It's in the right center area, slightly left of center
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
                    
                    property int currentTab: 0 // 0 = Main Goal, 1 = Events

                    // Header with tabs
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
                                text: Translation.tr("Countdown Manager")
                                font {
                                    weight: Font.Medium
                                    pixelSize: Appearance.font.pixelSize.normal
                                }
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                        }
                        
                        // Tab buttons
                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Rectangle {
                                width: 100
                                height: 24
                                radius: Appearance.rounding.extraSmall
                                color: contentColumn.currentTab === 0 ? 
                                       ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2) :
                                       "transparent"
                                border.width: 1
                                border.color: contentColumn.currentTab === 0 ?
                                              ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.2) :
                                              "transparent"
                                              
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                              
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: contentColumn.currentTab = 0
                                }
                                
                                StyledText {
                                    anchors.centerIn: parent
                                    text: Translation.tr("Main Goal")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    opacity: contentColumn.currentTab === 0 ? 1.0 : 0.5
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }
                            
                            Rectangle {
                                width: 100
                                height: 24
                                radius: Appearance.rounding.extraSmall
                                color: contentColumn.currentTab === 1 ? 
                                       ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2) :
                                       "transparent"
                                border.width: 1
                                border.color: contentColumn.currentTab === 1 ?
                                              ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.2) :
                                              "transparent"
                                              
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                              
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: contentColumn.currentTab = 1
                                }
                                
                                StyledText {
                                    anchors.centerIn: parent
                                    text: Translation.tr("Events")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    opacity: contentColumn.currentTab === 1 ? 1.0 : 0.5
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }
                        }
                    }

                    // Main Goal Tab Content
                    Column {
                        visible: contentColumn.currentTab === 0
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
                    
                    // Events Tab Content
                    Column {
                        visible: contentColumn.currentTab === 1
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        Layout.fillWidth: true
                        
                        // Add Event Form
                        Column {
                            width: 280
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            
                            // Event Name Input
                            Rectangle {
                                width: parent.width
                                height: 32
                                color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                radius: Appearance.rounding.extraSmall
                                border.width: 1
                                border.color: eventNameInput.activeFocus ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                TextInput {
                                    id: eventNameInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    clip: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    
                                    Text {
                                        visible: parent.text.length === 0 && !parent.activeFocus
                                        text: "Event name"
                                        font: parent.font
                                        color: ColorUtils.applyAlpha(parent.color, 0.4)
                                        verticalAlignment: parent.verticalAlignment
                                    }
                                }
                            }
                            
                            // Event Date Input with format helper
                            RowLayout {
                                width: parent.width
                                spacing: 6
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                    radius: Appearance.rounding.extraSmall
                                    border.width: 1
                                    border.color: eventDateInput.activeFocus ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                    TextInput {
                                        id: eventDateInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnSurfaceVariant
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        inputMask: "9999-99-99"
                                        
                                        property bool isValidDate: {
                                            if (text.length !== 10) return false
                                            var parts = text.split("-")
                                            if (parts.length !== 3) return false
                                            var year = parseInt(parts[0])
                                            var month = parseInt(parts[1])
                                            var day = parseInt(parts[2])
                                            if (isNaN(year) || isNaN(month) || isNaN(day)) return false
                                            if (month < 1 || month > 12) return false
                                            if (day < 1 || day > 31) return false
                                            var testDate = new Date(year, month - 1, day)
                                            return testDate.getFullYear() === year && 
                                                   testDate.getMonth() === month - 1 && 
                                                   testDate.getDate() === day
                                        }
                                        
                                        Text {
                                            visible: parent.text.length === 0 && !parent.activeFocus
                                            text: "YYYY-MM-DD"
                                            font: parent.font
                                            color: ColorUtils.applyAlpha(parent.color, 0.4)
                                            verticalAlignment: parent.verticalAlignment
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 32
                                    radius: Appearance.rounding.extraSmall
                                    color: todayButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.8) :
                                           todayButton.hovered ? ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.6) :
                                           ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                    border.width: 1
                                    border.color: todayButton.hovered ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    
                                    MouseArea {
                                        id: todayButton
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            var today = new Date()
                                            var year = today.getFullYear()
                                            var month = ("0" + (today.getMonth() + 1)).slice(-2)
                                            var day = ("0" + today.getDate()).slice(-2)
                                            eventDateInput.text = year + "-" + month + "-" + day
                                        }
                                        
                                        StyledText {
                                            anchors.centerIn: parent
                                            text: Translation.tr("Today")
                                            font.pixelSize: Appearance.font.pixelSize.extraSmall
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                    }
                                }
                            }
                            
                            // Category Selection
                            Row {
                                id: categoryRow
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                property string selectedCategory: "event"
                                
                                Repeater {
                                    model: [
                                        {name: "birthday", icon: "cake"},
                                        {name: "exam", icon: "school"},
                                        {name: "meeting", icon: "group"},
                                        {name: "event", icon: "event"}
                                    ]
                                    
                                    Rectangle {
                                        width: 60
                                        height: 32
                                        radius: Appearance.rounding.extraSmall
                                        color: categoryRow.selectedCategory === modelData.name ?
                                               ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.3) :
                                               (categoryMouseArea.containsMouse ? 
                                                ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.4) :
                                                ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2))
                                        border.width: 1
                                        border.color: categoryRow.selectedCategory === modelData.name ?
                                                     ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.6) :
                                                     (categoryMouseArea.containsMouse ?
                                                      ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.3) :
                                                      ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, 0.5))
                                        
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }
                                        
                                        MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: modelData.icon
                                            iconSize: Appearance.font.pixelSize.normal
                                            color: Appearance.colors.colOnSurfaceVariant
                                            opacity: categoryRow.selectedCategory === modelData.name ? 1.0 : 0.7
                                            Behavior on opacity { NumberAnimation { duration: 150 } }
                                        }
                                        
                                        MouseArea {
                                            id: categoryMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: categoryRow.selectedCategory = modelData.name
                                        }
                                    }
                                }
                            }
                            
                            // Add Button
                            Rectangle {
                                width: parent.width
                                height: 32
                                anchors.horizontalCenter: parent.horizontalCenter
                                radius: Appearance.rounding.extraSmall
                                color: addButton.enabled ? 
                                       (addButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.8) :
                                        addButton.hovered ? ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.7) :
                                        ColorUtils.applyAlpha(Appearance.colors.colAccent, 0.6)) :
                                       ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.3)
                                border.width: 1
                                border.color: addButton.enabled ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                Behavior on color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: addButton
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: eventNameInput.text.length > 0 && eventDateInput.isValidDate
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                    onClicked: {
                                        var events = []
                                        try {
                                            events = JSON.parse(GlobalStates.countdownEventsJson)
                                            if (!Array.isArray(events)) {
                                                events = []
                                            }
                                        } catch(e) {
                                            events = []
                                        }
                                        
                                        events.push({
                                            name: eventNameInput.text,
                                            date: eventDateInput.text,
                                            category: categoryRow.selectedCategory
                                        })
                                        
                                        GlobalStates.countdownEventsJson = JSON.stringify(events)
                                        
                                        // Clear inputs
                                        eventNameInput.text = ""
                                        eventDateInput.text = ""
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        
                                        MaterialSymbol {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "add"
                                            iconSize: Appearance.font.pixelSize.small
                                            color: addButton.enabled ? Appearance.colors.colOnSurfaceVariant : 
                                                   ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                        }
                                        
                                        StyledText {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: Translation.tr("Add Event")
                                            font.pixelSize: Appearance.font.pixelSize.small
                                            font.weight: Font.Medium
                                            color: addButton.enabled ? Appearance.colors.colOnSurfaceVariant : 
                                                   ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: 280
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Appearance.colors.colLayer0Border
                            opacity: 0.3
                        }
                        
                        // Events List
                        Column {
                            width: 280
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6
                            
                            StyledText {
                                text: Translation.tr("Your Events")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                            
                            Repeater {
                                id: eventsRepeater
                                model: {
                                    try {
                                        return JSON.parse(GlobalStates.countdownEventsJson)
                                    } catch(e) {
                                        return []
                                    }
                                }
                                
                                delegate: Item {
                                    width: 280
                                    height: 48
                                    
                                    Rectangle {
                                        id: eventRow
                                        anchors.fill: parent
                                        color: eventMouseArea.containsMouse ? 
                                               ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.4) :
                                               ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2)
                                        radius: Appearance.rounding.extraSmall
                                        border.width: 1
                                        border.color: eventMouseArea.containsMouse ?
                                                     ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.2) :
                                                     ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, 0.5)
                                        
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }
                                        
                                        MouseArea {
                                            id: eventMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10
                                            
                                            MaterialSymbol {
                                                Layout.alignment: Qt.AlignVCenter
                                                text: {
                                                    var category = modelData.category || "event"
                                                    if (category === "birthday") return "cake"
                                                    if (category === "exam") return "school"
                                                    if (category === "meeting") return "group"
                                                    return "event"
                                                }
                                                iconSize: Appearance.font.pixelSize.normal
                                                color: Appearance.colors.colOnSurfaceVariant
                                            }
                                            
                                            Column {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 3
                                                
                                                StyledText {
                                                    text: modelData.name
                                                    font.pixelSize: Appearance.font.pixelSize.small
                                                    font.weight: Font.Medium
                                                    color: Appearance.colors.colOnSurfaceVariant
                                                    elide: Text.ElideRight
                                                    width: parent.width
                                                }
                                                
                                                StyledText {
                                                    text: modelData.date
                                                    font.pixelSize: Appearance.font.pixelSize.extraSmall
                                                    color: Appearance.colors.colOnSurfaceVariant
                                                    opacity: 0.6
                                                }
                                            }
                                            
                                            Rectangle {
                                                Layout.preferredWidth: 28
                                                Layout.preferredHeight: 28
                                                Layout.alignment: Qt.AlignVCenter
                                                radius: Appearance.rounding.extraSmall
                                                color: deleteButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colError, 0.7) :
                                                       deleteButton.containsMouse ? ColorUtils.applyAlpha(Appearance.colors.colError, 0.5) :
                                                       "transparent"
                                                border.width: 1
                                                border.color: deleteButton.containsMouse ? 
                                                             ColorUtils.applyAlpha(Appearance.colors.colError, 0.6) : 
                                                             "transparent"
                                                
                                                Behavior on color { ColorAnimation { duration: 150 } }
                                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                                
                                                MaterialSymbol {
                                                    anchors.centerIn: parent
                                                    text: "delete"
                                                    iconSize: Appearance.font.pixelSize.small
                                                    color: Appearance.colors.colOnSurfaceVariant
                                                }
                                                
                                                MouseArea {
                                                    id: deleteButton
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    
                                                    onClicked: {
                                                        var events = []
                                                        try {
                                                            events = JSON.parse(GlobalStates.countdownEventsJson)
                                                        } catch(e) {}
                                                        
                                                        events.splice(index, 1)
                                                        GlobalStates.countdownEventsJson = JSON.stringify(events)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            StyledText {
                                visible: eventsRepeater.count === 0
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("No events yet. Add one above!")
                                font.pixelSize: Appearance.font.pixelSize.extraSmall
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.5
                            }
                        }
                    }
                }
            }
        }
    }
}
