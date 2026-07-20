import QtQuick // for Text
import Quickshell

Item {
    width: time.implicitWidth + 12
    height: 20

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
