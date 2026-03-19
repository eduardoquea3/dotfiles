import QtQuick // for Text
import Quickshell.Io // for Process

Rectangle {
    property int memUsage: 0

    required property var modelData
    visible: modelData.id == 0
    width: ram.implicitWidth + 16
    height: 20
    radius: root.radius
    color: root.colBg
    border.width: 1
    border.color: root.colBlue

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);

                var usedKB = parseInt(parts[2]) || 0;
                var usedGB = usedKB / (1024 * 1024);

                memUsage = usedGB.toFixed(2); // GB con 2 decimales
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true;
        }
    }

    Text {
        id: ram
        anchors.centerIn: parent
        text: "󰍛 " + memUsage + "GB"
        color: root.colBlue
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }
}
