import QtQuick

// A bar item: an icon/text with a tooltip, clicks and scroll
Item {
    id: item

    property alias text: label.text
    property alias color: label.color
    property alias bold: label.font.bold
    property alias glow: label.glow
    property alias strongGlow: label.strongGlow
    property alias fontSize: label.font.pixelSize
    property string tooltip
    readonly property alias hovered: mouse.containsMouse

    signal clicked(var mouse)
    signal scrolled(int direction)  // 1 = up, -1 = down

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    BarText {
        id: label
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => item.clicked(event)
        onWheel: event => item.scrolled(event.angleDelta.y > 0 ? 1 : -1)
    }

    Tooltip {
        target: item
        text: item.tooltip
        shown: mouse.containsMouse
    }
}
