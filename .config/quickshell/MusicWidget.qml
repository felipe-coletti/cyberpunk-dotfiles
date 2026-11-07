import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import QtQuick

// Music widget, at the bottom right of the desktop (under the windows): the
// cover, title and artist of what's playing, with buttons to skip and pause.
// It works with any player that has MPRIS (Spotify, browsers, mpv...)
PanelWindow {
    id: root

    // The player that's playing, or the first one there is
    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? players[0] ?? null
    readonly property bool active: player !== null && (player.trackTitle || player.trackArtist)
    readonly property int glowSpace: 10

    color: "transparent"
    anchors.bottom: true
    anchors.right: true
    margins.bottom: 20 - glowSpace
    margins.right: 20 - glowSpace
    implicitWidth: box.implicitWidth + 2 * glowSpace
    implicitHeight: box.implicitHeight + 2 * glowSpace
    // Below the bar, not behind it
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-music"
    mask: Region { item: box }

    WidgetBox {
        id: box

        x: root.glowSpace
        y: root.glowSpace

        BarText {
            text: I18n.t.musicTitle.toUpperCase()
            font.pixelSize: 13
            font.bold: true
        }

        Row {
            width: parent.width
            spacing: 12

            // The cover, or the music icon when there is none
            Item {
                width: 64
                height: 64

                Image {
                    id: cover

                    anchors.fill: parent
                    source: root.active ? (root.player.trackArtUrl ?? "") : ""
                    sourceSize.width: 128
                    sourceSize.height: 128
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }

                Rectangle {
                    anchors.fill: parent
                    visible: cover.visible
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.textDim
                }

                BarText {
                    anchors.centerIn: parent
                    visible: !cover.visible
                    text: "󰝚"
                    color: Theme.textDim
                    glow: false
                    font.pixelSize: 32
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 64 - 12
                spacing: 4

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    text: !root.active ? I18n.t.nothingPlaying
                        : root.player.trackTitle || root.player.trackArtist
                }

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    visible: text !== ""
                    text: root.active && root.player.trackTitle ? (root.player.trackArtist ?? "") : ""
                    color: Theme.textDim
                    glow: false
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            enabled: root.active

            WidgetButton {
                icon: "󰒮"
                onClicked: root.player.previous()
            }

            WidgetButton {
                icon: root.active && root.player.isPlaying ? "󰏤" : "󰐊"
                onClicked: root.player.togglePlaying()
            }

            WidgetButton {
                icon: "󰒭"
                onClicked: root.player.next()
            }
        }
    }
}
