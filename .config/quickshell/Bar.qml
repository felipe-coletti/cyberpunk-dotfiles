import Quickshell
import QtQuick

// The status bar: power, color wheel and workspaces on the left; status
// icons, weather and the clock on the right. Black, with a glowing neon
// line at the bottom
PanelWindow {
    id: bar

    required property var modelData

    readonly property int barHeight: 34
    readonly property int glowHeight: 5

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    // The glow under the bar takes no space and lets clicks through
    implicitHeight: barHeight + glowHeight
    exclusiveZone: barHeight
    mask: Region { item: background }
    color: "transparent"

    Rectangle {
        id: background

        width: parent.width
        height: bar.barHeight
        color: Theme.bg

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 22

            PowerButton { anchors.verticalCenter: parent.verticalCenter }
            NeonButton { anchors.verticalCenter: parent.verticalCenter }

            Workspaces {
                anchors.verticalCenter: parent.verticalCenter
                screen: bar.screen
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25

            Network { anchors.verticalCenter: parent.verticalCenter }
            BluetoothStatus { anchors.verticalCenter: parent.verticalCenter }
            Audio { anchors.verticalCenter: parent.verticalCenter }
            Brightness {
                anchors.verticalCenter: parent.verticalCenter
                monitor: bar.modelData.name
            }
            Battery { anchors.verticalCenter: parent.verticalCenter }
            Weather { anchors.verticalCenter: parent.verticalCenter }
            Clock { anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // The neon line at the bottom, glowing downwards
    Rectangle {
        y: bar.barHeight - 1
        width: parent.width
        height: 1
        color: Theme.border
    }

    Rectangle {
        y: bar.barHeight
        width: parent.width
        height: bar.glowHeight
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.alpha(Theme.neon, 0.35) }
            GradientStop { position: 1; color: "transparent" }
        }
    }
}
