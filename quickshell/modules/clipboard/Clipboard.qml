import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: clipboardModule

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string configPath: homePath + "/.config/quickshell"

    property bool clipboardVisible: false
    property string activeClipboardScreen: ""
    property string searchTerm: ""
    property var clipboardHistory: []
    property var filteredClips: {
        var source = clipboardHistory
        if (searchTerm !== "") {
            var result = []
            for (var i = 0; i < source.length; i++) {
                var entry = source[i]
                if (entry.text.toLowerCase().includes(searchTerm.toLowerCase()))
                    result.push(entry)
            }
            source = result
        }
        return source
    }
    property int selectedIndex: 0

    function toggleClipboard() {
        clipboardVisible = !clipboardVisible
        if (clipboardVisible && Hyprland.focusedMonitor)
            activeClipboardScreen = Hyprland.focusedMonitor.name
    }

    function copyToClipboard(text) {
        copyProc.command = ["bash", "-c", "echo -n '" + text.replace(/'/g, "'\\''") + "' | wl-copy"]
        copyProc.running = true
        clipboardVisible = false
    }

    function refreshClipboard() {
        clipboardHistory = []
        if (!clipHistProc.running) clipHistProc.running = true
    }

    Component.onCompleted: {
        clipHistProc.running = true
    }

    // ─── Processes ───────────────────────────────────────────────────────────

    Process {
        id: clipHistProc
        command: ["bash", "-c", "cliphist list 2>/dev/null | cut -f2- | head -50"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                // Truncate very long lines for display
                var displayText = line.length > 100 ? line.substring(0, 100) + "..." : line
                var current = clipboardModule.clipboardHistory.slice()
                current.push({ text: line, display: displayText })
                clipboardModule.clipboardHistory = current
            }
        }
    }

    Process { id: copyProc }

    // ─── IPC ─────────────────────────────────────────────────────────────────

    IpcHandler {
        target: "clipboard"
        function toggle() {
            clipboardModule.toggleClipboard()
        }
    }

    // ─── Panel per screen ────────────────────────────────────────────────────

    Variants {
        model: Quickshell.screens
        delegate: ClipboardPanel {
            required property var modelData
            screen: modelData
        }
    }
}
