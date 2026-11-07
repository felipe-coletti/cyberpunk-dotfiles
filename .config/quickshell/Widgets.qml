import Quickshell
import Quickshell.Io
import QtQuick

// The desktop widgets listed in ~/.config/quickshell/widgets.conf (music,
// todo), on the first screen. The list is followed, so removing a line (or
// putting # in front of it) turns that widget off right away
Scope {
    id: root

    property var shown: []

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/widgets.conf"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.shown = text().split("\n").map(line => line.trim()).filter(line => line !== "" && !line.startsWith("#"))
        onLoadFailed: root.shown = ["music", "todo"]
    }

    LazyLoader {
        active: root.shown.includes("music")

        MusicWidget {
            screen: Quickshell.screens[0]
        }
    }

    LazyLoader {
        active: root.shown.includes("todo")

        TodoWidget {
            screen: Quickshell.screens[0]
        }
    }
}
