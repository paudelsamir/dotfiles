import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

StyledPopup {
    id: root

    property int _eventsTrigger: 0
    property int _externalTrigger: 0

    readonly property var upcomingEvents: {
        const _t = root._eventsTrigger
        const _t2 = root._externalTrigger
        const now = new Date()
        const local = Events.getUpcomingEvents(14).map(e => Object.assign({}, e, { _source: "local" }))
        const startDay = new Date(now); startDay.setHours(0,0,0,0)
        const ext = []
        for (let i = 0; i < 14; i++) {
            const d = new Date(startDay); d.setDate(d.getDate() + i)
            const dayEvts = CalendarSync.getEventsForDate(d) || []
            for (const e of dayEvts) {
                const evtTime = new Date(e.startDate || e.dateTime)
                if (evtTime >= now || (e.allDay && evtTime >= startDay))
                    ext.push(Object.assign({}, e, { _source: "external", dateTime: e.startDate || e.dateTime, category: "general", priority: "normal" }))
            }
        }
        const all = local.concat(ext)
        all.sort((a,b) => new Date(a.dateTime || a.startDate) - new Date(b.dateTime || b.startDate))
        return all
    }

    Column {
        spacing: 8
        leftPadding: 8
        topPadding: 8
        rightPadding: 8
        bottomPadding: 8

        Connections {
            target: Events
            function onEventAdded(event) { root._eventsTrigger++ }
            function onEventRemoved(id) { root._eventsTrigger++ }
            function onEventUpdated(event) { root._eventsTrigger++ }
        }
        Connections {
            target: CalendarSync
            function onEventsUpdated() { root._externalTrigger++ }
        }

        // Header
        RowLayout {
            width: parent.width - 16
            spacing: 6

            MaterialSymbol {
                text: "event_upcoming"
                iconSize: 16
                fill: 1
                color: Appearance.colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Upcoming Events")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSurfaceVariant
            }

            Rectangle {
                visible: root.upcomingEvents.length > 0
                implicitWidth: Math.max(18, countLabel.implicitWidth + 8)
                implicitHeight: 18
                radius: 9
                color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.85)

                StyledText {
                    id: countLabel
                    anchors.centerIn: parent
                    text: root.upcomingEvents.length
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        // Events list
        Flickable {
            width: 280
            height: Math.min(300, eventCol.implicitHeight)
            contentHeight: eventCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: eventCol
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.upcomingEvents.slice(0, 10)

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: 4
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 14
                                color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.85)

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: 14
                                    text: modelData._source === "external" ? "cloud_sync" : Events.getCategoryIcon(modelData.category)
                                    color: Appearance.colors.colOnSurfaceVariant
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnLayer1
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    visible: text !== ""
                                    text: {
                                        const d = new Date(modelData.dateTime || modelData.startDate)
                                        const now = new Date()
                                        const today = now.toDateString()
                                        const tomorrow = new Date(now); tomorrow.setDate(tomorrow.getDate() + 1)
                                        if (d.toDateString() === today) {
                                            return Translation.tr("Today") + " " + Qt.formatTime(d, "HH:mm")
                                        } else if (d.toDateString() === tomorrow.toDateString()) {
                                            return Translation.tr("Tomorrow") + " " + Qt.formatTime(d, "HH:mm")
                                        } else {
                                            return Qt.formatDate(d, "dd/MM") + " " + Qt.formatTime(d, "HH:mm")
                                        }
                                    }
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }
                    }
                }

                // Empty state
                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    visible: root.upcomingEvents.length === 0
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: Translation.tr("No upcoming events")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                    opacity: 0.6
                }
            }
        }
    }
}
