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

    configEntryName: "custom.nepali-calendar"

    semanticPaletteControls: true
    semanticPaletteQuickControls: true

    defaultConfig: ({
        placementStrategy: "free",
        widgetScale: 100, widgetOpacity: 100, colorMode: "auto", dim: 0,
        showBackground: true, useBlur: false, showBorder: true,
        backgroundOpacity: 0.08, borderWidth: 1, borderOpacity: 0.12,
        cornerRadius: -1,
        contentWidth: 300, contentHeight: 350,
        x: 100, y: 100
    })

    implicitWidth: Math.round(Number(root._readConfigKey("contentWidth") ?? 300) * root.scaleFactor)
    implicitHeight: Math.round(Number(root._readConfigKey("contentHeight") ?? 350) * root.scaleFactor)

    visibleWhenLocked: true
    needsColText: true
    resizableAxes: ({ width: "contentWidth", height: "contentHeight" })
    resizeMinWidth: 220
    resizeMinHeight: 220
    resizeMaxWidth: 500
    resizeMaxHeight: 500

    readonly property real s: root.scaleFactor
    readonly property real cellSize: Math.round(34 * root.s)
    readonly property color accent: root.widgetAccentVisible
    readonly property color onAccent: root.widgetSemanticOnColor(root.widgetPrimaryRole)
    readonly property color hoverFill: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.06)
    readonly property color pressFill: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.12)

    readonly property var bsMonths: [
        "Baisakh", "Jestha", "Ashadh", "Shrawan",
        "Bhadra", "Ashwin", "Kartik", "Mangsir",
        "Poush", "Magh", "Falgun", "Chaitra"
    ]
    readonly property var weekDays: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    readonly property color weekEndColor: ColorUtils.applyAlpha(root.accent, 0.7)

    function weekDayColor(idx): color {
        if (idx === 0 || idx === 6) return root.weekEndColor
        return root.widgetInkMuted
    }

    readonly property var bsMonthDays: ({
        2070: [31,31,31,32,31,31,29,30,30,29,30,30],
        2071: [31,31,32,31,31,31,30,29,30,29,30,30],
        2072: [31,32,31,32,31,30,30,29,30,29,30,30],
        2073: [31,32,31,32,31,30,30,30,29,29,30,31],
        2074: [31,31,31,32,31,31,30,29,30,29,30,30],
        2075: [31,31,32,31,31,31,30,29,30,29,30,30],
        2076: [31,32,31,32,31,30,30,30,29,29,30,30],
        2077: [31,32,31,32,31,30,30,30,29,30,29,31],
        2078: [31,31,31,32,31,31,30,29,30,29,30,30],
        2079: [31,31,32,31,31,31,30,29,30,29,30,30],
        2080: [31,32,31,32,31,30,30,30,29,29,30,30],
        2081: [31,31,32,32,31,30,30,30,29,30,30,30],
        2082: [30,32,31,32,31,30,30,30,29,30,30,30],
        2083: [31,31,32,31,31,31,30,29,30,29,30,30],
        2084: [31,31,32,31,31,30,30,30,29,30,30,30],
        2085: [31,32,31,32,30,31,30,30,29,30,30,30],
        2086: [30,32,31,32,31,30,30,30,29,30,30,30],
        2087: [31,31,32,31,31,31,30,30,29,30,30,30],
        2088: [30,31,32,32,30,31,30,30,29,30,30,30],
        2089: [30,32,31,32,31,30,30,30,29,30,30,30],
        2090: [30,32,31,32,31,30,30,30,29,30,30,30]
    })

    readonly property var bsBaisakhStart: ({
        2070: [2013, 4, 14], 2071: [2014, 4, 14], 2072: [2015, 4, 14],
        2073: [2016, 4, 13], 2074: [2017, 4, 14], 2075: [2018, 4, 14],
        2076: [2019, 4, 14], 2077: [2020, 4, 13], 2078: [2021, 4, 14],
        2079: [2022, 4, 14], 2080: [2023, 4, 14], 2081: [2024, 4, 13],
        2082: [2025, 4, 14], 2083: [2026, 4, 14], 2084: [2027, 4, 14],
        2085: [2028, 4, 13], 2086: [2029, 4, 14], 2087: [2030, 4, 14],
        2088: [2031, 4, 15], 2089: [2032, 4, 14], 2090: [2033, 4, 14]
    })

    property int _tick: 0
    Timer {
        interval: 86400000
        running: true
        repeat: true
        onTriggered: root._tick++
    }

    property int navYear: 0
    property int navMonth: 0
    property var calendarGrid: []

    Component.onCompleted: {
        const bs = root.adToBs(new Date())
        root.navYear = bs.year
        root.navMonth = bs.month - 1
        root.updateCalendarGrid()
    }

    function updateCalendarGrid(): void {
        root.calendarGrid = root.buildCalendarGrid()
    }

    readonly property bool isViewingCurrentMonth: {
        const bs = root.adToBs(new Date())
        return root.navYear === bs.year && root.navMonth === bs.month - 1
    }

    readonly property var todayBs: root._tick >= 0 ? root.adToBs(new Date()) : null

    function bsDaysInMonth(year, month): int {
        const days = root.bsMonthDays[year]
        if (!days) return 30
        return days[month] || 30
    }

    function adToBs(date): var {
        const adYear = date.getFullYear()
        const adMonth = date.getMonth() + 1
        const adDay = date.getDate()

        let bsYear = 2082
        const years = Object.keys(root.bsBaisakhStart).map(Number).sort((a, b) => a - b)

        for (let i = years.length - 1; i >= 0; i--) {
            const y = years[i]
            const start = root.bsBaisakhStart[y]
            if (!start) continue
            const baisakhAd = new Date(start[0], start[1] - 1, start[2])
            if (date >= baisakhAd) {
                bsYear = y
                break
            }
        }

        const startInfo = root.bsBaisakhStart[bsYear]
        const startDate = new Date(startInfo[0], startInfo[1] - 1, startInfo[2])
        const diffMs = date.getTime() - startDate.getTime()
        let dayOfYear = Math.floor(diffMs / (1000 * 60 * 60 * 24))

        if (dayOfYear < 0) {
            bsYear--
            const prevStart = root.bsBaisakhStart[bsYear]
            if (!prevStart) return { year: bsYear, month: 1, day: 1 }
            const prevStartDate = new Date(prevStart[0], prevStart[1] - 1, prevStart[2])
            dayOfYear = Math.floor((date.getTime() - prevStartDate.getTime()) / (1000 * 60 * 60 * 24))
        }

        let bsMonth = 0
        let remaining = dayOfYear
        while (bsMonth < 12 && remaining >= root.bsDaysInMonth(bsYear, bsMonth)) {
            remaining -= root.bsDaysInMonth(bsYear, bsMonth)
            bsMonth++
        }
        if (bsMonth >= 12) bsMonth = 11

        return { year: bsYear, month: bsMonth + 1, day: remaining + 1 }
    }

    function bsToAd(bsYear, bsMonth, bsDay): var {
        const startInfo = root.bsBaisakhStart[bsYear]
        if (!startInfo) return null
        const startDate = new Date(startInfo[0], startInfo[1] - 1, startInfo[2])

        let totalDays = 0
        for (let m = 0; m < bsMonth - 1; m++)
            totalDays += root.bsDaysInMonth(bsYear, m)
        totalDays += bsDay - 1

        const result = new Date(startDate.getTime() + totalDays * 86400000)
        return { year: result.getFullYear(), month: result.getMonth() + 1, day: result.getDate() }
    }

    function buildCalendarGrid(): var {
        const year = root.navYear
        const month = root.navMonth
        const daysInMonth = root.bsDaysInMonth(year, month)
        const firstAd = root.bsToAd(year, month + 1, 1)
        const firstDate = new Date(firstAd.year, firstAd.month - 1, firstAd.day)
        const firstDow = firstDate.getDay()

        const todayBs = root.adToBs(new Date())
        const grid = []

        for (let i = 0; i < firstDow; i++)
            grid.push({ day: 0, today: 0, adDay: 0, adMonth: 0, adYear: 0 })

        for (let d = 1; d <= daysInMonth; d++) {
            const isToday = (todayBs.year === year && todayBs.month === month + 1 && todayBs.day === d)
            const ad = root.bsToAd(year, month + 1, d)
            grid.push({
                day: d,
                today: isToday ? 1 : 0,
                adDay: ad ? ad.day : 0,
                adMonth: ad ? ad.month : 0,
                adYear: ad ? ad.year : 0
            })
        }

        while (grid.length % 7 !== 0)
            grid.push({ day: 0, today: 0, adDay: 0, adMonth: 0, adYear: 0 })

        return grid
    }

    function prevMonth(): void {
        if (root.navMonth === 0) { root.navMonth = 11; root.navYear-- }
        else root.navMonth--
        root.updateCalendarGrid()
    }

    function nextMonth(): void {
        if (root.navMonth === 11) { root.navMonth = 0; root.navYear++ }
        else root.navMonth++
        root.updateCalendarGrid()
    }

    function goToToday(): void {
        const bs = root.adToBs(new Date())
        root.navYear = bs.year
        root.navMonth = bs.month - 1
        root.updateCalendarGrid()
    }

    editPopoverContent: Component {
        Row {
            spacing: 4
            anchors.horizontalCenter: parent.horizontalCenter
            SelectionGroupButton {
                leftmost: true; rightmost: true
                buttonIcon: "today"
                buttonText: Translation.tr("Today")
                toggled: root.isViewingCurrentMonth
                onClicked: root.goToToday()
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
        anchors.margins: Math.round(10 * root.s)
        spacing: 0
        clip: true

        RowLayout {
            Layout.fillWidth: true
            spacing: Math.round(8 * root.s)

            Rectangle {
                visible: root.isViewingCurrentMonth
                Layout.preferredWidth: todayCol.implicitWidth + Math.round(16 * root.s)
                Layout.preferredHeight: todayCol.implicitHeight + Math.round(10 * root.s)
                radius: root.widgetCardRadius
                color: root.accent

                ColumnLayout {
                    id: todayCol
                    anchors.centerIn: parent
                    spacing: -Math.round(2 * root.s)

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.todayBs ? String(root.todayBs.day) : ""
                        color: root.onAccent
                        font.pixelSize: Math.round(Appearance.font.pixelSize.larger * root.s)
                        font.family: Appearance.font.family.numbers
                        font.weight: Font.Bold
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.bsMonths[root.todayBs ? root.todayBs.month - 1 : 0]
                        color: root.onAccent
                        font.pixelSize: Math.round(Appearance.font.pixelSize.smallest * root.s)
                        font.weight: Font.Medium
                        opacity: 0.9
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    text: root.bsMonths[root.navMonth]
                    color: root.widgetInk
                    font.pixelSize: Math.round(Appearance.font.pixelSize.normal * root.s)
                    font.weight: Font.DemiBold
                }

                StyledText {
                    text: String(root.navYear)
                    color: root.widgetInkMuted
                    font.pixelSize: Math.round(Appearance.font.pixelSize.smallest * root.s)
                    font.family: Appearance.font.family.numbers
                }
            }

            RowLayout {
                spacing: Math.round(2 * root.s)

                Rectangle {
                    visible: !root.isViewingCurrentMonth
                    width: navJumpToday.implicitWidth + Math.round(12 * root.s)
                    height: Math.round(24 * root.s)
                    radius: root.widgetCardRadius
                    color: jumpTodayMA.containsPress ? root.pressFill
                        : jumpTodayMA.containsMouse ? root.hoverFill
                        : "transparent"

                    MaterialSymbol {
                        id: navJumpToday
                        anchors.centerIn: parent
                        text: "today"
                        iconSize: Math.round(14 * root.s)
                        color: root.accent
                    }

                    MouseArea {
                        id: jumpTodayMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goToToday()
                    }
                }

                Rectangle {
                    width: Math.round(26 * root.s)
                    height: Math.round(26 * root.s)
                    radius: root.widgetCardRadius
                    color: prevMA.containsPress ? root.pressFill
                        : prevMA.containsMouse ? root.hoverFill
                        : "transparent"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "chevron_left"
                        iconSize: Math.round(16 * root.s)
                        color: root.widgetInkMuted
                    }

                    MouseArea {
                        id: prevMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.prevMonth()
                    }
                }

                Rectangle {
                    width: Math.round(26 * root.s)
                    height: Math.round(26 * root.s)
                    radius: root.widgetCardRadius
                    color: nextMA.containsPress ? root.pressFill
                        : nextMA.containsMouse ? root.hoverFill
                        : "transparent"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "chevron_right"
                        iconSize: Math.round(16 * root.s)
                        color: root.widgetInkMuted
                    }

                    MouseArea {
                        id: nextMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextMonth()
                    }
                }
            }
        }

        Item { Layout.preferredHeight: Math.round(8 * root.s) }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(22 * root.s)
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Repeater {
                model: 7
                Rectangle {
                    required property int index
                    Layout.preferredWidth: Math.round(root.cellSize)
                    Layout.fillHeight: true
                    color: "transparent"

                    StyledText {
                        anchors.centerIn: parent
                        text: root.weekDays[parent.index]
                        color: root.weekDayColor(parent.index)
                        font.pixelSize: Math.round(Appearance.font.pixelSize.smaller * root.s)
                        font.weight: Font.Medium
                        font.letterSpacing: Math.round(0.5 * root.s)
                    }
                }
            }
        }

        Repeater {
            model: Math.ceil(root.calendarGrid.length / 7)

            delegate: RowLayout {
                required property int index
                property int weekRow: index
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 0

                Repeater {
                    model: Array(7).fill(parent.weekRow)

                    Rectangle {
                        required property int index
                        required property int modelData
                        readonly property int cellIdx: modelData * 7 + index
                        readonly property var cell: cellIdx < root.calendarGrid.length ? root.calendarGrid[cellIdx] : ({ day: 0, today: 0, adDay: 0 })
                        readonly property bool isEmpty: cell.day === 0
                        readonly property bool isToday: cell.today === 1

                        Layout.preferredWidth: Math.round(root.cellSize)
                        Layout.preferredHeight: Math.round(36 * root.s)
                        radius: isToday ? root.widgetCardRadius : Math.round(4 * root.s)
                        color: isToday ? root.accent
                            : cellMA.containsMouse && !isEmpty ? root.hoverFill
                            : "transparent"

                        Behavior on color {
                            enabled: Appearance.animationsEnabled
                            ColorAnimation { duration: Appearance.animation.elementMoveFast.duration }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -Math.round(4 * root.s)
                            visible: !parent.isEmpty
                            text: String(parent.cell.day)
                            color: parent.isToday ? root.onAccent : root.widgetInk
                            font.pixelSize: Math.round(Appearance.font.pixelSize.smaller * root.s)
                            font.family: Appearance.font.family.numbers
                            font.weight: parent.isToday ? Font.Bold : Font.Normal
                        }

                        StyledText {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: Math.round(8 * root.s)
                            visible: !parent.isEmpty && parent.cell.adDay > 0
                            text: String(parent.cell.adDay)
                            color: parent.isToday ? ColorUtils.applyAlpha(root.onAccent, 0.85) : root.widgetInkSubtle
                            font.pixelSize: Math.round(Appearance.font.pixelSize.smallest * root.s)
                            font.family: Appearance.font.family.numbers
                            font.weight: Font.Normal
                        }

                        MouseArea {
                            id: cellMA
                            anchors.fill: parent
                            hoverEnabled: true
                            visible: !parent.isEmpty
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}