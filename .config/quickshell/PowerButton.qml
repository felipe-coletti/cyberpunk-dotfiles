import Quickshell
import QtQuick

// Opens the power menu
IconButton {
    text: "󰐥"
    onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "power", "toggle"])
}
