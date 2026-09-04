import QtQuick
import Quickshell.Io

Item {
    id: wifiRect
    width: wifiText.implicitWidth + (root.isDesktop ? 12 : 8)
    height: 20

    property bool connected: false
    property string label: ""
    signal clicked()

    Process {
        id: wifiProc
        command: root.isDesktop
            ? ["sh", "-c", "state=$(nmcli -t -f CONNECTIVITY general 2>/dev/null); if [ \"$state\" = full ]; then dev=$(nmcli -t -f DEVICE,STATE dev | while IFS=: read -r d s; do [ \"$s\" = connected ] && { printf '%s' \"$d\"; break; }; done); if [ -n \"$dev\" ]; then ip=$(nmcli -t -f IP4.ADDRESS dev show \"$dev\" 2>/dev/null | sed -n 's/^IP4.ADDRESS\\[[0-9]\\+\\]://p' | head -n1); if [ -n \"$ip\" ]; then printf 'ip:%s\\n' \"$ip\"; exit; fi; fi; fi; printf 'noconn\\n'"]
            : ["sh", "-c", "if nmcli -t -f active dev wifi 2>/dev/null | grep -qx 'yes'; then printf 'connected\\n'; else printf 'disconnected\\n'; fi"]
        stdout: SplitParser {
            onRead: data => {
                const state = data.trim();
                if (root.isDesktop) {
                    wifiRect.connected = state.startsWith("ip:");
                    wifiRect.label = wifiRect.connected
                        ? "󰤨 " + state.slice(3)
                        : "󰤭 No connection";
                    return;
                }

                wifiRect.connected = state === "connected";
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

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: wifiMouse.containsMouse
            ? Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.1)
            : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Text {
        id: wifiText
        anchors.centerIn: parent

        text: root.isDesktop ? parent.label : (parent.connected ? "󰤨" : "󰤭")
        color: parent.connected ? root.colGreen : root.colRed
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    MouseArea {
        id: wifiMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: wifiRect.clicked()
    }
}
