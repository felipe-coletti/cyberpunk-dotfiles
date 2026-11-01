import Quickshell
import QtQuick

// Weather city menu (right click on the weather): type a city and press
// Enter, or choose the automatic location from the IP
Menu {
    name: "city"
    placeholder: I18n.t.cityPrompt
    menuHeight: 152

    readonly property string script: Quickshell.env("HOME") + "/.config/quickshell/scripts/weather-city.sh"

    entries: {
        const city = query.trim();
        const entries = [];
        if (city !== "")
            entries.push({ label: city, icon: "󰍎", run: () => Quickshell.execDetached([script, city]) });
        entries.push({ label: I18n.t.automatic, icon: "󰆤", run: () => Quickshell.execDetached([script]) });
        return entries;
    }
}
