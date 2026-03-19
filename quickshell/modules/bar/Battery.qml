import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: batteryRect
    width: battery.implicitWidth + 16
    height: 20

    property int percent: UPower.displayDevice.percentage * 100
    property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging

    function batteryIcon() {
        if (charging) return "󰂄"

        if (percent >= 90) return "󰁹"
        if (percent >= 80) return "󰂂"
        if (percent >= 70) return "󰂁"
        if (percent >= 60) return "󰂀"
        if (percent >= 50) return "󰁿"
        if (percent >= 40) return "󰁾"
        if (percent >= 30) return "󰁽"
        if (percent >= 20) return "󰁼"
        if (percent >= 10) return "󰁻"

        return "󰁺"
    }

    function batteryColor() {
        if (charging) return "#4CAF50"

        if (percent >= 50) return root.colGreen
        if (percent >= 30) return root.colYellow

        return root.colRed
    }

    Rectangle {
        anchors.centerIn: parent
        width: battery.implicitWidth + 16
        height: 20
        radius: root.radius
        border.width: 1
        border.color: batteryColor()
        color: root.colBg

        Text {
            id: battery
            anchors.centerIn: parent
            text: batteryIcon() + " " + Math.round(percent) + "%"
            color: batteryColor()
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }
    }
}
