import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    color: "transparent"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        // Header
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("System Monitor")
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnLayer1
        }
        
        // CPU Usage
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                MaterialSymbol {
                    text: "memory"
                    iconSize: 24
                    color: Appearance.colors.colPrimary
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    StyledText {
                        text: Translation.tr("CPU Usage")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer0
                    }
                    
                    ProgressBar {
                        Layout.fillWidth: true
                        value: ResourceUsage.cpuUsage
                        from: 0
                        to: 1
                        background: Rectangle {
                            radius: 3
                            color: Appearance.colors.colLayer1
                        }
                        contentItem: Rectangle {
                            radius: 3
                            color: ResourceUsage.cpuUsage > 0.8 ? Appearance.colors.colError : 
                                   ResourceUsage.cpuUsage > 0.6 ? Appearance.colors.colWarning : 
                                   Appearance.colors.colPrimary
                        }
                    }
                    
                    StyledText {
                        text: Math.round(ResourceUsage.cpuUsage * 100) + "%"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer0
                    }
                }
            }
        }
        
        // Memory Usage
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                MaterialSymbol {
                    text: "memory"
                    iconSize: 24
                    color: Appearance.colors.colSecondary
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    StyledText {
                        text: Translation.tr("Memory Usage")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer0
                    }
                    
                    ProgressBar {
                        Layout.fillWidth: true
                        value: ResourceUsage.memoryUsedPercentage
                        from: 0
                        to: 1
                        background: Rectangle {
                            radius: 3
                            color: Appearance.colors.colLayer1
                        }
                        contentItem: Rectangle {
                            radius: 3
                            color: ResourceUsage.memoryUsedPercentage > 0.8 ? Appearance.colors.colError : 
                                   ResourceUsage.memoryUsedPercentage > 0.6 ? Appearance.colors.colWarning : 
                                   Appearance.colors.colSecondary
                        }
                    }
                    
                    StyledText {
                        text: Math.round(ResourceUsage.memoryUsedPercentage * 100) + "%"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer0
                    }
                }
            }
        }
        
        // Network Speed
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                MaterialSymbol {
                    text: "download"
                    iconSize: 24
                    color: Appearance.colors.colTertiary
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    StyledText {
                        text: Translation.tr("Network Speed")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer0
                    }
                    
                    StyledText {
                        text: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkDownSpeed)
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.family: "monospace"
                        color: Appearance.colors.colTertiary
                    }
                }
            }
        }
        
        // Quick Actions
        Rectangle {
            Layout.fillWidth: true
            height: 100
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                
                StyledText {
                    text: Translation.tr("Quick Actions")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer0
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    RippleButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colBackground: Appearance.colors.colLayer1
                        colBackgroundHover: Appearance.colors.colLayer2
                        buttonRadius: Appearance.rounding.small
                        
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            MaterialSymbol {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "calculate"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("Calc")
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                        
                        onClicked: {
                            Quickshell.execDetached(["qalculate-gtk"])
                        }
                    }
                    
                    RippleButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colBackground: Appearance.colors.colLayer1
                        colBackgroundHover: Appearance.colors.colLayer2
                        buttonRadius: Appearance.rounding.small
                        
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            MaterialSymbol {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "speed"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("Speed")
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                        
                        onClicked: {
                            Quickshell.execDetached(["kitty", "-e", "speedtest-cli"])
                        }
                    }
                    
                    RippleButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colBackground: Appearance.colors.colLayer1
                        colBackgroundHover: Appearance.colors.colLayer2
                        buttonRadius: Appearance.rounding.small
                        
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            MaterialSymbol {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "task_alt"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                            }
                            
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("Tasks")
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                        
                        onClicked: {
                            Quickshell.execDetached(["kitty", "-e", "btop"])
                        }
                    }
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}