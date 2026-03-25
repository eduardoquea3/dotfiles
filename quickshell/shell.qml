import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import Quickshell.Hyprland
import "./widgets"
import "./modules/launcher"

ShellRoot {
    id: root

    // =========================================================
    // Theme / Bar properties (used by modules/bar/* components)
    // =========================================================
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

    // Aliases used by Launcher
    property color walBackground: colBg
    property color walForeground: colFg
    property color walColor2: colGreen
    property color walColor5: colBlue
    property color walColor8: colBorder
    property color walColor13: colPurple

    // =========================================================
    // Bar state
    // =========================================================
    property bool barVisible: true

    IpcHandler {
        target: "bar"
        function toggle() { root.barVisible = !root.barVisible }
    }

    // =========================================================
    // Bar (one per screen)
    // =========================================================
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
            visible: root.barVisible
        }
    }

    // =========================================================
    // Launcher (self-contained: state, processes, panels)
    // =========================================================
    Launcher {}
}
