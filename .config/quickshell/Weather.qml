import Quickshell
import Quickshell.Io
import QtQuick

// Weather from scripts/weather.sh (Open-Meteo), every 15 minutes. Click
// looks the location up again; right click opens the city menu
// (CityMenu.qml), which saves the city in weather.conf (followed here, so the
// weather updates)
BarItem {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/quickshell"
    property var weather: ({ text: "", tooltip: "" })

    function update() {
        check.running = true;
    }

    visible: weather.text !== ""
    text: weather.text
    tooltip: weather.tooltip

    onClicked: event => {
        if (event.button === Qt.RightButton) {
            Quickshell.execDetached(["quickshell", "ipc", "call", "city", "toggle"]);
        } else {
            refresh.running = true;
        }
    }

    Process {
        id: check
        command: [root.dir + "/scripts/weather.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const weather = JSON.parse(text);
                    if (weather.text)
                        root.weather = weather;
                } catch (error) {
                    // Offline with no saved weather: keep what's shown
                }
            }
        }
    }

    // Forgets the IP location, then checks again
    Process {
        id: refresh
        command: [root.dir + "/scripts/weather.sh", "refresh"]
        onExited: root.update()
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.update()
    }

    FileView {
        path: root.dir + "/weather.conf"
        watchChanges: true
        onFileChanged: root.update()
    }
}
