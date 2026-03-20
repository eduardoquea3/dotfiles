import Quickshell // for PanelWindow
import QtQuick // for Text

import "modules/bar"

PanelWindow {
    id: root

    property int radius: 5
    property int fontSize: 10
    property string fontFamily: "JetBrainsMono Nerd Font"
    property color colBg: "#090E13"
    property color colFg: "#ffffff"
    property color colBorder: "#555555"
    property color colRed: "#c4746e"
    property color colGreen: "#87a987"
    property color colBlue: "#7fb4ca"
    property color colYellow: "#c4b28a"
    property color colPurple: "#a292a3"

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

        Volume {}

        Wifi {}

        Date {}

        Battery {}

        Time {}

        Wlogout {}
    }
}
