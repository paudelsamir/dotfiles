import qs.modules.common
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool alwaysShowAllResources: false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: true

    RowLayout {
        id: rowLayout
        spacing: 4
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1

        Resource {
            iconName: "memory"
            percentage: ResourceUsage.memoryUsedPercentage
            warningThreshold: Config.options.bar.resources.memoryWarningThreshold
        }

        Resource {
            iconName: "graphic_eq"
            percentage: ResourceUsage.gpuUsage >= 0 ? ResourceUsage.gpuUsage : 0
            shown: true  // Always show GPU for testing
            warningThreshold: Config.options.bar.resources.gpuWarningThreshold || 90
        }

        NetworkDownloadResource {
            shown: Config.options.bar.resources.alwaysShowNetwork || 
                !(MprisController.activePlayer?.trackTitle?.length > 0) ||
                root.alwaysShowAllResources
        }
    }

    ResourcesPopup {
        hoverTarget: root
    }
}
