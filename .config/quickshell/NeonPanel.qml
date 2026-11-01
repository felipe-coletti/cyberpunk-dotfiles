import QtQuick
import QtQuick.Effects

// A black box with a neon border that glows outside and inside, like
// box-shadow: 0 0 3px, inset 0 0 3px in the GTK theme. Square corners
Item {
    id: panel

    property color fill: Theme.bg
    property color borderColor: Theme.border
    property bool glow: true

    RectangularShadow {
        anchors.fill: parent
        visible: panel.glow
        color: Qt.alpha(Theme.neon, 0.7)
        blur: 6
        spread: 0
    }

    Rectangle {
        anchors.fill: parent
        color: panel.fill
        border.width: 1
        border.color: panel.borderColor

        // The inner glow: a soft line just inside the border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            visible: panel.glow
            color: "transparent"
            border.width: 2
            border.color: Qt.alpha(Theme.neon, 0.25)
        }
    }
}
