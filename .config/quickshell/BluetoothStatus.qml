import Quickshell
import Quickshell.Io
import QtQuick
import "parse.js" as Parse

// Bluetooth status from bluetoothctl, checked every 5 seconds; hidden when
// there is no controller, and click opens bluetoothctl
BarItem {
    id: root

    property var status: ({ present: false, powered: false, devices: [] })

    visible: status.present
    text: !status.powered ? "󰂲"
        : status.devices.length ? `󰂱 ${status.devices.length}`
        : "󰂯"
    tooltip: {
        if (!status.present)
            return "";
        const controller = `${status.alias}\t${status.address}`;
        if (!status.devices.length)
            return controller;
        return controller + "\n\n" + status.devices.map(d => `${d.name}\t${d.address}`).join("\n");
    }
    onClicked: Quickshell.execDetached(["kitty", "-e", "bluetoothctl"])

    Process {
        id: check
        command: ["sh", "-c", "bluetoothctl show; echo --; bluetoothctl devices Connected"]
        stdout: StdioCollector {
            onStreamFinished: root.status = Parse.bluetooth(text)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: check.running = true
    }
}
