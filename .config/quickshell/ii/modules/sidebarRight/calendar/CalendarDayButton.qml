import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 40; 
    implicitHeight: 40;

    toggled: (isToday == 1)
    buttonRadius: Appearance.rounding.normal
    colBackground: (isToday == 1) ? Appearance.colors.colPrimary : "transparent"
    colBackgroundHover: (isToday == 1) ? Qt.darker(Appearance.colors.colPrimary, 1.1) : Appearance.colors.colLayer2
    
    contentItem: StyledText {
        anchors.centerIn: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: bold ? Font.DemiBold : Font.Normal
        font.pixelSize: Appearance.font.pixelSize.normal
        color: (isToday == 1) ? "white" : 
            (isToday == 0) ? Appearance.colors.colOnLayer1 : 
            Appearance.colors.colOutlineVariant

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}

