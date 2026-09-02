pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.background.widgets

AbstractBackgroundWidget {
    id: root

    configEntryName: "custom.day-countdown"

    semanticPaletteControls: true
    semanticPaletteQuickControls: true

    defaultConfig: ({
        placementStrategy: "free",
        widgetScale: 100, widgetOpacity: 100, colorMode: "auto", dim: 0,
        showBackground: true, useBlur: false, showBorder: false,
        backgroundOpacity: 0.08, borderWidth: 0, borderOpacity: 0,
        cornerRadius: -1,
        contentWidth: 280, contentHeight: 200,
        maxEvents: 5, dateRange: 365,
        showProgress: true, showTime: true, showCategory: true,
        x: 200, y: 200
    })

    implicitWidth: Math.round(Number(root._readConfigKey("contentWidth") ?? 280) * root.scaleFactor)
    implicitHeight: Math.round(Number(root._readConfigKey("contentHeight") ?? 200) * root.scaleFactor)

    visibleWhenLocked: true
    needsColText: true
    resizableAxes: ({ width: "contentWidth", height: "contentHeight" })
    resizeMinWidth: 160
    resizeMinHeight: 100
    resizeMaxWidth: 600
    resizeMaxHeight: 800

    readonly property int cfgMaxEvents: Number(root._readConfigKey("maxEvents") ?? 5)
    readonly property int cfgDateRange: Number(root._readConfigKey("dateRange") ?? 365)
    readonly property bool cfgShowProgress: Boolean(root._readConfigKey("showProgress") ?? true)
    readonly property bool cfgShowTime: Boolean(root._readConfigKey("showTime") ?? true)
    readonly property bool cfgShowCategory: Boolean(root._readConfigKey("showCategory") ?? true)

    readonly property real s: root.scaleFactor
    readonly property color accent: root.widgetAccentVisible
    readonly property color onAccent: root.widgetSemanticOnColor(root.widgetPrimaryRole)

    property int _refreshTrigger: 0
    Connections {
        target: Events
        function onEventAdded() { root._refreshTrigger++ }
        function onEventRemoved() { root._refreshTrigger++ }
        function onEventUpdated() { root._refreshTrigger++ }
    }
    Connections {
        target: CalendarSync
        function onEventsUpdated() { root._refreshTrigger++ }
    }

    readonly property var upcomingEvents: {
        const _t = root._refreshTrigger
        return root._buildList()
    }

    function _buildList(): var {
        const now = new Date()
        const days = root.cfgDateRange
        const local = (typeof Events !== "undefined" && Events.getUpcomingEvents)
            ? Events.getUpcomingEvents(days).map(e => Object.assign({}, e, { _source: "local" }))
            : []

        const startDay = new Date(now)
        startDay.setHours(0, 0, 0, 0)
        const externalAll = []
        if (typeof CalendarSync !== "undefined") {
            for (let i = 0; i < days; i++) {
                const d = new Date(startDay)
                d.setDate(d.getDate() + i)
                const dayEvents = CalendarSync.getEventsForDate(d) || []
                for (const e of dayEvents) {
                    const evtTime = new Date(e.startDate || e.dateTime)
                    if (evtTime < now && !(e.allDay && evtTime >= startDay)) continue
                    externalAll.push(Object.assign({}, e, {
                        _source: "external",
                        dateTime: e.startDate || e.dateTime
                    }))
                }
            }
        }

        const all = local.concat(externalAll)
        all.sort((a, b) => new Date(a.dateTime || a.startDate) - new Date(b.dateTime || b.startDate))
        return all.slice(0, root.cfgMaxEvents)
    }

    function _daysRemaining(event): int {
        const dt = new Date(event.dateTime || event.startDate)
        if (isNaN(dt.getTime())) return 0
        const now = new Date()
        const diff = dt.getTime() - now.getTime()
        return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)))
    }

    function _formatDate(event): string {
        if (!event) return ""
        const dt = new Date(event.dateTime || event.startDate)
        if (isNaN(dt.getTime())) return ""
        const now = new Date()
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        const tomorrow = new Date(today)
        tomorrow.setDate(tomorrow.getDate() + 1)
        const eventDay = new Date(dt.getFullYear(), dt.getMonth(), dt.getDate())
        if (eventDay.getTime() === today.getTime()) return Translation.tr("Today")
        if (eventDay.getTime() === tomorrow.getTime()) return Translation.tr("Tomorrow")
        return Qt.formatDate(dt, "ddd, d MMM")
    }

    function _formatTime(event): string {
        if (!event || event.allDay) return ""
        const dt = new Date(event.dateTime || event.startDate)
        if (isNaN(dt.getTime())) return ""
        return Qt.formatTime(dt, "HH:mm")
    }

    function _categoryIcon(category): string {
        switch (category) {
            case "birthday": return "cake"
            case "meeting": return "groups"
            case "deadline": return "flag"
            case "reminder": return "notifications"
            default: return "event"
        }
    }

    function _eventColor(event): color {
        if (event._source === "external" && event.sourceColor)
            return event.sourceColor
        switch (event.priority) {
            case "high": return root.widgetSignal
            case "low": return ColorUtils.applyAlpha(root.accent, 0.4)
            default: return root.accent
        }
    }

    function _progressColor(progress): color {
        if (progress < 0.5) return Appearance.colors.colSuccess
        if (progress < 0.8) return Appearance.colors.colWarning
        return root.widgetSignal
    }

    editPopoverContent: Component {
        ColumnLayout {
            spacing: 6

            Row {
                spacing: 6
                Layout.alignment: Qt.AlignHCenter
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Translation.tr("Show:")
                    color: Appearance.colors.colOnLayer2
                    font.pixelSize: Appearance.font.pixelSize.small
                }
                Repeater {
                    model: [3, 5, 8, 12]
                    SelectionGroupButton {
                        required property var modelData
                        leftmost: modelData === 3
                        rightmost: modelData === 12
                        buttonText: String(modelData)
                        toggled: root.cfgMaxEvents === modelData
                        onClicked: Config.setNestedValue("background.widgets.custom.day-countdown.maxEvents", modelData)
                    }
                }
            }

            Row {
                spacing: 4
                Layout.alignment: Qt.AlignHCenter
                SelectionGroupButton {
                    leftmost: true; rightmost: true
                    buttonIcon: "linear_scale"
                    buttonText: Translation.tr("Progress")
                    toggled: root.cfgShowProgress
                    onClicked: Config.setNestedValue("background.widgets.custom.day-countdown.showProgress", !root.cfgShowProgress)
                }
                SelectionGroupButton {
                    leftmost: true; rightmost: true
                    buttonIcon: "schedule"
                    buttonText: Translation.tr("Time")
                    toggled: root.cfgShowTime
                    onClicked: Config.setNestedValue("background.widgets.custom.day-countdown.showTime", !root.cfgShowTime)
                }
                SelectionGroupButton {
                    leftmost: true; rightmost: true
                    buttonIcon: "category"
                    buttonText: Translation.tr("Category")
                    toggled: root.cfgShowCategory
                    onClicked: Config.setNestedValue("background.widgets.custom.day-countdown.showCategory", !root.cfgShowCategory)
                }
            }
        }
    }

    WidgetSurface {
        anchors.fill: parent
        regionBrightness: root.regionBrightness
        surfaceRadius: root.cornerRadiusOverride >= 0 ? root.cornerRadiusOverride : root.widgetCardRadius
        surfaceOpacity: root.backgroundOpacity
        surfaceBorderWidth: root.borderWidth
        surfaceBorderOpacity: root.borderOpacity
        surfaceColor: root.widgetSurfaceInk
        colorMode: root.colorMode
        surfaceAccent: root.widgetAccent
        surfaceUseBlur: root.effectiveBlur
        screenX: root.x
        screenY: root.y
        screenWidth: root.scaledScreenWidth
        screenHeight: root.scaledScreenHeight
        visible: root.backgroundOpacity > 0 || root.borderWidth > 0 || root.effectiveBlur
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Math.round(12 * root.s)
        spacing: 0
        clip: true

        RowLayout {
            Layout.fillWidth: true
            spacing: Math.round(6 * root.s)

            MaterialSymbol {
                text: "timer"
                iconSize: Math.round(14 * root.s)
                color: root.accent
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: Translation.tr("EVENTS COUNTDOWN")
                color: root.widgetInkMuted
                font.pixelSize: Math.round(Appearance.font.pixelSize.smaller * root.s)
                font.weight: Font.DemiBold
                font.letterSpacing: Math.round(1 * root.s)
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                visible: root.upcomingEvents.length > 0
                Layout.alignment: Qt.AlignVCenter
                width: eventCount.implicitWidth + Math.round(8 * root.s)
                height: eventCount.implicitHeight + Math.round(2 * root.s)
                radius: Math.round(8 * root.s)
                color: ColorUtils.applyAlpha(root.accent, 0.15)

                StyledText {
                    id: eventCount
                    anchors.centerIn: parent
                    text: root.upcomingEvents.length
                    color: root.accent
                    font.pixelSize: Math.round(Appearance.font.pixelSize.smallest * root.s)
                    font.family: Appearance.font.family.numbers
                    font.weight: Font.Bold
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: Math.round(6 * root.s)
            Layout.bottomMargin: Math.round(6 * root.s)
            color: ColorUtils.applyAlpha(root.widgetInk, 0.10)
        }

        Repeater {
            model: root.upcomingEvents

            delegate: ColumnLayout {
                id: eventRow
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.topMargin: index > 0 ? Math.round(10 * root.s) : 0
                spacing: Math.round(5 * root.s)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Math.round(12 * root.s)

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: Math.round(3 * root.s)
                        height: Math.round(30 * root.s)
                        radius: Math.round(2 * root.s)
                        color: root._eventColor(modelData)
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Math.round(6 * root.s)

                            MaterialSymbol {
                                visible: root.cfgShowCategory
                                text: root._categoryIcon(modelData?.category)
                                iconSize: Math.round(13 * root.s)
                                color: root.widgetInkMuted
                                Layout.alignment: Qt.AlignVCenter
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData?.title || Translation.tr("Untitled")
                                color: root.widgetInk
                                font.pixelSize: Math.round(Appearance.font.pixelSize.small * root.s)
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        StyledText {
                            text: {
                                const parts = []
                                parts.push(root._formatDate(modelData))
                                if (root.cfgShowTime) {
                                    const t = root._formatTime(modelData)
                                    if (t) parts.push(t)
                                }
                                return parts.join(" · ")
                            }
                            color: root.widgetInkMuted
                            font.pixelSize: Math.round(Appearance.font.pixelSize.smaller * root.s)
                            font.family: Appearance.font.family.numbers
                            elide: Text.ElideRight
                            Layout.alignment: Qt.AlignLeft
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 0

                        StyledText {
                            text: root._daysRemaining(modelData)
                            color: root.accent
                            font.pixelSize: Math.round(Appearance.font.pixelSize.large * root.s)
                            font.family: Appearance.font.family.numbers
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignHCenter
                        }

                        StyledText {
                            text: Translation.tr("DAYS")
                            color: root.widgetInkSubtle
                            font.pixelSize: Math.round(Appearance.font.pixelSize.smallest * root.s)
                            font.weight: Font.Medium
                            font.letterSpacing: Math.round(1 * root.s)
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Rectangle {
                    visible: root.cfgShowProgress
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(2 * root.s)
                    radius: Math.round(1 * root.s)
                    color: ColorUtils.applyAlpha(root.widgetInk, 0.10)

                    Rectangle {
                        property real progress: {
                            const dt = new Date(modelData?.dateTime || modelData?.startDate)
                            const now = new Date()
                            const created = new Date(modelData?.createdAt || modelData?.startDate)
                            const total = dt.getTime() - created.getTime()
                            const elapsed = now.getTime() - created.getTime()
                            if (total <= 0) return 1
                            return Math.max(0, Math.min(1, elapsed / total))
                        }
                        width: Math.round(parent.width * (1 - progress))
                        height: parent.height
                        radius: parent.radius
                        color: root._progressColor(1 - progress)

                        Behavior on width {
                            enabled: Appearance.animationsEnabled
                            NumberAnimation {
                                duration: Appearance.animation.elementMoveFast.duration
                                easing.type: Appearance.animation.elementMoveFast.type
                                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            visible: root.upcomingEvents.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Math.round(4 * root.s)

            Item { Layout.fillHeight: true }

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: "event_available"
                iconSize: Math.round(28 * root.s)
                color: ColorUtils.applyAlpha(root.widgetInkMuted, 0.5)
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Translation.tr("No upcoming events")
                color: ColorUtils.applyAlpha(root.widgetInkMuted, 0.8)
                font.pixelSize: Math.round(Appearance.font.pixelSize.smaller * root.s)
            }

            Item { Layout.fillHeight: true }
        }
    }
}