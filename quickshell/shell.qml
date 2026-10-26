import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import Quickshell.Hyprland
import "./widgets"
import "./modules/bar"
import "./modules/wallpaper"
import "./modules/clipboard"

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
    property string barPosition: "bottom"
    property bool screenshotActive: false
    property int chassisType: 0
    property bool isDesktop: chassisType === 3
    property bool isNotebook: chassisType === 10
    property bool showBatteryModule: isNotebook
    property bool showBrightnessModule: isNotebook

    function updateBarPosition(output) {
        try {
            var config = JSON.parse(String(output || "{}").trim() || "{}");
            barPosition = config.position === "top" ? "top" : "bottom";
        } catch (error) {
            barPosition = "bottom";
        }
    }

    Process {
        id: barPositionProcess
        command: ["sh", "-c", "config=\"$HOME/.config/quickshell/bar.json\"; if [ ! -f \"$config\" ]; then printf '%s\\n' '{\"position\":\"bottom\"}' > \"$config\"; fi; cat \"$config\""]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.updateBarPosition(text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!barPositionProcess.running)
                barPositionProcess.running = true;
        }
    }

    CodexUsage {
        id: codexUsageModule
    }

    CodexUsagePanel {
        usage: codexUsageModule
    }

    Process {
        id: chassisTypeProc
        command: ["sh", "-c", "cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(data.trim())
                if (!isNaN(value))
                    root.chassisType = value
            }
        }
    }

    IpcHandler {
        target: "bar"
        function toggle() { root.barVisible = !root.barVisible }
    }

    IpcHandler {
        target: "panels"
        function beginScreenshot() { root.screenshotActive = true }
        function endScreenshot() { root.screenshotActive = false }
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
            codexUsage: codexUsageModule
        }
    }

    // =========================================================
    // Wallpaper picker (overlay with romboid design)
    // =========================================================
    Wallpaper {}

    // =========================================================
    // Clipboard history overlay
    // =========================================================
    Clipboard {
        id: clipboardWindow
    }
}
