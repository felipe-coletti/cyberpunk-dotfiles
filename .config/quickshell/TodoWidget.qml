import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Task list widget, at the top right of the desktop (under the windows), in
// the style of the to-do-list app. Tasks are kept in
// ~/.local/share/cyberpunk-dotfiles/todo.txt, one per line, with "x " in front
// of the ones that are done (like todo.txt), so they can be edited by hand
PanelWindow {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.local/share/cyberpunk-dotfiles"
    // [{ text, done }]
    property var tasks: []
    readonly property int doneCount: tasks.filter(t => t.done).length
    readonly property int glowSpace: 10

    function parse(text) {
        return text.split("\n").filter(line => line.trim() !== "").map(line => {
            const done = line.startsWith("x ");
            return { text: done ? line.slice(2) : line, done: done };
        });
    }

    function save(tasks) {
        root.tasks = tasks;
        file.setText(tasks.map(t => (t.done ? "x " : "") + t.text + "\n").join(""));
    }

    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.top: 20 - glowSpace
    margins.right: 20 - glowSpace
    implicitWidth: box.implicitWidth + 2 * glowSpace
    implicitHeight: box.implicitHeight + 2 * glowSpace
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    // The field takes the keyboard when it's clicked
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell-todo"
    mask: Region { item: box }

    // The folder of todo.txt, the first time
    Process {
        running: true
        command: ["mkdir", "-p", root.dir]
    }

    // Reloads when the file changes, also when it's edited by hand
    FileView {
        id: file

        path: root.dir + "/todo.txt"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.tasks = root.parse(text())
        onLoadFailed: root.tasks = []
    }

    WidgetBox {
        id: box

        x: root.glowSpace
        y: root.glowSpace

        Item {
            width: parent.width
            height: heading.implicitHeight

            BarText {
                id: heading
                text: I18n.t.todoTitle.toUpperCase()
                font.pixelSize: 13
                font.bold: true
            }

            BarText {
                anchors.right: parent.right
                visible: root.tasks.length > 0
                text: `${root.doneCount}/${root.tasks.length}`
                color: Theme.textDim
                glow: false
            }
        }

        // New task: type it and press Enter
        Item {
            width: parent.width
            height: 44

            NeonPanel {
                anchors.fill: parent
                fill: input.activeFocus ? Theme.bgHover : "transparent"
            }

            TextInput {
                id: input

                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                selectionColor: Theme.neon
                selectedTextColor: Theme.bg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                clip: true

                onAccepted: {
                    const task = text.trim();
                    if (task !== "") {
                        root.save([...root.tasks, { text: task, done: false }]);
                        text = "";
                    }
                }
                Keys.onEscapePressed: focus = false

                BarText {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: I18n.t.todoPlaceholder
                    color: Theme.textDim
                    glow: false
                }
            }
        }

        BarText {
            visible: root.tasks.length === 0
            text: I18n.t.todoEmpty
            color: Theme.textDim
            glow: false
        }

        // Grows with the list up to 260px, then scrolls
        ListView {
            id: list

            visible: root.tasks.length > 0
            width: parent.width
            height: Math.min(contentHeight, 260)
            clip: true
            spacing: 6
            model: root.tasks
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: row

                required property var modelData
                required property int index

                width: list.width
                height: Math.max(name.implicitHeight, 19)

                // Checkbox like the to-do-list: a square, filled when done
                Item {
                    id: check

                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16

                    NeonPanel {
                        anchors.fill: parent
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        visible: row.modelData.done
                        color: Theme.neon
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        onClicked: {
                            const tasks = root.tasks.slice();
                            tasks[row.index] = { text: row.modelData.text, done: !row.modelData.done };
                            root.save(tasks);
                        }
                    }
                }

                BarText {
                    id: name

                    anchors.left: check.right
                    anchors.leftMargin: 10
                    anchors.right: remove.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.text
                    elide: Text.ElideRight
                    color: row.modelData.done ? Theme.textDim : Theme.text
                    glow: !row.modelData.done
                    font.strikeout: row.modelData.done
                }

                WidgetButton {
                    id: remove

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    flat: true
                    icon: "󰅖"
                    onClicked: root.save(root.tasks.filter((_, i) => i !== row.index))
                }
            }
        }
    }
}
