import Quickshell
import QtQuick

// Quickshell entry point: one bar on each screen, and the menus, which open
// on the focused screen (see Menu.qml)
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Launcher {}
    PowerMenu {}
    CityMenu {}
}
