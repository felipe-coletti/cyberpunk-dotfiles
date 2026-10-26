import QtQuick 2.15
import SddmComponents 2.0

// Login screen with the same layout as the hyprlock lock screen: time,
// date, user and password, plus the session and power buttons
Rectangle {
    id: root

    // theme.conf.user (written by ~/.config/neon/apply.sh) overrides theme.conf
    readonly property color neon: config.color || "#ffffff"
    readonly property color neonDim: Qt.rgba(neon.r, neon.g, neon.b, 0.5)
    readonly property string fontFamily: config.font || "JetBrainsMono Nerd Font"

    property int sessionIndex: sessionModel.lastIndex
    property var sessionNames: []
    property string message: ""

    width: 1920
    height: 1080
    color: "#000000"

    // Texts translated by SDDM itself, in the system language
    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.message = textConstants.loginFailed
            password.text = ""
            password.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.message = ""
        }
    }

    function login() {
        root.message = ""
        sddm.login(user.text, password.text, root.sessionIndex)
    }

    // Session names, read once from the model
    Repeater {
        model: sessionModel

        Item {
            Component.onCompleted: {
                var names = root.sessionNames
                names[index] = model.name
                root.sessionNames = names
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            time.text = Qt.formatTime(now, "hh:mm")
            date.text = now.toLocaleDateString(Qt.locale(), Locale.LongFormat)
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 18

        NeonText {
            id: time
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.neon
            font.family: root.fontFamily
            font.pixelSize: 96
        }

        NeonText {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.neonDim
            glow: 0.15
            font.family: root.fontFamily
            font.pixelSize: 18
        }

        Item { width: 1; height: 24 }

        // User (the last one to log in, but it can be changed)
        Item {
            width: 320
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter

            NeonBox {
                anchors.fill: parent
                color: root.neon
                highlighted: user.activeFocus
            }

            Text {
                id: userIcon
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "󰀄"
                color: root.neon
                font.family: root.fontFamily
                font.pixelSize: 16
            }

            TextInput {
                id: user
                anchors.left: userIcon.right
                anchors.right: parent.right
                anchors.leftMargin: 12
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: userModel.lastUser
                color: root.neon
                selectionColor: root.neonDim
                font.family: root.fontFamily
                font.pixelSize: 15
                clip: true
                KeyNavigation.tab: password
                onAccepted: password.forceActiveFocus()
            }
        }

        // Password
        Item {
            width: 320
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter

            NeonBox {
                anchors.fill: parent
                color: root.neon
                highlighted: password.activeFocus
            }

            Text {
                anchors.centerIn: parent
                visible: password.text.length === 0
                text: "󰌾  " + textConstants.password.toUpperCase()
                color: root.neonDim
                font.family: root.fontFamily
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
                color: root.neon
                selectionColor: root.neonDim
                font.family: root.fontFamily
                font.pixelSize: 18
                font.letterSpacing: 4
                clip: true
                focus: true
                KeyNavigation.backtab: user
                KeyNavigation.tab: loginButton
                onAccepted: root.login()
            }
        }

        NeonButton {
            id: loginButton
            width: 320
            anchors.horizontalCenter: parent.horizontalCenter
            text: textConstants.login
            color: root.neon
            fontFamily: root.fontFamily
            primary: true
            onClicked: root.login()
        }

        // Login error and Caps Lock warning
        NeonText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.message || (keyboard.capsLock ? textConstants.capslockWarning : " ")
            color: root.neon
            font.family: root.fontFamily
            font.pixelSize: 14
        }
    }

    // Session (click to switch)
    NeonButton {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 24
        text: textConstants.session + ": " + (root.sessionNames[root.sessionIndex] || "")
        color: root.neon
        fontFamily: root.fontFamily
        visible: sessionModel.rowCount() > 0
        onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount()
    }

    // Power
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 10

        NeonButton {
            text: textConstants.reboot
            color: root.neon
            fontFamily: root.fontFamily
            enabled: sddm.canReboot
            onClicked: sddm.reboot()
        }

        NeonButton {
            text: textConstants.shutdown
            color: root.neon
            fontFamily: root.fontFamily
            enabled: sddm.canPowerOff
            onClicked: sddm.powerOff()
        }
    }

    Component.onCompleted: {
        if (user.text.length === 0)
            user.forceActiveFocus()
        else
            password.forceActiveFocus()
    }
}
