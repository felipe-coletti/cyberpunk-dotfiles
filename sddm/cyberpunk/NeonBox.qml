import QtQuick 2.15

// 1px neon border with an outer and inner glow, like the rest of the theme
Item {
    id: neonBox

    property color color: "#ffffff"
    property bool filled: false
    property bool highlighted: false

    Repeater {
        model: 3

        Rectangle {
            anchors.fill: parent
            anchors.margins: -(index + 1)
            color: "transparent"
            border.color: neonBox.color
            opacity: 0.3 / (index + 1)
        }
    }

    Repeater {
        model: 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: index + 1
            color: "transparent"
            border.color: neonBox.color
            opacity: 0.25 / (index + 1)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: neonBox.filled ? neonBox.color
             : neonBox.highlighted ? Qt.rgba(neonBox.color.r, neonBox.color.g, neonBox.color.b, 0.15)
             : "transparent"
        border.color: neonBox.color
    }
}
