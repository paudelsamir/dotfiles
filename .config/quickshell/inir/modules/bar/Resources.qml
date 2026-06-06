import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options?.bar?.borderless ?? false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: true

    Component.onCompleted: ResourceUsage.keepAlive()

    RowLayout {
        id: rowLayout
        spacing: 8
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1

        // CPU
        RowLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 16
                height: 16
                radius: 4
                color: Appearance.colors.colSecondaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.Normal
                    fill: 1
                    text: "planner_review"
                    iconSize: Appearance.font.pixelSize.smaller
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                color: Appearance.colors.colOnLayer1
                font.pixelSize: Appearance.font.pixelSize.small
                text: `${Math.round(ResourceUsage.cpuUsage * 100).toString()}%`
            }
        }

        // Memory
        RowLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 16
                height: 16
                radius: 4
                color: Appearance.colors.colSecondaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.Normal
                    fill: 1
                    text: "memory"
                    iconSize: Appearance.font.pixelSize.smaller
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                color: Appearance.colors.colOnLayer1
                font.pixelSize: Appearance.font.pixelSize.small
                text: `${Math.round(ResourceUsage.memoryUsedPercentage * 100).toString()}%`
            }
        }

        // GPU
        RowLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 16
                height: 16
                radius: 4
                color: Appearance.colors.colSecondaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.Normal
                    fill: 1
                    text: "graphic_eq"
                    iconSize: Appearance.font.pixelSize.smaller
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                color: Appearance.colors.colOnLayer1
                font.pixelSize: Appearance.font.pixelSize.small
                text: `${Math.round((ResourceUsage.gpuUsage >= 0 ? ResourceUsage.gpuUsage : 0) * 100).toString()}%`
            }
        }

        NetworkDownloadResource {}
    }

    ResourcesPopup {
        hoverTarget: root
    }
}
