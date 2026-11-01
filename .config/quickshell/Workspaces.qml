import Quickshell
import Quickshell.Hyprland
import QtQuick

// Numbered workspaces in neon boxes. Workspaces 1-5 are always shown, even
// when they don't exist yet; the active one (and an urgent one) lights up.
// Click a number to go to it; scroll over them to go to the next or
// previous one, like SUPER + scroll
Row {
    id: root

    required property var screen

    readonly property var monitor: Hyprland.monitorFor(screen)
    readonly property int activeId: monitor?.activeWorkspace?.id ?? -1
    readonly property var workspaces: Hyprland.workspaces.values
    readonly property var ids: {
        const ids = new Set([1, 2, 3, 4, 5]);
        for (const workspace of workspaces) {
            if (workspace.id > 0)
                ids.add(workspace.id);
        }
        return Array.from(ids).sort((a, b) => a - b);
    }

    // With the Lua config, Hyprland takes dispatchers as Lua, like the ones
    // in binds.lua
    function goTo(target) {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${JSON.stringify(target)} })`);
    }

    spacing: 7

    Repeater {
        model: root.ids

        Item {
            id: button

            required property int modelData
            readonly property var workspace: root.workspaces.find(w => w.id === modelData)
            readonly property bool lit: modelData === root.activeId || (workspace?.urgent ?? false)

            width: label.implicitWidth + 20
            height: 24

            // Lit: a glowing neon box; otherwise a faint outline
            NeonPanel {
                anchors.fill: parent
                visible: button.lit
                fill: Theme.accentHover
            }

            Rectangle {
                anchors.fill: parent
                visible: !button.lit
                color: mouse.containsMouse ? Theme.bgHover : "transparent"
                border.width: 1
                border.color: Theme.borderSoft
            }

            BarText {
                id: label
                anchors.centerIn: parent
                text: button.workspace?.name ?? button.modelData
                color: button.lit || mouse.containsMouse ? Theme.text : Theme.textDim
                glow: button.lit
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.goTo(button.modelData)
                onWheel: event => root.goTo(event.angleDelta.y > 0 ? "e-1" : "e+1")
            }
        }
    }
}
