import QtQuick // for Text
import Quickshell

Item {
    width: date.implicitWidth + 12
    height: 20

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: date
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "dd/MM/yy")
        color: root.colGreen
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
