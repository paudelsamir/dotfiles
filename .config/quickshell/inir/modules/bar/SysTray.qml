import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

Item {
    id: root
    implicitWidth: gridLayout.implicitWidth
    implicitHeight: gridLayout.implicitHeight
    property bool vertical: false
    property bool invertSide: false
    property bool showSeparator: true
    property var activeMenu: null

    signal closeAllTrayMenus()

    property bool smartTray: Config.options.bar.tray.filterPassive

    function isValidItem(item) {
        return item && item.id;
    }

    property list<var> trayItems: SystemTray.items.values.filter(i => {
        if (!isValidItem(i)) return false;
        const id = (i.id || "").toLowerCase();
        const title = (i.title || "").toLowerCase();
        if (id.indexOf("nm-applet") !== -1 || title.indexOf("network") !== -1) return false;
        if (id.indexOf("blueman") !== -1 || title.indexOf("bluetooth") !== -1) return false;
        const isSpotify = id.indexOf("spotify") !== -1 || title.indexOf("spotify") !== -1;
        return !smartTray || i.status !== Status.Passive || isSpotify;
    })

    function grabFocus() {
        focusGrab.active = true;
    }

    function setExtraWindowAndGrabFocus(window) {
        root.activeMenu = window;
        root.grabFocus();
    }

    function releaseFocus() {
        focusGrab.active = false;
    }

    CompositorFocusGrab {
        id: focusGrab
        active: root.activeMenu !== null
        windows: [root.activeMenu]
        onCleared: {
            if (root.activeMenu) {
                root.activeMenu.close();
                root.activeMenu = null;
            }
        }
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        anchors.fill: parent
        rowSpacing: 8
        columnSpacing: 15

        Repeater {
            model: root.trayItems

            delegate: SysTrayItem {
                required property SystemTrayItem modelData
                item: modelData
                trayParent: root
                Layout.fillHeight: !root.vertical
                Layout.fillWidth: root.vertical
                onMenuClosed: root.releaseFocus();
                onMenuOpened: (qsWindow) => {
                    root.setExtraWindowAndGrabFocus(qsWindow);
                }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.larger
            color: Appearance.angelEverywhere ? Appearance.angel.colTextSecondary
                : Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
            text: "•"
            visible: root.showSeparator && SystemTray.items.values.length > 0
        }
    }
}
