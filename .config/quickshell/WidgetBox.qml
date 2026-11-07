import QtQuick

// A widget's box on the desktop: black, with the glowing neon border and a
// 14px padding, like the GTK widgets had
NeonPanel {
    default property alias content: inner.data

    implicitWidth: 300
    implicitHeight: inner.implicitHeight + 28

    Column {
        id: inner

        x: 14
        y: 14
        width: parent.width - 28
        spacing: 10
    }
}
