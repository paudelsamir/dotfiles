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
                implicitWidth: contentColumn.implicitWidth + 24
                implicitHeight: contentColumn.implicitHeight + 24
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
                    width: parent.width - 24

                    property int currentTab: 0

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

                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: 80
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
                                width: 80
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
                                    text: Translation.tr("Active")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    opacity: contentColumn.currentTab === 1 ? 1.0 : 0.5
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }

                            Rectangle {
                                width: 80
                                height: 24
                                radius: Appearance.rounding.extraSmall
                                color: contentColumn.currentTab === 2 ?
                                       ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2) :
                                       "transparent"
                                border.width: 1
                                border.color: contentColumn.currentTab === 2 ?
                                              ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.2) :
                                              "transparent"

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: contentColumn.currentTab = 2
                                }

                                StyledText {
                                    anchors.centerIn: parent
                                    text: Translation.tr("Completed")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    opacity: contentColumn.currentTab === 2 ? 1.0 : 0.5
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }
                        }
                    }

                    // --- Main Goal Tab ---
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

                        // Date input: year / month / day fields
                        RowLayout {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter

                            function buildDate(): string {
                                var y = yearInput.text.padStart(4, "0")
                                var m = monthInput.text.padStart(2, "0")
                                var d = dayInput.text.padStart(2, "0")
                                return y + "-" + m + "-" + d
                            }

                            function isValidDate(): bool {
                                var text = buildDate()
                                if (text.length !== 10) return false
                                var parts = text.split('-')
                                if (parts.length !== 3) return false
                                var year = parseInt(parts[0])
                                var month = parseInt(parts[1])
                                var day = parseInt(parts[2])
                                if (isNaN(year) || isNaN(month) || isNaN(day)) return false
                                if (month < 1 || month > 12) return false
                                if (day < 1 || day > 31) return false
                                var date = new Date(year, month - 1, day)
                                return date.getFullYear() === year &&
                                       date.getMonth() === month - 1 &&
                                       date.getDate() === day
                            }

                            // Year
                            Rectangle {
                                Layout.preferredWidth: 70
                                Layout.preferredHeight: 32
                                color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                radius: Appearance.rounding.extraSmall
                                border.width: 1
                                border.color: yearInput.activeFocus ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                TextInput {
                                    id: yearInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    selectByMouse: true
                                    inputMask: "9999"
                                    maximumLength: 4

                                    text: GlobalStates.countdownTargetDate ?
                                          GlobalStates.countdownTargetDate.split('-')[0] : ""

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "YYYY"
                                        color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                        visible: parent.text.length === 0 && !parent.activeFocus
                                        font.pixelSize: parent.font.pixelSize
                                    }
                                }
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: "/"
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.5
                            }

                            // Month
                            Rectangle {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 32
                                color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                radius: Appearance.rounding.extraSmall
                                border.width: 1
                                border.color: monthInput.activeFocus ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                TextInput {
                                    id: monthInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    selectByMouse: true
                                    inputMask: "99"
                                    maximumLength: 2

                                    text: GlobalStates.countdownTargetDate ?
                                          GlobalStates.countdownTargetDate.split('-')[1] : ""

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "MM"
                                        color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                        visible: parent.text.length === 0 && !parent.activeFocus
                                        font.pixelSize: parent.font.pixelSize
                                    }
                                }
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: "/"
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.5
                            }

                            // Day
                            Rectangle {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 32
                                color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
                                radius: Appearance.rounding.extraSmall
                                border.width: 1
                                border.color: dayInput.activeFocus ? Appearance.colors.colAccent : Appearance.colors.colLayer0Border

                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                TextInput {
                                    id: dayInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnSurfaceVariant
                                    selectByMouse: true
                                    inputMask: "99"
                                    maximumLength: 2

                                    text: GlobalStates.countdownTargetDate ?
                                          GlobalStates.countdownTargetDate.split('-')[2] : ""

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "DD"
                                        color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                        visible: parent.text.length === 0 && !parent.activeFocus
                                        font.pixelSize: parent.font.pixelSize
                                    }
                                }
                            }

                            // Save button
                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 32
                                radius: Appearance.rounding.extraSmall
                                color: saveMainButton.enabled ?
                                       (saveMainButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.3) :
                                        saveMainButton.hovered ? ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.2) :
                                        ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.15)) :
                                       ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.1)
                                border.width: 1
                                border.color: saveMainButton.enabled ?
                                             ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.2) :
                                             ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, 0.2)

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: saveMainButton
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: parent.parent.isValidDate()
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                    onClicked: {
                                        GlobalStates.countdownTargetDate = parent.parent.buildDate()
                                        GlobalStates.countdownPopupOpen = false
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: Translation.tr("Save")
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Medium
                                        color: parent.enabled ? Appearance.colors.colOnSurfaceVariant :
                                               ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                    }
                                }
                            }
                        }
                    }

                    // --- Active Events Tab ---
                    Column {
                        visible: contentColumn.currentTab === 1
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        Layout.fillWidth: true

                        Column {
                            width: 280
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

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

                                    StyledText {
                                        visible: parent.text.length === 0 && !parent.activeFocus
                                        text: "Event name"
                                        font: parent.font
                                        color: ColorUtils.applyAlpha(parent.color, 0.4)
                                        verticalAlignment: parent.verticalAlignment
                                    }
                                }
                            }

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

                                        StyledText {
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

                            // Category selection
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

                            // Add button
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
                                            if (!Array.isArray(events)) events = []
                                        } catch(e) {
                                            events = []
                                        }

                                        events.push({
                                            name: eventNameInput.text,
                                            date: eventDateInput.text,
                                            category: categoryRow.selectedCategory
                                        })

                                        GlobalStates.countdownEventsJson = JSON.stringify(events)

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

                        Column {
                            width: 280
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6

                            StyledText {
                                text: Translation.tr("Active Events")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                            }

                            Repeater {
                                id: eventsRepeater
                                model: {
                                    try {
                                        var allEvents = JSON.parse(GlobalStates.countdownEventsJson)
                                        return allEvents.filter(function(e) { return !e.done })
                                    } catch(e) {
                                        return []
                                    }
                                }

                                delegate: Item {
                                    width: 280
                                    height: 48
                                    readonly property int actualIndex: {
                                        try {
                                            var allEvents = JSON.parse(GlobalStates.countdownEventsJson)
                                            for (var i = 0; i < allEvents.length; i++) {
                                                if (allEvents[i].name === modelData.name &&
                                                    allEvents[i].date === modelData.date &&
                                                    !allEvents[i].done) {
                                                    return i
                                                }
                                            }
                                        } catch(e) {}
                                        return -1
                                    }

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
                                                    var cat = modelData.category || "event"
                                                    if (cat === "birthday") return "cake"
                                                    if (cat === "exam") return "school"
                                                    if (cat === "meeting") return "group"
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
                                                color: doneButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.7) :
                                                       doneButton.containsMouse ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.5) :
                                                       "transparent"
                                                border.width: 1
                                                border.color: doneButton.containsMouse ?
                                                             ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.6) :
                                                             "transparent"

                                                Behavior on color { ColorAnimation { duration: 150 } }
                                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                                MaterialSymbol {
                                                    anchors.centerIn: parent
                                                    text: "check"
                                                    iconSize: Appearance.font.pixelSize.small
                                                    color: Appearance.colors.colOnSurfaceVariant
                                                }

                                                MouseArea {
                                                    id: doneButton
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor

                                                    onClicked: {
                                                        var events = []
                                                        try {
                                                            events = JSON.parse(GlobalStates.countdownEventsJson)
                                                        } catch(e) {}

                                                        var idx = doneButton.parent.parent.parent.parent.parent.actualIndex
                                                        if (idx >= 0 && idx < events.length) {
                                                            events[idx].done = true
                                                            GlobalStates.countdownEventsJson = JSON.stringify(events)
                                                        }
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
                                text: Translation.tr("No active events. Add one above!")
                                font.pixelSize: Appearance.font.pixelSize.extraSmall
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.5
                            }
                        }
                    }

                    // --- Completed Events Tab ---
                    Column {
                        visible: contentColumn.currentTab === 2
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        Layout.fillWidth: true

                        Column {
                            width: 280
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6

                            StyledText {
                                text: Translation.tr("Completed Events")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                            }

                            Repeater {
                                id: completedRepeater
                                model: {
                                    try {
                                        var allEvents = JSON.parse(GlobalStates.countdownEventsJson)
                                        return allEvents.filter(function(e) { return e.done })
                                    } catch(e) {
                                        return []
                                    }
                                }

                                delegate: Item {
                                    width: 280
                                    height: 48
                                    readonly property int actualIndex: {
                                        try {
                                            var allEvents = JSON.parse(GlobalStates.countdownEventsJson)
                                            for (var i = 0; i < allEvents.length; i++) {
                                                if (allEvents[i].name === modelData.name &&
                                                    allEvents[i].date === modelData.date &&
                                                    allEvents[i].done === true) {
                                                    return i
                                                }
                                            }
                                        } catch(e) {}
                                        return -1
                                    }

                                    Rectangle {
                                        id: completedRow
                                        anchors.fill: parent
                                        color: completedMouseArea.containsMouse ?
                                               ColorUtils.applyAlpha(Appearance.colors.colTertiary, 0.2) :
                                               ColorUtils.applyAlpha(Appearance.colors.colTertiary, 0.1)
                                        radius: Appearance.rounding.extraSmall
                                        border.width: 1
                                        border.color: completedMouseArea.containsMouse ?
                                                     ColorUtils.applyAlpha(Appearance.colors.colTertiary, 0.3) :
                                                     ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, 0.3)

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            id: completedMouseArea
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
                                                    var cat = modelData.category || "event"
                                                    if (cat === "birthday") return "cake"
                                                    if (cat === "exam") return "school"
                                                    if (cat === "meeting") return "group"
                                                    return "event"
                                                }
                                                iconSize: Appearance.font.pixelSize.normal
                                                color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.5)
                                            }

                                            Column {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 3

                                                StyledText {
                                                    text: modelData.name
                                                    font.pixelSize: Appearance.font.pixelSize.small
                                                    font.weight: Font.Medium
                                                    color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.6)
                                                    elide: Text.ElideRight
                                                    width: parent.width
                                                    font.strikeout: true
                                                }

                                                StyledText {
                                                    text: modelData.date
                                                    font.pixelSize: Appearance.font.pixelSize.extraSmall
                                                    color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.4)
                                                }
                                            }

                                            Row {
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 6

                                                Rectangle {
                                                    width: 28
                                                    height: 28
                                                    radius: Appearance.rounding.extraSmall
                                                    color: revertButton.pressed ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.7) :
                                                           revertButton.containsMouse ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.5) :
                                                           "transparent"
                                                    border.width: 1
                                                    border.color: revertButton.containsMouse ?
                                                                 ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.6) :
                                                                 "transparent"

                                                    Behavior on color { ColorAnimation { duration: 150 } }
                                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                                    MaterialSymbol {
                                                        anchors.centerIn: parent
                                                        text: "undo"
                                                        iconSize: Appearance.font.pixelSize.small
                                                        color: Appearance.colors.colOnSurfaceVariant
                                                    }

                                                    MouseArea {
                                                        id: revertButton
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor

                                                        onClicked: {
                                                            var events = []
                                                            try {
                                                                events = JSON.parse(GlobalStates.countdownEventsJson)
                                                            } catch(e) {}

                                                            var idx = revertButton.parent.parent.parent.parent.parent.actualIndex
                                                            if (idx >= 0 && idx < events.length) {
                                                                events[idx].done = false
                                                                GlobalStates.countdownEventsJson = JSON.stringify(events)
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: 28
                                                    height: 28
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

                                                            var idx = deleteButton.parent.parent.parent.parent.parent.actualIndex
                                                            if (idx >= 0 && idx < events.length) {
                                                                events.splice(idx, 1)
                                                                GlobalStates.countdownEventsJson = JSON.stringify(events)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            StyledText {
                                visible: completedRepeater.count === 0
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("No completed events yet!")
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
