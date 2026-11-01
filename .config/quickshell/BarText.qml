import QtQuick

// Text in the neon color and font, with the neon glow (glow: false for
// dimmed texts, strongGlow for hover and alerts)
Text {
    property bool glow: true
    property bool strongGlow: false

    color: Theme.text
    font.family: Theme.font
    font.pixelSize: Theme.fontSize
    verticalAlignment: Text.AlignVCenter

    layer.enabled: glow
    layer.effect: NeonGlow {
        strong: strongGlow
    }
}
