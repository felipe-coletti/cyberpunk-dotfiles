import Quickshell
import QtQuick
import QtQuick.Controls

// The time over the date, in the date order of the system language; click to
// add the weekday, and hover for the month calendar (scroll to change the
// month, middle click to go back to the current one)
Item {
    id: root

    property bool showWeekday: false
    property int monthOffset: 0
    readonly property var shownMonth: {
        const date = new Date(clock.date.getFullYear(), clock.date.getMonth() + monthOffset, 1);
        return { year: date.getFullYear(), month: date.getMonth() };
    }

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BarText {
        id: label
        anchors.centerIn: parent
        text: I18n.format(clock.date, root.showWeekday ? I18n.t.clockAlt : I18n.t.clock)
        lineHeight: 1.05
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                root.monthOffset = 0;
            else
                root.showWeekday = !root.showWeekday;
        }
        onWheel: event => root.monthOffset += event.angleDelta.y > 0 ? -1 : 1
        onContainsMouseChanged: if (!containsMouse) root.monthOffset = 0
    }

    PopupWindow {
        id: popup

        readonly property int glowSpace: 8

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: mouse.containsMouse
        color: "transparent"
        implicitWidth: calendar.implicitWidth + 24 + 2 * glowSpace
        implicitHeight: calendar.implicitHeight + 16 + 6 + 2 * glowSpace

        NeonPanel {
            anchors.fill: parent
            anchors.margins: popup.glowSpace
            anchors.topMargin: popup.glowSpace + 6

            Column {
                id: calendar
                anchors.centerIn: parent
                spacing: 6

                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    // The standalone month name ("октябрь", not "октября")
                    text: `${Qt.locale().standaloneMonthName(root.shownMonth.month)} ${root.shownMonth.year}`
                    font.bold: true
                }

                DayOfWeekRow {
                    width: grid.width
                    locale: grid.locale
                    delegate: BarText {
                        required property string shortName
                        // "seg." → "seg", so the names fit in the columns
                        text: shortName.replace(/\.$/, "")
                        color: Theme.textDim
                        glow: false
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MonthGrid {
                    id: grid
                    width: 7 * 32
                    month: root.shownMonth.month
                    year: root.shownMonth.year
                    locale: Qt.locale()
                    delegate: BarText {
                        required property var model
                        readonly property bool today: model.today
                        text: model.day
                        horizontalAlignment: Text.AlignHCenter
                        opacity: model.month === grid.month ? 1 : 0.3
                        glow: today
                        font.bold: today
                        font.underline: today
                    }
                }
            }
        }
    }
}
