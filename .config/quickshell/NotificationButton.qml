import Quickshell
import QtQuick

// The bell on the bar: an outline with no notifications, filled when there
// are some, ringing (with a stronger glow) when one arrived since the center
// was last opened. Click opens the notification center
BarItem {
    text: Notifs.unread ? "󰂞" : Notifs.all.length > 0 ? "󰂚" : "󰂜"
    strongGlow: Notifs.unread || hovered
    onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "notifications", "toggle"])
}
