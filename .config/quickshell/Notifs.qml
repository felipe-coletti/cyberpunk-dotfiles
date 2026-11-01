pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// The notification server, shared by the popups and the notification center.
// Every notification stays in the center (history) until it's closed or
// cleared; a popup shows it for a moment when it arrives
Singleton {
    id: root

    // All notifications, newest first
    readonly property var all: server.trackedNotifications.values.slice().reverse()
    // The ones showing as popups right now
    property var popups: []
    // When each one arrived, by id
    property var times: ({})
    // Something arrived since the center was last opened
    property bool unread: false

    function hidePopup(notification) {
        popups = popups.filter(n => n !== notification);
    }

    function dismiss(notification) {
        hidePopup(notification);
        notification.dismiss();
    }

    function clear() {
        for (const notification of all)
            notification.dismiss();
        popups = [];
    }

    // Runs the notification's default action (when it has one) and closes it
    function activate(notification) {
        const action = Array.from(notification.actions).find(a => a.identifier === "default");
        if (action)
            action.invoke();
        dismiss(notification);
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
            root.times = Object.assign({}, root.times, { [notification.id]: new Date() });
            root.popups = [notification, ...root.popups];
            root.unread = true;
            // Closed by the app: it also leaves the popups
            notification.closed.connect(() => root.hidePopup(notification));
        }
    }
}
