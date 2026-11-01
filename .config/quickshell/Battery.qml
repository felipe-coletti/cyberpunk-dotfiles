import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Laptop battery from UPower; hidden on computers without one
BarItem {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device?.isLaptopBattery ?? false
    // UPower reports 0-1 in some Quickshell versions and 0-100 in others
    readonly property int percent: {
        const value = device?.percentage ?? 0;
        return Math.round(value <= 1 ? value * 100 : value);
    }
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
    readonly property var icons: ["󰂎", "󰁼", "󰁾", "󰂀", "󰂂", "󰁹"]

    visible: present
    text: charging ? `󰂄 ${percent}%`
        : `${icons[Math.min(icons.length - 1, Math.floor(percent * icons.length / 100))]} ${percent}%`
    // Low battery: a stronger glow (and bold when critical), since the theme
    // is monochrome
    strongGlow: !charging && percent <= 20
    bold: !charging && percent <= 10
}
