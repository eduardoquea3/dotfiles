import "./modules/bar"
import "./modules/clipboard"
import "./modules/launcher"
import "./modules/wallpaper"
import "./widgets"
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // =========================================================
    // Theme / Bar properties (used by modules/bar/* components)
    // =========================================================
    property int radius: 5
    property int fontSize: 10
    property string fontFamily: "JetBrainsMono Nerd Font"
    property color colBg: theme.colBg
    property color colFg: theme.colFg
    property color colBorder: theme.colBorder
    property color colRed: theme.colRed
    property color colGreen: theme.colGreen
    property color colBlue: theme.colBlue
    property color colYellow: theme.colYellow
    property color colPurple: theme.colPurple
    // Aliases used by Launcher
    property color walBackground: theme.colBg
    property color walForeground: theme.colFg
    property color walColor2: theme.colGreen
    property color walColor5: theme.colBlue
    property color walColor8: theme.colBorder
    property color walColor13: theme.colPurple
    property var launcherAnchors: ({
    })
    // =========================================================
    // Bar state
    // =========================================================
    property bool barVisible: true
    property string barPosition: "bottom"
    property bool screenshotActive: false
    property int chassisType: 0
    property bool isDesktop: chassisType === 3
    property bool isNotebook: chassisType === 10
    property bool showBatteryModule: isNotebook
    property bool showBrightnessModule: isNotebook

    function registerLauncherAnchor(screenName, item, window, topAnchored) {
        var anchors = {
        };
        for (var name in launcherAnchors) anchors[name] = launcherAnchors[name]
        anchors[screenName] = {
            "item": item,
            "window": window,
            "top": topAnchored
        };
        launcherAnchors = anchors;
    }

    function unregisterLauncherAnchor(screenName) {
        var anchors = {
        };
        for (var name in launcherAnchors) {
            if (name !== screenName)
                anchors[name] = launcherAnchors[name];

        }
        launcherAnchors = anchors;
    }

    // =========================================================
    // Theme singleton — all colors live in Theme.qml
    // =========================================================
    Theme {
        id: theme
    }

    CodexUsage {
        id: codexUsageModule
    }

    Process {
        id: chassisTypeProc

        command: ["sh", "-c", "cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                const value = parseInt(data.trim());
                if (!isNaN(value))
                    root.chassisType = value;

            }
        }

    }

    IpcHandler {
        function toggle() {
            root.barVisible = !root.barVisible;
        }

        target: "bar"
    }

    IpcHandler {
        function begin() {
            root.screenshotActive = true;
        }

        function end() {
            root.screenshotActive = false;
        }

        target: "screenshot"
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
            barVisible: root.barVisible
            codexUsage: codexUsageModule
        }

    }

    // =========================================================
    // Wallpaper picker (overlay with romboid design)
    // =========================================================
    Wallpaper {
    }

    Launcher {
    }

    // =========================================================
    // Clipboard history overlay
    // =========================================================
    Clipboard {
        id: clipboardWindow
    }

}
