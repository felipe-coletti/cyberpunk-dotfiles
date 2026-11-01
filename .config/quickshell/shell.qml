import Quickshell
import QtQuick

// Quickshell entry point: one bar on each screen
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
