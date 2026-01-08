import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Wayland
pragma Singleton

/**
 * A nice wrapper for date and time strings.
 */
Singleton {
    id: root

    property bool inhibit: false

    Connections {
        target: Persistent
        function onReadyChanged() {
            if (!Persistent.isNewHyprlandInstance) {
                root.inhibit = Persistent.states.idle.inhibit
            } else {
                Persistent.states.idle.inhibit = root.inhibit
            }
        }
    }

    function toggleInhibit() {
        root.inhibit = !root.inhibit
        Persistent.states.idle.inhibit = root.inhibit
    }

    property var idleInhibitor: null
    
    Component.onCompleted: {
        if (typeof IdleInhibitor !== 'undefined') {
            idleInhibitor = Qt.createQmlObject(`
                import Quickshell.Wayland
                IdleInhibitor {
                    active: false
                    window: PanelWindow {
                        implicitWidth: 0
                        implicitHeight: 0
                        color: "transparent"
                        anchors {
                            right: true
                            bottom: true
                        }
                        mask: Region {
                            item: null
                        }
                    }
                }
            `, root, "IdleInhibitorDynamic");
            
            // Bind the inhibitor's active state to our inhibit property
            if (idleInhibitor) {
                idleInhibitor.active = Qt.binding(() => root.inhibit)
            }
        }
    }    

}
