import QtQuick // for Text
import Quickshell

Rectangle {
    color: root.colBg
    width: date.implicitWidth + 16
    height: 20
    radius: root.radius
    border.width: 1
    border.color: root.colGreen

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
