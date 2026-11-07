import Quickshell
import QtQuick

// Quickshell entry point: one bar on each screen; the menus, the
// notifications, the notification center and the volume/brightness
// indicator show on the focused screen, the lock screen on all of them, and
// the desktop widgets on the first one
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

    Lock {}
    Osd {}
    Widgets {}
}
