import QtQuick // for Text
import Quickshell

Rectangle {
    color: root.colBg
    width: time.implicitWidth + 16
    height: 20
    radius: root.radius
    border.width: 1
    border.color: root.colBlue

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: time
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: root.colBlue
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
