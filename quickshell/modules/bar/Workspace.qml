import QtQuick // for Text
import Quickshell.Hyprland // for Hyprland

Repeater {
    model: Hyprland.workspaces
    delegate: Rectangle {
        required property var modelData
        visible: modelData.id > 0
        width: workspace.implicitWidth + 16
        height: 20
        radius: root.radius
        color: root.colBg
        border.width: modelData.focused ? 2 : 1
        border.color: modelData.focused ? root.colYellow : root.colBorder

        MouseArea {
            anchors.fill: parent
            onClicked: modelData.activate()
        }

        Text {
            id: workspace
            anchors.centerIn: parent
            text: (modelData.focused ? "󰮯" : "󰊠") + " " + modelData.id
            font.pointSize: 7
            color: modelData.focused ? root.colYellow : root.colFg
        }
    }
}
