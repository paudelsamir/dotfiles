import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property int dayProgressPercentage: 0
    property int hoursLeft: 0
    property int minutesLeft: 0
    
    ColumnLayout {
        spacing: 8
        
        // TODAY header
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "TODAY"
            font.weight: Font.Medium
            font.pixelSize: Appearance.font.pixelSize.extraSmall
            color: Appearance.colors.colOnSurfaceVariant
            opacity: 0.6
        }
        
        // Percentage row
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8
            
            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                fill: 1
                font.weight: Font.Medium
                text: "schedule"
                iconSize: Appearance.font.pixelSize.extraLarge
                color: Appearance.colors.colOnSurfaceVariant
            }
            
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.dayProgressPercentage + "%"
                font.weight: Font.Bold
                font.pixelSize: Appearance.font.pixelSize.extraLarge
                color: Appearance.colors.colOnSurfaceVariant
            }
        }
        
        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            color: Appearance.colors.colOutlineVariant
            opacity: 0.2
        }
        
        // Hours remaining
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6
            
            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                text: "timer"
                color: Appearance.colors.colOnSurfaceVariant
                font.pixelSize: Appearance.font.pixelSize.normal
                fill: 0
                font.weight: Font.Medium
            }
            
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                color: Appearance.colors.colOnSurfaceVariant
                text: root.hoursLeft + "h " + root.minutesLeft + "m left"
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }
}
