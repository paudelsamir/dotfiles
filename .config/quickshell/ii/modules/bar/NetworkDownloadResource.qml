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
        spacing: 2
        x: shown ? 0 : -networkRowLayout.width
        anchors {
            verticalCenter: parent.verticalCenter
        }

        ClippedFilledCircularProgress {
            id: networkCircProg
            Layout.alignment: Qt.AlignVCenter
            lineWidth: Appearance.rounding.unsharpen
            value: 0.3  // Static visual indicator since network speed isn't a percentage
            implicitSize: 20
            colPrimary: Appearance.colors.colOnSecondaryContainer
            accountForLightBleeding: true
            enableAnimation: false

            Item {
                anchors.centerIn: parent
                width: networkCircProg.implicitSize
                height: networkCircProg.implicitSize
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.DemiBold
                    fill: 1
                    text: "download"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: networkTextMetrics.width
            implicitHeight: networkText.implicitHeight

            TextMetrics {
                id: networkTextMetrics
                text: "999M/s"  // Max expected width for network speed
                font.pixelSize: Appearance.font.pixelSize.small
                font.family: "monospace"
            }

            StyledText {
                id: networkText
                anchors.centerIn: parent
                color: Appearance.colors.colOnLayer1
                font.pixelSize: Appearance.font.pixelSize.small
                font.family: "monospace"
                text: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkDownSpeed)
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