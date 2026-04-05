import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: keybindsModule

    readonly property string homePath: Quickshell.env("HOME")
    property bool keybindsVisible: false
    property var keybindsList: []
    property string searchTerm: ""
    property var filteredKeybinds: {
        var result = []
        var search = searchTerm.toLowerCase()

        for (var i = 0; i < keybindsList.length; i++) {
            var item = keybindsList[i]
            if (!search ||
                item.keys.toLowerCase().includes(search) ||
                item.description.toLowerCase().includes(search) ||
                item.group.toLowerCase().includes(search)) {
                result.push(item)
            }
        }
        return result
    }
    property int filteredCount: filteredKeybinds.length

    function toggleKeybinds() {
        keybindsVisible = !keybindsVisible
        if (keybindsVisible && keybindsList.length === 0) {
            loadKeybinds()
        }
    }

    function loadKeybinds() {
        keybindsList = []
        keybindsProc.running = true
    }

    Component.onCompleted: {
        loadKeybinds()
    }

    Process {
        id: keybindsProc
        command: ["bash", "-c",
            homePath + "/.config/hypr/scripts/hint-hyprland.py 2>/dev/null | jq -r '.[] | \"\\(.header1):::\\(.displayed_keys):::\\(.description)\"'"
        ]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (!line || !line.includes(":::")) return

                var parts = line.split(":::")
                if (parts.length < 3) return

                var current = keybindsModule.keybindsList.slice()
                current.push({
                    group: parts[0].trim() || "Other",
                    keys: parts[1].trim(),
                    description: parts[2].trim()
                })
                keybindsModule.keybindsList = current
            }
        }
    }

    IpcHandler {
        target: "keybinds"
        function toggle() {
            keybindsModule.toggleKeybinds()
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: KeybindsPanel {
            required property var modelData
            screen: modelData
        }
    }
}
