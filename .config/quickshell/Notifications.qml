import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Notification popups in the top right corner of the focused monitor, under
// the bar, newest on top. Click one to run its default action; right click
// or the × closes it. They stay while the mouse is over them, and every one
// is kept in the notification center
PanelWindow {
    id: root

    readonly property int maxShown: 5
    readonly property var shown: Notifs.popups.slice(0, maxShown)
    // Room around the cards for their glow
    readonly property int glowSpace: 10

    screen: {
        const focused = Hyprland.focusedMonitor;
        return Quickshell.screens.find(s => focused && s.name === focused.name) ?? Quickshell.screens[0];
    }
    // Hidden while the center is open, which shows them all
    visible: shown.length > 0 && !center.opened
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.top: 4
    margins.right: 4
    implicitWidth: 360 + 2 * glowSpace
    implicitHeight: column.implicitHeight + 2 * glowSpace
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    // Only the cards take clicks, not the glow around them
    mask: Region { item: column }

    // The notification center, to know when it's open
    required property var center

    Column {
        id: column

        x: root.glowSpace
        y: root.glowSpace
        width: 360
        spacing: 12

        Repeater {
            model: root.shown

            NotificationCard {}
        }
    }
}
