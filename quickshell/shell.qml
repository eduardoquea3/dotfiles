import Quickshell // for PanelWindow
import Quickshell.Io // for Process
import Quickshell.Hyprland // for Hyprland
import Quickshell.Widgets // for IconImage
import QtQuick // for Text
import QtQuick.Controls // for Button
import Quickshell.Services.UPower
import Quickshell.Networking

// palette = 0=#090E13
// palette = 1=#c4746e
// palette = 2=#8a9a7b
// palette = 3=#c4b28a
// palette = 4=#8ba4b0
// palette = 5=#a292a3
// palette = 6=#8ea4a2
// palette = 7=#a4a7a4
// palette = 8=#5C6066
// palette = 9=#e46876
// palette = 10=#87a987
// palette = 11=#e6c384
// palette = 12=#7fb4ca
// palette = 13=#938aa9
// palette = 14=#7aa89f
// palette = 15=#c5c9c7

// background = #090E13
// foreground = #c5c9c7
// cursor-color = #c5c9c7
// selection-background = #22262D
// selection-foreground = #c5c9c7

PanelWindow {
    id: root

    property int memUsage: 0
    property int radius: 5
    property int fontSize: 10
    property string fontFamily: "JetBrainsMono Nerd Font"
    property color colBg: "#090E13"
    property color colFg: "#ffffff"
    property color colBorder: "#555555"
    property color colRed: "#c4746e"
    property color colGreen: "#87a987"
    property color colBlue: "#7fb4ca"

    color: "transparent"
    anchors {
        top: false
        left: true
        right: true
        bottom: true
    }

    implicitHeight: 26

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

    // Update your timer to run both processes
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true;
        }
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: 4
        }
        spacing: 6

        Repeater {
            model: Hyprland.workspaces
            delegate: Rectangle {
                required property var modelData
                visible: modelData.id > 0
                width: 34
                height: 20
                radius: root.radius
                color: root.colBg
                border.width: modelData.focused ? 2 : 1
                border.color: modelData.focused ? "#e6c384" : root.colBorder

                MouseArea {
                    anchors.fill: parent
                    onClicked: modelData.activate()
                }

                Text {
                    anchors.centerIn: parent
                    text: (modelData.focused ? "󰮯" : "󰊠") + " " + modelData.id
                    font.pointSize: 7
                    color: modelData.focused ? "#e6c384" : "white"
                }
            }
        }

        Rectangle {
            required property var modelData
            visible: modelData.id == 0
            width: 42
            height: 20
            radius: root.radius
            color: root.colBg
            border.width: 1
            border.color: root.colRed

            Text {
                anchors.centerIn: parent
                text: "󰍛 " + memUsage + "GB"
                color: root.colRed
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }
        }
    }

    Row {
        anchors {
            right: parent.right
            rightMargin: 4
        }
        spacing: 8

        Rectangle {
            color: root.colBg
            width: 120
            height: 20
            radius: root.radius
            border.width: 1
            border.color: root.colBlue

            Text {
                anchors.centerIn: parent

                text: {
                    var dev = Network.name;
                    if (!dev)
                        return "󰤮 no wifi";

                    if (dev.activeNetwork)
                        return "󰤨 " + dev.activeNetwork.ssid;

                    return "󰤮 disconnected";
                }

                color: root.colBlue
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }
        }

        Rectangle {
            color: root.colBg
            width: 90
            height: 20
            radius: root.radius
            border.width: 1
            border.color: root.colGreen

            Text {
                id: date
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), " dd/MM/yy")
                color: root.colGreen
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: date.text = Qt.formatDateTime(new Date(), " dd/MM/yy")
                }
            }
        }

        Rectangle {
            color: root.colBg
            width: 50
            height: 20
            radius: root.radius
            border.width: 1
            border.color: root.colGreen

            Text {
                anchors.centerIn: parent

                text: {
                    if (!UPower.displayDevice.ready)
                        return " ...";
                    return " " + Math.round(UPower.displayDevice.percentage * 100) + "%";
                }

                color: root.colGreen
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }
        }

        Rectangle {
            color: root.colBg
            width: 80
            height: 20
            radius: root.radius
            border.width: 1
            border.color: root.colBlue

            Text {
                id: time
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), " HH:mm:ss")
                color: root.colBlue
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }

                Timer {
                    interval: 10
                    running: true
                    repeat: true
                    onTriggered: time.text = Qt.formatDateTime(new Date(), " HH:mm:ss")
                }
            }
        }

        Rectangle {
            width: 24
            height: 20
            radius: 5
            color: root.colBg
            border.width: 1
            border.color: root.colRed

            Text {
                anchors.centerIn: parent
                text: ""
                color: root.colRed
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Hyprland.dispatch("exec pkill -x wlogout || ~/.config/hypr/scripts/wlogout 2 &");
                }
            }
        }
    }
}
