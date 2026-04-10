import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: wallpaperModule

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string wallpaperPath: homePath + "/.config/hypr/img"

    property bool wallpaperVisible: false
    property var wallpaperList: []
    property int selectedWallIndex: 0

    function toggleWallpaper() {
        wallpaperVisible = !wallpaperVisible
    }

    function applyWallpaper(wallpath) {
        applyWallProc.command = ["bash", "-c",
            "if ! pgrep -x 'awww-daemon' >/dev/null; then awww-daemon & sleep 1; fi && " +
            "awww img '" + wallpath + "' --transition-type any --transition-fps 60 && " +
            "mkdir -p '" + homePath + "/.config/hypr/img' && " +
            "echo '" + wallpath + "' > '" + homePath + "/.config/hypr/img/.wallpaper'"
        ]
        applyWallProc.running = true
        wallpaperVisible = false
    }

    Component.onCompleted: {
        loadWallpaperList()
    }

    function loadWallpaperList() {
        wallpaperListProc.running = true
    }

    Process {
        id: wallpaperListProc
        command: ["bash", "-c", "find '" + wallpaperModule.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | sort"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length === 0) return
                var parts = path.split("/")
                var name = parts[parts.length - 1]
                var current = wallpaperModule.wallpaperList.slice()
                current.push({ name: name, path: path })
                wallpaperModule.wallpaperList = current
            }
        }
    }

    Process { id: applyWallProc }

    IpcHandler {
        target: "wallpaper"
        function toggle() {
            wallpaperModule.toggleWallpaper()
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: WallpaperPanel {
            required property var modelData
            screen: modelData
        }
    }
}
