import Quickshell
import Quickshell.Wayland
import QtQuick

import "../modules/bar"

PanelWindow {
    color: "transparent"
    anchors {
        top: false
        left: true
        right: true
        bottom: true
    }
    implicitHeight: 26

    Row {
        anchors {
            left: parent.left
            leftMargin: 4
        }
        spacing: 6
        Workspace {}
        Ram {}
    }

    Row {
        anchors {
            right: parent.right
            rightMargin: 4
        }
        spacing: 6
        Brightness {}
        Volume {}
        Wifi {}
        Date {}
        Battery {}
        Time {}
        Wlogout {}
    }
}
