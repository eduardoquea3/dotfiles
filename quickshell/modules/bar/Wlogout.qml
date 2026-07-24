import QtQuick // for Text
import Quickshell
import Quickshell.Io
import Quickshell.Wayland // for Edges

Item {
    id: powerMenu
    width: wlogout.implicitWidth + 12
    height: 20

    property bool menuVisible: false
    readonly property string imagePickerScript: Quickshell.env("HOME") + "/.config/hypr/scripts/image-picker"
    property var menuEntries: [
        { label: "Editar Imagen", command: imagePickerScript }
    ]

    Text {
        id: wlogout
        anchors.centerIn: parent
        text: "☰"
        color: root.colRed
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: powerMenu.menuVisible = !powerMenu.menuVisible
    }

    Process {
        id: imagePickerProc
    }

    PopupWindow {
        visible: powerMenu.menuVisible
        grabFocus: true
        color: "transparent"
        implicitWidth: 180
        implicitHeight: 44

        anchor.item: powerMenu
        anchor.edges: Edges.Top | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Left

        onVisibleChanged: {
            if (!visible)
                powerMenu.menuVisible = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: root.colBg
            border.color: root.colBorder
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4

                Repeater {
                    model: powerMenu.menuEntries

                    delegate: Rectangle {
                        required property var modelData

                        width: 168
                        height: 28
                        radius: 8
                        color: hoverArea.containsMouse ? Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.22) : "transparent"
                        border.color: hoverArea.containsMouse ? root.colBlue : "transparent"
                        border.width: hoverArea.containsMouse ? 1 : 0

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: hoverArea.containsMouse ? root.colBlue : root.colFg
                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize - 1
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                powerMenu.menuVisible = false
                                imagePickerProc.command = [modelData.command]
                                imagePickerProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
