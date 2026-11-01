import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// One notification in a neon box: icon, title, text, its action buttons and
// the time it arrived. As a popup it hides after a moment (it stays in the
// notification center); critical ones get a stronger glow and stay
Item {
    id: card

    required property Notification modelData
    // true in the popups, false in the notification center
    property bool popup: true

    readonly property Notification notification: modelData
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical
    // Array.from: the list of actions isn't a JS array in every Qt version
    readonly property var actions: Array.from(notification.actions).filter(a => a.identifier !== "default")
    readonly property string icon: notification.image
        || (notification.appIcon ? Quickshell.iconPath(notification.appIcon, true) : "")
    readonly property date time: Notifs.times[notification.id] ?? new Date()

    width: parent ? parent.width : 360
    height: content.implicitHeight + 24

    // Hides the popup after the time the app asked for (5 seconds when it
    // didn't say), unless it's critical or the mouse is over it
    Timer {
        interval: card.notification.expireTimeout > 0 ? card.notification.expireTimeout * 1000 : 5000
        running: card.popup && !card.critical && !mouse.containsMouse
        onTriggered: Notifs.hidePopup(card.notification)
    }

    NeonPanel {
        anchors.fill: parent
        fill: mouse.containsMouse ? Theme.bgHover : Theme.bg
    }

    // Critical: a second border, so it stands out without leaving the neon
    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        visible: card.critical
        color: "transparent"
        border.width: 1
        border.color: Theme.border
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.LeftButton)
                Notifs.activate(card.notification);
            else
                Notifs.dismiss(card.notification);
        }
    }

    Column {
        id: content

        x: 12
        y: 12
        width: parent.width - 24
        spacing: 10

        Row {
            width: parent.width
            spacing: 10

            Image {
                visible: card.icon !== ""
                source: card.icon
                width: 32
                height: 32
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            BarText {
                visible: card.icon === ""
                width: 32
                horizontalAlignment: Text.AlignHCenter
                text: "󰂚"
                font.pixelSize: 22
                strongGlow: card.critical
            }

            Column {
                width: parent.width - 42 - side.width - 10
                spacing: 4

                BarText {
                    width: parent.width
                    text: card.notification.summary || card.notification.appName
                    font.bold: true
                    elide: Text.ElideRight
                    strongGlow: card.critical
                }

                BarText {
                    width: parent.width
                    visible: text !== ""
                    text: card.notification.body
                    color: Theme.textDim
                    glow: false
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    linkColor: Theme.text
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }
            }

            // The time it arrived, over the × that closes it
            Column {
                id: side

                spacing: 4

                BarText {
                    anchors.right: parent.right
                    text: I18n.format(card.time, "HH:mm")
                    color: Theme.textDim
                    glow: false
                }

                BarItem {
                    anchors.right: parent.right
                    text: "󰅖"
                    color: hovered ? Theme.text : Theme.textDim
                    glow: hovered
                    onClicked: Notifs.dismiss(card.notification)
                }
            }
        }

        // The other actions, as buttons (the default one is the click)
        Row {
            visible: card.actions.length > 0
            width: parent.width
            spacing: 6

            Repeater {
                model: card.actions

                Item {
                    required property NotificationAction modelData

                    width: (content.width - 6 * (card.actions.length - 1)) / card.actions.length
                    height: 28

                    NeonPanel {
                        anchors.fill: parent
                        glow: button.containsMouse
                        fill: button.containsMouse ? Theme.bgHover : "transparent"
                        borderColor: button.containsMouse ? Theme.border : Theme.borderSoft
                    }

                    BarText {
                        anchors.centerIn: parent
                        width: parent.width - 12
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: parent.modelData.text
                    }

                    MouseArea {
                        id: button

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            parent.modelData.invoke();
                            Notifs.dismiss(card.notification);
                        }
                    }
                }
            }
        }
    }
}
