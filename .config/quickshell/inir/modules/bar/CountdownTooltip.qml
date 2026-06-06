import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    property string targetDate: ""
    property int daysLeft: 0

    Column {
        spacing: 4
        leftPadding: 10
        topPadding: 10

        Rectangle {
            width: 200
            height: 50
            radius: Appearance.rounding.small
            color: "transparent"
            border.width: 1
            border.color: "#4f4f4f40"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "schedule"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnSurfaceVariant
                    fill: 0
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    StyledText {
                        text: {
                            if (!root.targetDate || root.targetDate === "Not set")
                                return Translation.tr("No target date set")
                            return root.daysLeft > 0
                                ? root.daysLeft + "d " + Translation.tr("until") + " " + root.targetDate
                                : Translation.tr("Target reached!")
                        }
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnSurfaceVariant
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        visible: root.targetDate && root.targetDate !== "Not set"
                        text: Translation.tr("Target: ") + root.targetDate
                        font.pixelSize: Appearance.font.pixelSize.extraSmall
                        color: Appearance.colors.colOnSurfaceVariant
                        opacity: 0.5
                    }
                }
            }
        }

        StyledText {
            visible: !root.targetDate || root.targetDate === "Not set"
            width: 200
            height: 50
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: Translation.tr("Click to set a target date")
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
            opacity: 0.4
        }
    }
}
