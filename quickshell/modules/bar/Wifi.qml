import QtQuick
import Quickshell.Io

Item {
    id: wifiRect
    width: wifiText.implicitWidth + 8
    height: 20

    property bool connected: false

    Process {
        id: wifiProc
        command: ["sh", "-c", "if nmcli -t -f active dev wifi 2>/dev/null | grep -qx 'yes'; then printf 'connected\\n'; else printf 'disconnected\\n'; fi"]
        stdout: SplitParser {
            onRead: data => {
                wifiRect.connected = data.trim() === "connected";
            }
        }
    }

    Component.onCompleted: wifiProc.running = true

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: if (!wifiProc.running) wifiProc.running = true
    }

    Text {
        id: wifiText
        anchors.centerIn: parent

        text: parent.connected ? "󰤨" : "󰤭"
        color: parent.connected ? root.colGreen : root.colRed
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
