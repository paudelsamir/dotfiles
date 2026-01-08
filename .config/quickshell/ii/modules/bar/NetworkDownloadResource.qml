import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property bool shown: true
    clip: true
    visible: width > 0 && height > 0
    implicitWidth: networkRowLayout.x < 0 ? 0 : networkRowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: networkRowLayout
        spacing: 0
        x: shown ? 0 : -networkRowLayout.width
        anchors {
            verticalCenter: parent.verticalCenter
        }

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

        Behavior on x {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: networkRowLayout.x >= 0 && root.width > 0 && root.visible
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }
}