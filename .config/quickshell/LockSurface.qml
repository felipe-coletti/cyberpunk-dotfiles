import Quickshell
import Quickshell.Wayland
import QtQuick

// What the lock screen shows on each monitor, with the same layout as the
// login screen (sddm/cyberpunk/Main.qml): time, date, the user and the
// password in neon boxes, and the unlock button. Keep both in sync
WlSessionLockSurface {
    id: surface

    required property var lock

    readonly property string user: Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""

    function unlock() {
        surface.lock.unlock(password.text);
    }

    color: Theme.bg

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 18

        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: I18n.format(clock.date, "HH:mm")
            font.pixelSize: 96
        }

        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clock.date.toLocaleDateString(Qt.locale(), Locale.LongFormat)
            color: Theme.textDim
            font.pixelSize: 18
        }

        Item { width: 1; height: 24 }

        // The user of this session
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 44

            NeonPanel {
                anchors.fill: parent
            }

            BarText {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "󰀄   " + surface.user
                font.pixelSize: 15
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 44

            NeonPanel {
                anchors.fill: parent
                fill: password.activeFocus ? Theme.bgHover : Theme.bg
            }

            BarText {
                anchors.centerIn: parent
                visible: password.text === ""
                text: "󰌾  " + I18n.t.password.toUpperCase()
                color: Theme.textDim
                glow: false
                font.pixelSize: 14
            }

            TextInput {
                id: password

                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: Theme.text
                selectionColor: Theme.textDim
                font.family: Theme.font
                font.pixelSize: 18
                font.letterSpacing: 4
                clip: true
                focus: true
                readOnly: surface.lock.checking

                Component.onCompleted: forceActiveFocus()
                onTextEdited: surface.lock.failed = false
                Keys.onReturnPressed: surface.unlock()
                Keys.onEnterPressed: surface.unlock()
                Keys.onEscapePressed: text = ""
            }
        }

        // Unlock: filled, like the login screen's main button
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 34

            NeonPanel {
                anchors.fill: parent
                fill: unlockMouse.containsMouse ? Qt.alpha(Theme.neon, 0.85) : Theme.neon
            }

            BarText {
                anchors.centerIn: parent
                text: I18n.t.unlock.toUpperCase()
                color: Theme.bg
                glow: false
                font.pixelSize: 13
            }

            MouseArea {
                id: unlockMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: surface.unlock()
            }
        }

        // Wrong password
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: surface.lock.failed ? I18n.t.wrongPassword : " "
            font.pixelSize: 14
        }
    }

    Connections {
        target: surface.lock

        function onCleared() {
            password.text = "";
        }
    }
}
