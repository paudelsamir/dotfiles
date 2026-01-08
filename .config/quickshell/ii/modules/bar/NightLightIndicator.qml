import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell

MouseArea {
    id: root
    implicitWidth: nightLightContent.implicitWidth
    implicitHeight: Appearance.sizes.barHeight
    
    hoverEnabled: true
    
    onPressed: event => {
        if (event.button === Qt.LeftButton) {
            nightLightPopup.visible = !nightLightPopup.visible;
        }
    }
    
    RowLayout {
        id: nightLightContent
        anchors.centerIn: parent
        spacing: 8
        
        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            text: Hyprsunset.active ? "nights_stay" : "light_mode"
            iconSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer1
            
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }
    
    // Popup for adjusting color temperature
    Popup {
        id: nightLightPopup
        x: root.width - width - 10
        y: root.height + 10
        width: 250
        height: contentColumn.implicitHeight + 24
        padding: 12
        
        background: Rectangle {
            color: Appearance.colors.colLayer1
            radius: Appearance.rounding.normal
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
        }
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            spacing: 12
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                MaterialSymbol {
                    text: Hyprsunset.active ? "nights_stay" : "light_mode"
                    iconSize: Appearance.font.pixelSize.normal
                }
                
                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("Color Temperature")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.bold: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Slider {
                    id: temperatureSlider
                    Layout.fillWidth: true
                    from: 2700
                    to: 6500
                    stepSize: 100
                    
                    Binding {
                        target: temperatureSlider
                        property: "value"
                        value: Hyprsunset.colorTemperature
                    }
                    
                    onMoved: {
                        Hyprsunset.setColorTemperature(Math.round(value));
                    }
                }
                
                StyledText {
                    text: Math.round(temperatureSlider.value) + "K"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    Layout.minimumWidth: 50
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                RippleButton {
                    Layout.fillWidth: true
                    text: Translation.tr("Toggle")
                    onPressed: Hyprsunset.toggle()
                }
                
                RippleButton {
                    Layout.fillWidth: true
                    text: Translation.tr("Auto")
                    toggled: Hyprsunset.automatic
                    onPressed: Config.options.light.night.automatic = !Config.options.light.night.automatic
                }
            }
        }
    }
}
