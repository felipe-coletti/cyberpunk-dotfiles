import Quickshell
import QtQuick

// Text shown under a bar item while the mouse is over it, in a neon box
PopupWindow {
    id: tip

    property Item target
    property string text
    property bool shown

    readonly property int glowSpace: 8

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    visible: shown && text !== ""
    color: "transparent"
    implicitWidth: label.implicitWidth + 20 + 2 * glowSpace
    implicitHeight: label.implicitHeight + 12 + 6 + 2 * glowSpace

    NeonPanel {
        anchors.fill: parent
        anchors.margins: tip.glowSpace
        anchors.topMargin: tip.glowSpace + 6
    }

    BarText {
        id: label
        x: tip.glowSpace + 10
        y: tip.glowSpace + 6 + 6
        text: tip.text
        textFormat: Text.PlainText
    }
}
