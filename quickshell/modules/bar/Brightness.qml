import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: brightnessItem
    visible: root.showBrightnessModule
    width: visible ? brightnessText.implicitWidth + 12 : 0
    height: visible ? 20 : 0

    property int percent: 0

    function brightnessIcon() {
        if (percent < 34)
            return "󰃞";
        if (percent < 67)
            return "󰃟";
        return "󰃠";
    }

    Process {
        id: getProc
        command: ["sh", "-c", "b=$(cat /sys/class/backlight/*/brightness); m=$(cat /sys/class/backlight/*/max_brightness); echo $((b * 100 / m))"]
        running: brightnessItem.visible
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim());
                if (!isNaN(val))
                    brightnessItem.percent = val;
            }
        }
    }

    Process {
        id: setProc
        property int targetPercent: brightnessItem.percent
        command: ["brightnessctl", "set", setProc.targetPercent + "%"]
        onRunningChanged: if (!running)
            getProc.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: getProc.running = true
    }

    Text {
        id: brightnessText
        anchors.centerIn: parent
        text: brightnessIcon() + " " + percent + "%"
        color: root.colYellow
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 5 : -5;
            const newVal = Math.max(1, Math.min(100, brightnessItem.percent + delta));
            brightnessItem.percent = newVal;
            setProc.targetPercent = newVal;
            setProc.running = true;
        }
    }
}
