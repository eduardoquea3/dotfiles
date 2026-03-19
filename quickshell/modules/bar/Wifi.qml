import QtQuick // for Text
import Quickshell.Io // for Process
import Quickshell.Networking

Rectangle {
    id: wifiRect
    color: root.colBg
    width: wifiText.implicitWidth + 16
    height: 20
    radius: root.radius
    border.width: 1
    border.color: root.colYellow

    property string ssid: ""

    visible: ssid !== ""

    Process {
        id: wifiProc
        command: ["sh", "-c", "iwgetid -r || echo disconnected"]
        stdout: SplitParser {
            onRead: data => {
                var s = data.trim();
                wifiRect.ssid = (s && s !== "disconnected")
                    ? "󰤨 " + s
                    : "";
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: wifiProc.running = true
    }

    Text {
        id: wifiText
        anchors.centerIn: parent

        text: parent.ssid

        color: root.colYellow
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
