import Quickshell
import QtQuick

// Power menu (SUPER + Q with no window open, or the button on the bar)
Menu {
    name: "power"
    placeholder: I18n.t.search
    menuWidth: 300
    menuHeight: 236

    readonly property var actions: [
        { label: I18n.t.shutdown, icon: "󰐥", command: ["systemctl", "poweroff"] },
        { label: I18n.t.reboot,   icon: "󰜉",   command: ["systemctl", "reboot"] },
        { label: I18n.t.lock,     icon: "󰌾",     command: ["hyprlock"] },
        { label: I18n.t.logout,   icon: "󰍃",   command: ["uwsm", "stop"] }
    ]

    entries: {
        const q = query.trim().toLowerCase();
        return actions
            .filter(action => action.label.toLowerCase().includes(q))
            .map(action => ({
                label: action.label,
                icon: action.icon,
                run: () => Quickshell.execDetached(action.command)
            }));
    }
}
