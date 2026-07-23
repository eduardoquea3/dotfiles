import QtQuick // for Text
import Quickshell.Io // for Process
import Quickshell.Networking

Item {
    id: wifiRect
    width: visible ? wifiText.implicitWidth + 12 : 0
    height: 20

    property string label: ""

    visible: root.isDesktop ? true : label !== ""

    Process {
        id: wifiProc
        command: root.isDesktop
            ? ["sh", "-c", "state=$(nmcli -t -f CONNECTIVITY general 2>/dev/null); if [ \"$state\" = full ]; then dev=$(nmcli -t -f DEVICE,STATE dev | while IFS=: read -r d s; do [ \"$s\" = connected ] && { printf '%s' \"$d\"; break; }; done); if [ -n \"$dev\" ]; then ip=$(nmcli -t -f IP4.ADDRESS dev show \"$dev\" 2>/dev/null | sed -n 's/^IP4.ADDRESS\\[[0-9]\\+\\]://p' | head -n1); if [ -n \"$ip\" ]; then printf 'ip:%s\\n' \"$ip\"; exit; fi; fi; fi; printf 'noconn\\n' "]
            : ["sh", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2 || echo disconnected"]
        stdout: SplitParser {
            onRead: data => {
                var s = data.trim();
                if (root.isDesktop) {
                    wifiRect.label = s.startsWith("ip:")
                        ? "󰇚 " + s.slice(3)
                        : "󰤭 No connection";
                    return;
                }

                wifiRect.label = (s && s !== "disconnected")
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

        text: parent.label

        color: root.isDesktop && parent.label === "󰤭 No connection"
            ? root.colRed
            : root.isDesktop
                ? root.colGreen
                : root.colYellow
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
