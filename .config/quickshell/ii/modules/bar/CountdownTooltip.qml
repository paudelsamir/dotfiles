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
    property var events: []
    
    // Calculate days remaining for an event
    function calculateDaysLeft(dateString) {
        var today = new Date();
        today = new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()));
        var eventDate = new Date(dateString);
        eventDate = new Date(Date.UTC(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate()));
        var diff = Math.floor((eventDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
        return Math.max(0, diff);
    }
    
    Column {
        spacing: 4
        leftPadding: 10
        topPadding: 10
        
        // Upcoming events
        Repeater {
            model: root.events.slice(0, 5) // Show max 5 events
            
            delegate: Rectangle {
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
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8
                    spacing: 8
                    
                    // Category Icon
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        radius: Appearance.rounding.small
                        color: "transparent"
                        border.width: 1
                        border.color: "#50404040"
                        
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: {
                                var category = modelData.category || "event";
                                if (category === "birthday") return "cake";
                                if (category === "exam") return "school";
                                if (category === "meeting") return "group";
                                return "event";
                            }
                            iconSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnSurfaceVariant
                            fill: 0
                        }
                    }
                    
                    // Event Details
                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 3
                        
                        StyledText {
                            text: modelData.name || "Event"
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnSurfaceVariant
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        
                        Row {
                            spacing: 4
                            
                            StyledText {
                                text: modelData.date
                                font.pixelSize: Appearance.font.pixelSize.extraSmall
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.5
                            }
                            
                            StyledText {
                                text: "•"
                                font.pixelSize: Appearance.font.pixelSize.extraSmall
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.3
                            }
                            
                            StyledText {
                                text: root.calculateDaysLeft(modelData.date) + "d"
                                font.pixelSize: Appearance.font.pixelSize.extraSmall
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                                opacity: 0.7
                            }
                        }
                    }
                }
            }
        }
        
        // Show message if no events
        Rectangle {
            visible: root.events.length === 0
            width: 200
            height: 50
            radius: Appearance.rounding.small
            color: "transparent"
            border.width: 1
            border.color: "#40404040"
            
            StyledText {
                anchors.centerIn: parent
                text: Translation.tr("No upcoming events")
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
                opacity: 0.4
            }
        }
    }
}
