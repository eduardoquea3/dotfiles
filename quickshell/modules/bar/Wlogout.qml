import QtQuick // for Text
import Quickshell
import Quickshell.Hyprland // for Hyprland

Rectangle {
    width: wlogout.implicitWidth + 16
    height: 20
    radius: root.radius
    color: root.colBg
    border.width: 1
    border.color: root.colRed

    Text {
        id: wlogout
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
