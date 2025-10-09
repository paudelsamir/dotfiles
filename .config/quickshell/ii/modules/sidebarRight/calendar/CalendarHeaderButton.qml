import qs.modules.common
import qs.modules.common.widgets
import QtQuick

RippleButton {
    id: button
    property string buttonText: ""
    property string tooltipText: ""
    property bool forceCircle: false

    implicitHeight: 30
    implicitWidth: forceCircle ? implicitHeight : (contentItem.implicitWidth + 10 * 2)
    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: Appearance.animation.elementMove.velocity
        }
    }

    background.anchors.fill: button
    buttonRadius: forceCircle ? Appearance.rounding.full : Appearance.rounding.normal
    colBackground: Appearance.colors.colLayer0
    colBackgroundHover: Appearance.colors.colLayer1
    colRipple: Appearance.colors.colLayer2

    contentItem: StyledText {
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: Appearance.font.pixelSize.normal
        font.weight: Font.Medium
        color: Appearance.colors.colOnLayer0
    }

    StyledToolTip {
        text: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }
}