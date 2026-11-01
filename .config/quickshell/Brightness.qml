import Quickshell
import Quickshell.Io
import QtQuick

// Brightness of this bar's monitor, through brightness.sh; hidden on
// monitors without brightness control
BarItem {
    id: root

    required property string monitor
    readonly property string script: Quickshell.env("HOME") + "/.config/quickshell/scripts/brightness.sh"
    property string value: ""

    visible: value !== ""
    text: `󰃠 ${value}%`
    tooltip: I18n.t.brightnessHint

    onClicked: event => run(event.button === Qt.RightButton ? "right_click" : "left_click")
    onScrolled: direction => run(direction > 0 ? "up" : "down")

    function run(action) {
        Quickshell.execDetached([script, action, monitor]);
        refresh.restart();
    }

    Process {
        id: check
        command: [root.script, "get", root.monitor]
        stdout: StdioCollector {
            onStreamFinished: root.value = text.trim()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: check.running = true
    }

    // Reads the new value shortly after a change
    Timer {
        id: refresh
        interval: 300
        onTriggered: check.running = true
    }
}
