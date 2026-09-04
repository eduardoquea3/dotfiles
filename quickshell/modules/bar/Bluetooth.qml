import QtQuick
import Quickshell.Io

Item {
    id: bluetoothRect
    width: bluetoothText.implicitWidth + 8
    height: 20

    property bool connected: false
    signal clicked()

    Process {
        id: bluetoothProc
        command: ["sh", "-c", "if bluetoothctl devices Connected 2>/dev/null | grep -q .; then printf 'connected\\n'; else printf 'disconnected\\n'; fi"]
        stdout: SplitParser {
            onRead: data => bluetoothRect.connected = data.trim() === "connected"
        }
    }

    Component.onCompleted: bluetoothProc.running = true

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: if (!bluetoothProc.running) bluetoothProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: bluetoothMouse.containsMouse
            ? Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.1)
            : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Text {
        id: bluetoothText
        anchors.centerIn: parent
        text: parent.connected ? "󰂯" : "󰂲"
        color: parent.connected ? root.colBlue : root.colRed
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    MouseArea {
        id: bluetoothMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: bluetoothRect.clicked()
    }
}
