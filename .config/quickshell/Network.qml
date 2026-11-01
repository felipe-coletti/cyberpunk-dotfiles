import Quickshell
import Quickshell.Io
import QtQuick
import "parse.js" as Parse

// Network status from nmcli, checked every 5 seconds; click opens nmtui
BarItem {
    id: root

    property var status: ({ kind: "disconnected" })

    text: {
        switch (status.kind) {
        case "wifi": return "󰤨";
        case "ethernet": return `󰈀 ${status.device}`;
        case "linked": return `󰈁 ${status.device} (${I18n.t.noIp})`;
        default: return "󰤭";
        }
    }
    tooltip: status.kind === "wifi" && status.ssid ? `${status.ssid} (${status.signal}%)` : ""
    onClicked: Quickshell.execDetached(["kitty", "-e", "nmtui"])

    Process {
        id: check
        // In English: nmcli translates values like "yes" and "connected"
        environment: ({ LC_ALL: "C" })
        command: ["sh", "-c",
            "nmcli -t -f TYPE,STATE,DEVICE device; echo --; " +
            "nmcli -t -f ACTIVE,SIGNAL,SSID device wifi list --rescan no"]
        stdout: StdioCollector {
            onStreamFinished: root.status = Parse.network(text)
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
