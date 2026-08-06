import "./modules/bar"
import "./modules/clipboard"
import "./modules/notifications"
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
    // =========================================================
    // Bar state
    // =========================================================
    property bool barVisible: true
    property string barPosition: "bottom"
    property bool notificationDnd: false
    property bool notificationPopupVisible: false
    property bool controlCenterOpen: false
    property var mediaPlayer: null
    property var notificationService: notifications
    property int chassisType: 0
    property bool isDesktop: chassisType === 3
    property bool isNotebook: chassisType === 10
    property bool showBatteryModule: isNotebook
    property bool showBrightnessModule: isNotebook

    function toggleControlCenter() {
        controlCenterOpen = !controlCenterOpen;
    }

    function showMedia(player) {
        mediaPlayer = player;
        controlCenterOpen = true;
    }

    function closeMedia() {
        controlCenterOpen = false;
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
        function toggle() {
            root.toggleControlCenter();
        }

        target: "controlCenter"
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

    Notifications {
        id: notifications
    }

    Loader {
        source: "modules/media/Media.qml"
    }

    // =========================================================
    // Wallpaper picker (overlay with romboid design)
    // =========================================================
    Wallpaper {
    }

    // =========================================================
    // Clipboard history overlay
    // =========================================================
    Clipboard {
        id: clipboardWindow
    }

}
