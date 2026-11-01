import Quickshell
import QtQuick

// Opens the power menu
IconButton {
    text: "󰐥"
    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/wofi/scripts/powermenu.sh"])
}
