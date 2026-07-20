import QtQuick // for Text
import Quickshell
import Quickshell.Hyprland // for Hyprland

Item {
    width: wlogout.implicitWidth + 12
    height: 20

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
