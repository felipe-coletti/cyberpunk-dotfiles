import QtQuick

// A small neon button with an icon; flat buttons have no box and only glow
// stronger on hover
Item {
    id: button

    property string icon
    property bool flat: false

    signal clicked()

    implicitWidth: label.implicitWidth + (flat ? 8 : 16)
    implicitHeight: label.implicitHeight + (flat ? 0 : 8)
    opacity: enabled ? 1 : 0.3

    NeonPanel {
        anchors.fill: parent
        visible: !button.flat
        fill: mouse.containsMouse ? Theme.bgHover : "transparent"
    }

    BarText {
        id: label

        anchors.centerIn: parent
        text: button.icon
        font.pixelSize: button.flat ? Theme.fontSize : 16
        strongGlow: button.flat && mouse.containsMouse
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }
}
