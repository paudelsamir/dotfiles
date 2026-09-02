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

    configEntryName: "custom.age-calculator"
    defaultConfig: ({
        placementStrategy: "free",
        widgetScale: 100, widgetOpacity: 100, colorMode: "auto", dim: 0,
        contentWidth: 200, contentHeight: 44,
        showShadow: true,
        bgOpacity: 100, borderOpacity: 12, borderWidth: 1,
        x: 300, y: 200
    })

    implicitWidth: Math.round((Config.getNestedValue("background.widgets.custom.age-calculator.contentWidth", 200)) * scaleFactor)
    implicitHeight: Math.round((Config.getNestedValue("background.widgets.custom.age-calculator.contentHeight", 44)) * scaleFactor)

    visibleWhenLocked: true
    needsColText: true
    resizableAxes: ({ width: "contentWidth", height: "contentHeight" })
    resizeMinWidth: 140
    resizeMinHeight: 32
    resizeMaxWidth: 500
    resizeMaxHeight: 200

    readonly property bool cfgShowShadow: _readConfigKey("showShadow") ?? true
    readonly property real cfgBgOpacity: Number(_readConfigKey("bgOpacity") ?? 100) / 100
    readonly property real cfgBorderOpacity: Number(_readConfigKey("borderOpacity") ?? 12) / 100
    readonly property real cfgBorderWidth: Number(_readConfigKey("borderWidth") ?? 1)

    readonly property real cardRadius: Appearance.rounding.normal
    readonly property real s: root.scaleFactor

    property real dimFactor: {
        const v = Number(_readConfigKey("dim") ?? 0);
        return Math.max(0, Math.min(1, Number.isFinite(v) ? v / 100 : 0));
    }

    property color clockTextColor: ColorUtils.mix(root.colText, Qt.rgba(0, 0, 0, 1), dimFactor)

    readonly property date birthDate: new Date(2005, 1, 16)

    property int _tick: 0

    Timer {
        interval: 86400000
        running: true
        repeat: true
        onTriggered: root._tick++
    }

    readonly property var ageData: (root._tick, (() => {
        const now = new Date()
        const bday = root.birthDate

        let years = now.getFullYear() - bday.getFullYear()
        let months = now.getMonth() - bday.getMonth()
        let dayDiff = now.getDate() - bday.getDate()
        if (dayDiff < 0) { months--; dayDiff += new Date(now.getFullYear(), now.getMonth(), 0).getDate() }
        if (months < 0) { years--; months += 12 }
        const days = months * 30 + dayDiff

        return { years, days }
    })())

    // ── Edit popover ───────────────────────────────────────────
    editPopoverContent: Component {
        Column {
            spacing: 6
            SelectionGroupButton {
                anchors.horizontalCenter: parent.horizontalCenter
                leftmost: true; rightmost: true
                buttonIcon: "shadow"
                buttonText: "Shadow"
                toggled: root.cfgShowShadow
                onClicked: Config.setNestedValue("background.widgets.custom.age-calculator.showShadow", !root.cfgShowShadow)
            }
            RowLayout {
                width: parent.width; spacing: 6
                MaterialSymbol { text: "format_color_fill"; iconSize: 14; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.5) }
                StyledText { text: "BG"; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.7); font.pixelSize: Appearance.font.pixelSize.smaller }
                StyledSlider {
                    Layout.fillWidth: true; from: 0; to: 100; stepSize: 5
                    configuration: StyledSlider.Configuration.XS; stopIndicatorValues: []
                    value: root.cfgBgOpacity * 100; tooltipContent: Math.round(value) + "%"
                    onMoved: Config.setNestedValue("background.widgets.custom.age-calculator.bgOpacity", Math.round(value))
                }
            }
            RowLayout {
                width: parent.width; spacing: 6
                MaterialSymbol { text: "border_outer"; iconSize: 14; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.5) }
                StyledText { text: "Border"; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.7); font.pixelSize: Appearance.font.pixelSize.smaller }
                StyledSlider {
                    Layout.fillWidth: true; from: 0; to: 50; stepSize: 1
                    configuration: StyledSlider.Configuration.XS; stopIndicatorValues: []
                    value: root.cfgBorderOpacity * 100; tooltipContent: Math.round(value) + "%"
                    onMoved: Config.setNestedValue("background.widgets.custom.age-calculator.borderOpacity", Math.round(value))
                }
            }
            RowLayout {
                width: parent.width; spacing: 6
                MaterialSymbol { text: "line_weight"; iconSize: 14; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.5) }
                StyledText { text: "Width"; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.7); font.pixelSize: Appearance.font.pixelSize.smaller }
                StyledSlider {
                    Layout.fillWidth: true; from: 0; to: 4; stepSize: 0.5
                    configuration: StyledSlider.Configuration.XS; stopIndicatorValues: []
                    value: root.cfgBorderWidth; tooltipContent: value.toFixed(1)
                    onMoved: Config.setNestedValue("background.widgets.custom.age-calculator.borderWidth", value)
                }
            }
        }
    }

    // ── Card background ────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadiusOverride >= 0 ? root.cornerRadiusOverride : root.cardRadius
        color: ColorUtils.applyAlpha(root.colText, root.cfgBgOpacity)
        border.width: root.cfgBorderWidth
        border.color: ColorUtils.applyAlpha(root.colText, root.cfgBorderOpacity)
    }

    // ── Single line: 21y 151d lived ───────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: Math.round(10 * root.s)
        opacity: 1.0 - root.dimFactor * 0.6

        StyledText {
            text: (root.ageData?.years ?? "—") + "y"
            color: root.clockTextColor
            font.pixelSize: Math.round(Appearance.font.pixelSize.large * root.s)
            font.family: Appearance.font.family.numbers
            font.weight: Font.Bold
            style: root.cfgShowShadow ? Text.Raised : Text.Normal
            styleColor: Appearance.colors.colShadow
        }

        StyledText {
            text: (root.ageData?.days ?? "—") + "d lived"
            color: root.clockTextColor
            font.pixelSize: Math.round(Appearance.font.pixelSize.large * root.s)
            font.family: Appearance.font.family.numbers
            font.weight: Font.Bold
            style: root.cfgShowShadow ? Text.Raised : Text.Normal
            styleColor: Appearance.colors.colShadow
        }
    }
}
