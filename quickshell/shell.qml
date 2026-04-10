import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import Quickshell.Hyprland
import "./widgets"
import "./modules/wallpaper"

ShellRoot {
    id: root

    // =========================================================
    // Theme singleton — all colors live in Theme.qml
    // =========================================================
    Theme { id: theme }

    // =========================================================
    // Theme / Bar properties (used by modules/bar/* components)
    // =========================================================
    property int radius: 5
    property int fontSize: 10
    property string fontFamily: "JetBrainsMono Nerd Font"
    property color colBg:     theme.colBg
    property color colFg:     theme.colFg
    property color colBorder: theme.colBorder
    property color colRed:    theme.colRed
    property color colGreen:  theme.colGreen
    property color colBlue:   theme.colBlue
    property color colYellow: theme.colYellow
    property color colPurple: theme.colPurple

    // Aliases used by Launcher
    property color walBackground: theme.colBg
    property color walForeground: theme.colFg
    property color walColor2:     theme.colGreen
    property color walColor5:     theme.colBlue
    property color walColor8:     theme.colBorder
    property color walColor13:    theme.colPurple

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
    // Wallpaper picker (overlay with romboid design)
    // =========================================================
    Wallpaper {}
}
