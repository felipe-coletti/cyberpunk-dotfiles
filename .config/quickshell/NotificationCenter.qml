import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Notification center: every notification that arrived and wasn't closed,
// newest first, under the bar on the right of the focused monitor. Opens with
// the bell on the bar (or `quickshell ipc call notifications toggle`) and
// closes with Escape or a click outside
PanelWindow {
    id: center

    property bool opened: false
    readonly property int glowSpace: 10
    readonly property int panelWidth: 380

    function open() {
        const focused = Hyprland.focusedMonitor;
        const target = Quickshell.screens.find(s => focused && s.name === focused.name);
        if (target)
            screen = target;
        Notifs.popups = [];
        Notifs.unread = false;
        opened = true;
        keys.forceActiveFocus();
    }

    function close() {
        opened = false;
    }

    function toggle() {
        if (opened)
            close();
        else
            open();
    }

    visible: opened
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.top: 4
    margins.right: 4
    implicitWidth: panelWidth + 2 * glowSpace
    implicitHeight: Math.min(panel.implicitHeight, (screen?.height ?? 900) * 0.7) + 2 * glowSpace
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell-notification-center"

    IpcHandler {
        target: "notifications"

        function toggle(): void {
            center.toggle();
        }
    }

    // A click outside the center closes it
    HyprlandFocusGrab {
        windows: [center]
        active: center.opened
        onCleared: center.close()
    }

    Item {
        id: keys
        focus: true
        Keys.onEscapePressed: center.close()
    }

    NeonPanel {
        id: panel

        x: center.glowSpace
        y: center.glowSpace
        width: center.panelWidth
        height: center.height - 2 * center.glowSpace
        implicitHeight: header.height + 24 + (Notifs.all.length > 0 ? list.contentHeight + 12 : empty.height + 12)

        // Title and the button that clears everything
        Item {
            id: header

            x: 14
            y: 12
            width: parent.width - 28
            height: 24

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t.notifications.toUpperCase()
                font.bold: true
            }

            BarItem {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: Notifs.all.length > 0
                text: "󰩺  " + I18n.t.clearAll
                color: hovered ? Theme.text : Theme.textDim
                glow: hovered
                onClicked: Notifs.clear()
            }
        }

        BarText {
            id: empty

            anchors.horizontalCenter: parent.horizontalCenter
            y: header.y + header.height + 18
            visible: Notifs.all.length === 0
            text: I18n.t.noNotifications
            color: Theme.textDim
            glow: false
        }

        ListView {
            id: list

            x: 12
            y: header.y + header.height + 12
            width: parent.width - 24
            height: parent.height - y - 12
            visible: Notifs.all.length > 0
            clip: true
            spacing: 10
            model: Notifs.all
            boundsBehavior: Flickable.StopAtBounds

            delegate: NotificationCard {
                width: list.width
                popup: false
            }
        }
    }
}
