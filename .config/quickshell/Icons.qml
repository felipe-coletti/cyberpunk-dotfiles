pragma Singleton

import Quickshell
import QtQuick

// Icons shared by the bar and the on-screen indicator
Singleton {
    function volume(percent, muted, headphones) {
        if (muted)
            return "󰝟";
        if (headphones)
            return "󰋋";
        return percent < 34 ? "󰕿" : percent < 67 ? "󰖀" : "󰕾";
    }

    function brightness(percent) {
        return percent < 34 ? "󰃞" : percent < 67 ? "󰃟" : "󰃠";
    }
}
