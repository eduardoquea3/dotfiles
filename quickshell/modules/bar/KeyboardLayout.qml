import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: layoutIndicator

    property string layoutLabel: "US"

    width: layoutText.implicitWidth + 12
    height: 20

    function updateLayout(keymap) {
        const normalized = keymap.toLowerCase()
        if (normalized.includes("latin american") || normalized.includes("latam")) {
            layoutLabel = "LATAM"
        } else if (normalized.includes("english (us)") || normalized === "us") {
            layoutLabel = "US"
        } else {
            layoutLabel = keymap
        }
    }

    Process {
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text)
                    const keyboards = devices.keyboards || []
                    const keyboard = keyboards.find(device => device.main) || keyboards[0]
                    if (keyboard && keyboard.active_keymap)
                        layoutIndicator.updateLayout(keyboard.active_keymap)
                } catch (error) {
                    console.warn("Could not read active keyboard layout:", error)
                }
            }
        }
        Component.onCompleted: running = true
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "activelayout")
                return

            const values = event.parse(2)
            if (values.length === 2)
                layoutIndicator.updateLayout(values[1])
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.28)

        Text {
            id: layoutText
            anchors.centerIn: parent
            text: layoutIndicator.layoutLabel
            color: root.colBlue
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }
    }
}
