import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: root
    spacing: 0
    visible: true

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
            text: "download"
            iconSize: Appearance.font.pixelSize.smaller
            color: Appearance.m3colors.m3onSecondaryContainer
        }
    }

    Item {
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 8
        Layout.preferredWidth: networkTextMetrics.width
        implicitHeight: networkText.implicitHeight

        TextMetrics {
            id: networkTextMetrics
            text: "99K/s"
            font.pixelSize: Appearance.font.pixelSize.small
        }

        StyledText {
            id: networkText
            anchors.fill: parent
            horizontalAlignment: Text.AlignRight
            color: Appearance.colors.colOnLayer1
            font.pixelSize: Appearance.font.pixelSize.small
            text: {
                let speed = ResourceUsage.networkDownSpeed;
                let kbps = speed / 1024;
                if (kbps < 100) {
                    return kbps < 10 ? (Math.round(kbps * 10) / 10) + "K/s" : Math.round(kbps) + "K/s";
                }
                let mbps = kbps / 1024;
                return (Math.round(mbps * 10) / 10) + "M/s";
            }
        }
    }
}
