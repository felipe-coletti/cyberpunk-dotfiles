import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick

// Indicator at the bottom of the focused monitor when the volume or the
// brightness changes. The volume is followed through PipeWire (keys, the
// bar, any app); the brightness keys call `quickshell ipc call osd brightness`
PanelWindow {
    id: root

    property string icon
    property real value
    property bool muted

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink?.audio ?? false
    // Own copies of the volume and mute state, to know when they change
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool sinkMuted: ready && sink.audio.muted
    // Off right after starting and when the output changes, so loading
    // the volume doesn't show the indicator
    property bool armed: false
    // Room around the box for its glow
    readonly property int glowSpace: 10

    function show(icon, value, muted) {
        root.icon = icon;
        root.value = Math.max(0, Math.min(1, value));
        root.muted = muted;
        visible = true;
        hideTimer.restart();
    }

    function showVolume() {
        if (!armed || !ready)
            return;
        const headphones = /head(phone|set)/i.test(sink.description ?? "");
        show(Icons.volume(Math.round(volume * 100), sinkMuted, headphones), volume, sinkMuted);
    }

    screen: {
        const focused = Hyprland.focusedMonitor;
        return Quickshell.screens.find(s => focused && s.name === focused.name) ?? Quickshell.screens[0];
    }
    visible: false
    color: "transparent"
    anchors.bottom: true
    margins.bottom: 64
    implicitWidth: 260 + 2 * glowSpace
    implicitHeight: 44 + 2 * glowSpace
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"
    // Clicks go through it
    mask: Region {}

    onVolumeChanged: showVolume()
    onSinkMutedChanged: showVolume()
    onSinkChanged: {
        armed = false;
        armTimer.restart();
    }

    Timer {
        id: armTimer
        interval: 1000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible = false
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    IpcHandler {
        target: "osd"

        function brightness(): void {
            brightnessCheck.running = true;
        }
    }

    // brightnessctl -m: device,class,current,percent,max
    Process {
        id: brightnessCheck
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                const value = Number(fields[2]) / Number(fields[4]);
                if (fields.length >= 5 && !isNaN(value))
                    root.show(Icons.brightness(value * 100), value, false);
            }
        }
    }

    // A neon box with the icon, a glowing bar and the percentage. Muted:
    // dimmed and without the glow, like the bar shows it
    NeonPanel {
        id: box

        anchors.fill: parent
        anchors.margins: root.glowSpace

        BarText {
            id: iconText

            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            text: root.icon
            color: root.muted ? Theme.textDim : Theme.text
            glow: !root.muted
            font.pixelSize: 16
        }

        Rectangle {
            id: track

            anchors.left: iconText.right
            anchors.leftMargin: 12
            anchors.right: percent.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            height: 4
            color: Theme.borderSoft

            Rectangle {
                width: track.width * root.value
                height: parent.height
                color: root.muted ? Theme.textDim : Theme.neon

                layer.enabled: !root.muted
                layer.effect: NeonGlow {}
            }
        }

        BarText {
            id: percent

            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            horizontalAlignment: Text.AlignRight
            text: `${Math.round(root.value * 100)}%`
            color: root.muted ? Theme.textDim : Theme.text
            glow: !root.muted
        }
    }
}
