import Quickshell
import QtQuick

// Opens the color wheel to pick the neon color (also SUPER + N)
IconButton {
    text: "󰏘"
    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/neon/pick.sh"])
}
