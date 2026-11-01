import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// A menu in the middle of the screen: a search field over a list, in neon.
// The launcher, the power menu and the weather city menu are built on it.
// It opens on the focused monitor and closes with Escape or a click outside
PanelWindow {
    id: menu

    // IPC target: `quickshell ipc call <name> toggle`
    required property string name
    // [{ label, icon (a glyph) or image (a file), run() }]
    property var entries: []
    property string placeholder
    property int menuWidth: 400
    property int menuHeight: 600
    readonly property alias query: input.text
    property int current: 0

    // Room around the box for its glow
    readonly property int glowSpace: 10

    function open() {
        const focused = Hyprland.focusedMonitor;
        const target = Quickshell.screens.find(s => focused && s.name === focused.name);
        if (target)
            screen = target;
        input.text = "";
        current = 0;
        visible = true;
        input.forceActiveFocus();
    }

    function close() {
        visible = false;
    }

    function toggle() {
        if (visible)
            close();
        else
            open();
    }

    function move(step) {
        if (entries.length > 0)
            current = (current + step + entries.length) % entries.length;
    }

    function activate(index) {
        const entry = entries[index];
        if (!entry)
            return;
        close();
        entry.run();
    }

    visible: false
    color: "transparent"
    implicitWidth: menuWidth + 2 * glowSpace
    implicitHeight: menuHeight + 2 * glowSpace
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-" + name

    onEntriesChanged: current = 0

    IpcHandler {
        target: menu.name

        function toggle(): void {
            menu.toggle();
        }
    }

    // A click outside the menu closes it
    HyprlandFocusGrab {
        windows: [menu]
        active: menu.visible
        onCleared: menu.close()
    }

    // The window: a black box with a glowing neon border, like wofi had
    NeonPanel {
        id: box

        anchors.fill: parent
        anchors.margins: menu.glowSpace

        // Search field in its own neon box, the text in uppercase
        Item {
            id: field

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            height: input.implicitHeight + 18

            NeonPanel {
                anchors.fill: parent
                fill: input.activeFocus ? Theme.bgHover : "transparent"
            }

            BarText {
                id: searchIcon

                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍉"
                font.pixelSize: 14
            }

            TextInput {
                id: input

                anchors.left: searchIcon.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                selectionColor: Theme.neon
                selectedTextColor: Theme.bg
                cursorDelegate: Rectangle {
                    width: 2
                    color: Theme.neon
                }
                font.family: Theme.font
                font.pixelSize: 14
                clip: true

                layer.enabled: true
                layer.effect: NeonGlow {}

                Keys.onEscapePressed: menu.close()
                Keys.onReturnPressed: menu.activate(menu.current)
                Keys.onEnterPressed: menu.activate(menu.current)
                Keys.onUpPressed: menu.move(-1)
                Keys.onDownPressed: menu.move(1)
                Keys.onTabPressed: menu.move(1)
                Keys.onBacktabPressed: menu.move(-1)

                BarText {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: menu.placeholder.toUpperCase()
                    color: Theme.textDim
                    glow: false
                    font.pixelSize: 14
                }
            }
        }

        ListView {
            id: list

            anchors.top: field.bottom
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true
            spacing: 4
            model: menu.entries
            currentIndex: menu.current
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 0

            // The list sets the position of each row, so the side margins
            // go inside it, on the highlight
            delegate: Item {
                id: row

                required property var modelData
                required property int index
                readonly property bool selected: index === menu.current

                width: list.width
                height: 32

                // Selected: a glowing neon box, like the active workspace
                NeonPanel {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    visible: row.selected
                    fill: Theme.bgHover
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !!row.modelData.image
                        source: row.modelData.image ?? ""
                        width: 22
                        height: 22
                        sourceSize.width: 44
                        sourceSize.height: 44
                        asynchronous: true
                    }

                    BarText {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !!row.modelData.icon
                        text: row.modelData.icon ?? ""
                        // Same width for every icon, so the labels line up
                        width: 18
                        horizontalAlignment: Text.AlignHCenter
                        color: row.selected ? Theme.text : Theme.textDim
                        glow: row.selected
                        font.pixelSize: 16
                    }

                    BarText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.label
                        color: row.selected ? Theme.text : Theme.textDim
                        glow: row.selected
                        width: row.width - 84
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: menu.current = row.index
                    onClicked: menu.activate(row.index)
                }
            }
        }
    }
}
