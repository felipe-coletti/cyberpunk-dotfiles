pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// The neon palette, like .config/colors/palette.css. The neon comes from the
// color wheel (SUPER + N), which saves it in ~/.config/neon/color: it's
// followed live, so everything changes color as soon as it's picked
Singleton {
    id: theme

    property color neon: "#ffffff"

    readonly property color bg: "#000000"
    readonly property color text: neon
    readonly property color textDim: Qt.alpha(neon, 0.5)
    readonly property color bgHover: Qt.alpha(neon, 0.15)
    readonly property color accentHover: Qt.alpha(neon, 0.25)
    readonly property color border: neon
    readonly property color borderSoft: Qt.alpha(neon, 0.25)

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12

    FileView {
        path: Quickshell.env("HOME") + "/.config/neon/color"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            // apply.sh rewrites the file: ignore it while it's half written
            const hex = text().trim().toLowerCase();
            if (/^[0-9a-f]{6}$/.test(hex))
                theme.neon = "#" + hex;
        }
    }
}
