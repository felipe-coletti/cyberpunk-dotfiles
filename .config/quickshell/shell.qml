import Quickshell
import QtQuick

// Quickshell entry point: one bar on each screen; the menus, the
// notifications and the notification center show on the focused screen
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Launcher {}
    PowerMenu {}
    CityMenu {}

    NotificationCenter {
        id: center
    }

    Notifications {
        center: center
    }
}
