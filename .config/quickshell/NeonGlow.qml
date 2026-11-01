import QtQuick
import QtQuick.Effects

// The neon glow around texts and icons, like text-shadow: 0 0 3px in the
// GTK theme. Used as layer.effect; strong is the hover/alert glow
MultiEffect {
    property bool strong: false

    shadowEnabled: true
    shadowColor: Theme.neon
    shadowHorizontalOffset: 0
    shadowVerticalOffset: 0
    shadowBlur: strong ? 0.6 : 0.3
    shadowOpacity: strong ? 1 : 0.8
    blurMax: 12
    autoPaddingEnabled: true
}
