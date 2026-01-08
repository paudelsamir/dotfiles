import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets
import qs
import qs.services
import Quickshell.Io

QuickToggleButton {
    id: nightLightButton
    property bool enabled: Hyprsunset.active
    toggled: enabled
    buttonIcon: Config.options.light.night.automatic ? "night_sight_auto" : "bedtime"
    
    onClicked: {
        Hyprsunset.toggle()
    }

    altAction: () => {
        temperaturePopup.open()
    }

    Component.onCompleted: {
        Hyprsunset.fetchState()
    }
    
    StyledToolTip {
        text: Translation.tr("Night Light | Right-click to adjust")
    }
    
    // Temperature popup
    Popup {
        id: temperaturePopup
        parent: nightLightButton
        x: parent.width + 10
        y: (parent.height - height) / 2
        width: 150
        padding: 10
        
        background: Rectangle {
            color: Appearance.colors.colLayer1
            radius: Appearance.rounding.small
            border.width: 1
            border.color: Appearance.colors.colOutline
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            
            Slider {
                id: temperatureSlider
                Layout.fillWidth: true
                from: 2700
                to: 6500
                stepSize: 100
                value: Hyprsunset.colorTemperature
                
                handle: Rectangle {
                    x: temperatureSlider.leftPadding + temperatureSlider.visualPosition * (temperatureSlider.availableWidth - width)
                    y: (temperatureSlider.height - height) / 2
                    width: 12
                    height: 12
                    radius: 6
                    color: Appearance.colors.colPrimary
                }
                
                onMoved: {
                    Hyprsunset.setColorTemperature(Math.round(value))
                }
            }
            
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Math.round(temperatureSlider.value) + "K"
                font.pixelSize: Appearance.font.pixelSize.micro
                color: Appearance.colors.colOnLayer1
            }
        }
    }
}
