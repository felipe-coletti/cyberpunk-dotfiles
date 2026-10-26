import QtQuick 2.15

// Text with a neon glow, drawn as faint copies around it (no graphical
// effects module, so it works on both the Qt 5 and Qt 6 greeters)
Item {
    id: neonText

    property alias text: label.text
    property alias font: label.font
    property alias horizontalAlignment: label.horizontalAlignment
    property color color: "#ffffff"
    property real glow: 0.3

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Repeater {
        model: [[-1, 0], [1, 0], [0, -1], [0, 1], [-2, 0], [2, 0], [0, -2], [0, 2]]

        Text {
            x: modelData[0]
            y: modelData[1]
            width: label.width
            text: label.text
            font: label.font
            horizontalAlignment: label.horizontalAlignment
            color: neonText.color
            opacity: neonText.glow / (Math.abs(modelData[0]) + Math.abs(modelData[1]))
        }
    }

    Text {
        id: label
        width: neonText.width
        color: neonText.color
    }
}
