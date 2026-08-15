import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Item {
    // ─── Processes ───────────────────────────────────────────────────────────
    // ─── IPC ─────────────────────────────────────────────────────────────────
    // ─── Panel per screen ────────────────────────────────────────────────────

    id: launcherModule

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string wallpaperPath: homePath + "/.config/hypr/img"
    readonly property string cachePath: homePath + "/.cache"
    property bool launcherVisible: false
    property string activeLauncherScreen: ""
    property bool barVisible: root.barVisible
    property string barPosition: root.barPosition
    property string searchTerm: ""
    property var appList: []
    property var filteredApps: {
        var source = appList;
        if (searchTerm !== "") {
            var result = [];
            for (var i = 0; i < source.length; i++) {
                var entry = source[i];
                if (entry.name.toLowerCase().includes(searchTerm) || entry.comment.toLowerCase().includes(searchTerm))
                    result.push(entry);

            }
            source = result;
        }
        return source;
    }
    property int selectedIndex: 0
    property int activeTab: 0
    property string wallSearchTerm: ""
    property var wallpaperList: []
    property var filteredWallpapers: {
        if (wallSearchTerm === "")
            return wallpaperList;

        var result = [];
        for (var i = 0; i < wallpaperList.length; i++) {
            if (wallpaperList[i].name.toLowerCase().includes(wallSearchTerm))
                result.push(wallpaperList[i]);

        }
        return result;
    }
    property int wallSelectedIndex: 0
    property string currentWallpaper: ""
    property bool wallsLoaded: false
    property bool thumbsReady: false
    property var wallpaperHashes: ({
    })

    function toggleLauncher() {
        launcherVisible = !launcherVisible;
        if (launcherVisible && Hyprland.focusedMonitor)
            activeLauncherScreen = Hyprland.focusedMonitor.name;

    }

    function refreshLauncher() {
        loadApps();
        if (!currentWallProc.running)
            currentWallProc.running = true;

    }

    function loadApps() {
        var entries = DesktopEntries.applications.values;
        var apps = [];
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            apps.push({
                "name": entry.name,
                "comment": entry.comment || "",
                "icon": entry.icon,
                "entry": entry
            });
        }
        apps.sort(function(a, b) {
            return a.name.localeCompare(b.name);
        });
        appList = apps;
    }

    function launchApp(app) {
        if (app && app.entry)
            app.entry.execute();

        launcherVisible = false;
    }

    function applyWallpaper(wallpaper) {
        currentWallpaper = wallpaper.path;
        applyWallProc.command = ["bash", "-c", "awww img '" + wallpaper.path + "' --transition-type any --transition-fps 60" + "; mkdir -p '" + homePath + "/.config/hypr/img'" + " && echo '" + wallpaper.path + "' > '" + homePath + "/.config/hypr/img/.wallpaper'"];
        applyWallProc.running = true;
    }

    function loadWallpapers() {
        wallpaperList = [];
        wallsLoaded = false;
        thumbsReady = false;
        if (!wallpaperListProc.running)
            wallpaperListProc.running = true;

    }

    Component.onCompleted: {
        loadApps();
        currentWallProc.running = true;
        thumbDirProc.running = true;
    }

    Process {
        id: thumbDirProc

        command: ["mkdir", "-p", launcherModule.cachePath + "/wallpaper-thumbs"]
        onExited: launcherModule.loadWallpapers()
    }

    Process {
        id: applyWallProc
    }

    Process {
        id: currentWallProc

        command: ["bash", "-c", "ls -t '" + launcherModule.wallpaperPath + "'/*.{jpg,jpeg,png,webp,gif} 2>/dev/null | head -1 || echo ''"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim())
                    launcherModule.currentWallpaper = data.trim();

            }
        }

    }

    Process {
        id: wallpaperListProc

        command: ["bash", "-c", "find '" + launcherModule.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | sort"]
        onExited: {
            launcherModule.wallsLoaded = true;
            if (!thumbGenProc.running)
                thumbGenProc.running = true;

        }

        stdout: SplitParser {
            onRead: (data) => {
                var path = data.trim();
                if (path.length === 0)
                    return ;

                var parts = path.split("/");
                var name = parts[parts.length - 1];
                var current = launcherModule.wallpaperList.slice();
                current.push({
                    "name": name,
                    "path": path
                });
                launcherModule.wallpaperList = current;
            }
        }

    }

    Process {
        id: thumbGenProc

        command: ["bash", "-c", "THUMB_DIR='" + launcherModule.cachePath + "/wallpaper-thumbs' && " + "WALL_DIR='" + launcherModule.wallpaperPath + "' && " + "find \"$WALL_DIR\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | " + "while IFS= read -r f; do " + "  hash=$(echo -n \"$f\" | md5sum | cut -d' ' -f1); " + "  thumb=\"$THUMB_DIR/${hash}.jpg\"; " + "  if [ ! -f \"$thumb\" ] || [ \"$f\" -nt \"$thumb\" ]; then " + "    case \"$f\" in " + "      *.gif) convert \"${f}[0]\" -thumbnail 180x120^ -gravity center -extent 180x120 -quality 85 \"$thumb\" 2>/dev/null ;; " + "      *) convert \"$f\" -thumbnail 180x120^ -gravity center -extent 180x120 -quality 85 \"$thumb\" 2>/dev/null ;; " + "    esac; " + "  fi; " + "done"]
        onExited: {
            launcherModule.thumbsReady = true;
            if (!hashAllProc.running)
                hashAllProc.running = true;

        }
    }

    Process {
        id: hashAllProc

        command: ["bash", "-c", "find '" + launcherModule.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | " + "while IFS= read -r f; do echo \"$f|$(echo -n \"$f\" | md5sum | cut -d' ' -f1)\"; done"]

        stdout: SplitParser {
            onRead: (data) => {
                var parts = data.trim().split("|");
                if (parts.length === 2 && parts[0] && parts[1]) {
                    var updated = launcherModule.wallpaperHashes;
                    updated[parts[0]] = parts[1];
                    launcherModule.wallpaperHashes = updated;
                    launcherModule.wallpaperHashesChanged();
                }
            }
        }

    }

    IpcHandler {
        function toggle() {
            launcherModule.activeTab = 0;
            launcherModule.toggleLauncher();
        }

        target: "launcher"
    }

    Variants {
        model: Quickshell.screens

        delegate: Item {
            required property var modelData
            property bool activeOnScreen: launcherModule.launcherVisible && launcherModule.activeLauncherScreen === modelData.name

            PanelWindow {
                id: fallbackSurface

                screen: modelData
                visible: activeOnScreen && !launcherPanel.usingBarAnchor
                color: "transparent"
                implicitWidth: modelData.width
                implicitHeight: modelData.height
                exclusiveZone: -1
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "launcher_anchor"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.focusable: false

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

            }

            LauncherPanel {
                id: launcherPanel

                targetScreen: modelData
                fallbackWindow: fallbackSurface
                barVisible: launcherModule.barVisible
                barPosition: launcherModule.barPosition
            }

        }

    }

}
