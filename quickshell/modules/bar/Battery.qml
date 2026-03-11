import QtQuick // for Text
import Quickshell.Services.UPower

Rectangle {
    color: root.colBg
    width: battery.implicitWidth + 16
    height: 20
    radius: root.radius
    border.width: 1
    border.color: root.colPurple

    Text {
        id: battery
        anchors.centerIn: parent

        text: {
            if (!UPower.displayDevice.ready)
                return " ...";
            return " " + Math.round(UPower.displayDevice.percentage * 100) + "%";
        }

        color: root.colPurple
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
