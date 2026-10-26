import QtQuick 2.15

// Uppercase neon button; the primary one is filled, like on the color wheel
Item {
    id: button

    property string text
    property color color: "#ffffff"
    property string fontFamily
    property bool primary: false

    signal clicked()

    implicitWidth: label.implicitWidth + 24
    implicitHeight: 34
    opacity: enabled ? 1 : 0.3

    NeonBox {
        anchors.fill: parent
        color: button.color
        filled: button.primary
        highlighted: mouse.containsMouse || button.activeFocus
    }

    NeonText {
        id: label
        anchors.centerIn: parent
        text: button.text.toUpperCase()
        color: button.primary ? "#000000" : button.color
        glow: button.primary ? 0 : 0.3
        font.family: button.fontFamily
        font.pixelSize: 13
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }

    Keys.onReturnPressed: button.clicked()
    Keys.onSpacePressed: button.clicked()
}
