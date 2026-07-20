import QtQuick
import Quickshell.Hyprland

Item {
    width: workspaceCapsule.width
    height: 20

    Rectangle {
        id: workspaceCapsule
        anchors.centerIn: parent
        width: workspaceRow.implicitWidth + 10
        height: 20
        radius: 10
        color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.28)

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    required property var modelData
                    visible: modelData.id > 0
                    width: 16
                    height: 16
                    radius: 8
                    color: modelData.focused ? root.colRed : root.colYellow

                    Text {
                        anchors.centerIn: parent
                        text: modelData.id
                        color: root.colBg
                        font {
                            family: root.fontFamily
                            pixelSize: 9
                            bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.activate()
                    }
                }
            }
        }
    }
}
