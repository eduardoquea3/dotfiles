import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: launcherModule

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string configPath: homePath + "/.config/quickshell"
    readonly property string wallpaperPath: homePath + "/.config/hypr/img"
    readonly property string cachePath: homePath + "/.cache"

    property bool launcherVisible: false
    property string activeLauncherScreen: ""
    property string searchTerm: ""
    property var appList: []
    property var appUsage: ({})
    property var filteredApps: {
        var source = appList
        var usage = appUsage
        if (searchTerm !== "") {
            var result = []
            for (var i = 0; i < source.length; i++) {
                var entry = source[i]
                if (entry.name.toLowerCase().includes(searchTerm) || entry.exec.toLowerCase().includes(searchTerm))
                    result.push(entry)
            }
            source = result
        }
        return source.slice().sort(function(a, b) {
            var cA = usage[a.name] || 0
            var cB = usage[b.name] || 0
            if (cB !== cA) return cB - cA
            return a.name.localeCompare(b.name)
        })
    }
    property int selectedIndex: 0
    property int activeTab: 0

    property string wallSearchTerm: ""
    property var wallpaperList: []
    property var filteredWallpapers: {
        if (wallSearchTerm === "") return wallpaperList
        var result = []
        for (var i = 0; i < wallpaperList.length; i++) {
            if (wallpaperList[i].name.toLowerCase().includes(wallSearchTerm))
                result.push(wallpaperList[i])
        }
        return result
    }
    property int wallSelectedIndex: 0
    property string currentWallpaper: ""
    property bool wallsLoaded: false
    property bool thumbsReady: false
    property var wallpaperHashes: ({})

    function toggleLauncher() {
        launcherVisible = !launcherVisible
        if (launcherVisible && Hyprland.focusedMonitor)
            activeLauncherScreen = Hyprland.focusedMonitor.name
    }

    function refreshLauncher() {
        if (!loadUsageProc.running) loadUsageProc.running = true
        if (!currentWallProc.running) currentWallProc.running = true
    }

    function launchApp(app) {
        launchProc.command = ["bash", "-c", app.exec + " &"]
        launchProc.running = true
        var usage = appUsage
        var updated = {}
        for (var key in usage) updated[key] = usage[key]
        updated[app.name] = (updated[app.name] || 0) + 1
        appUsage = updated
        saveUsageProc.command = ["bash", "-c", "echo '" + JSON.stringify(updated) + "' > '" + configPath + "/app_usage.json'"]
        saveUsageProc.running = true
        launcherVisible = false
    }

    function applyWallpaper(wallpaper) {
        currentWallpaper = wallpaper.path
        applyWallProc.command = ["bash", "-c",
            "awww img '" + wallpaper.path + "' --transition-type any --transition-fps 60" +
            "; mkdir -p '" + homePath + "/.config/hypr/img'" +
            " && echo '" + wallpaper.path + "' > '" + homePath + "/.config/hypr/img/.wallpaper'"
        ]
        applyWallProc.running = true
    }

    function loadWallpapers() {
        wallpaperList = []
        wallsLoaded = false
        thumbsReady = false
        if (!wallpaperListProc.running) wallpaperListProc.running = true
    }

    Component.onCompleted: {
        appListProc.running = true
        loadUsageProc.running = true
        currentWallProc.running = true
        thumbDirProc.running = true
    }

    // ─── Processes ───────────────────────────────────────────────────────────

    Process {
        id: thumbDirProc
        command: ["mkdir", "-p", launcherModule.cachePath + "/wallpaper-thumbs"]
        onExited: launcherModule.loadWallpapers()
    }

    Process {
        id: appListProc
        command: ["bash", "-c",
            "for f in /usr/share/applications/*.desktop '" + launcherModule.homePath + "/.local/share/applications'/*.desktop; do " +
            "  [ -f \"$f\" ] || continue; " +
            "  grep -qi '^NoDisplay=true' \"$f\" && continue; " +
            "  grep -qi '^Hidden=true' \"$f\" && continue; " +
            "  name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); " +
            "  exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed 's/ %[fFuUdDnNickvm]//g'); " +
            "  icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); " +
            "  [ -z \"$name\" ] && continue; " +
            "  [ -z \"$exec\" ] && continue; " +
            "  printf '%s\\t%s\\t%s\\n' \"$name\" \"$exec\" \"$icon\"; " +
            "done | sort -f -t$'\\t' -k1,1 | awk -F'\\t' '!seen[$1]++'"
        ]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split("\t")
                if (parts.length < 2) return
                var current = launcherModule.appList.slice()
                current.push({ name: parts[0], exec: parts[1], icon: parts.length > 2 ? parts[2] : "" })
                launcherModule.appList = current
            }
        }
    }

    Process { id: launchProc }
    Process { id: saveUsageProc }
    Process { id: applyWallProc }

    Process {
        id: loadUsageProc
        command: ["bash", "-c", "cat '" + launcherModule.configPath + "/app_usage.json' 2>/dev/null || echo '{}'"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try { launcherModule.appUsage = JSON.parse(data.trim()) } catch(e) { launcherModule.appUsage = {} }
            }
        }
    }

    Process {
        id: currentWallProc
        command: ["bash", "-c", "ls -t '" + launcherModule.wallpaperPath + "'/*.{jpg,jpeg,png,webp,gif} 2>/dev/null | head -1 || echo ''"]
        stdout: SplitParser { onRead: data => { if (data.trim()) launcherModule.currentWallpaper = data.trim() } }
    }

    Process {
        id: wallpaperListProc
        command: ["bash", "-c", "find '" + launcherModule.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | sort"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length === 0) return
                var parts = path.split("/")
                var name = parts[parts.length - 1]
                var current = launcherModule.wallpaperList.slice()
                current.push({ name: name, path: path })
                launcherModule.wallpaperList = current
            }
        }
        onExited: {
            launcherModule.wallsLoaded = true
            if (!thumbGenProc.running) thumbGenProc.running = true
        }
    }

    Process {
        id: thumbGenProc
        command: ["bash", "-c",
            "THUMB_DIR='" + launcherModule.cachePath + "/wallpaper-thumbs' && " +
            "WALL_DIR='" + launcherModule.wallpaperPath + "' && " +
            "find \"$WALL_DIR\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | " +
            "while IFS= read -r f; do " +
            "  hash=$(echo -n \"$f\" | md5sum | cut -d' ' -f1); " +
            "  thumb=\"$THUMB_DIR/${hash}.jpg\"; " +
            "  if [ ! -f \"$thumb\" ] || [ \"$f\" -nt \"$thumb\" ]; then " +
            "    case \"$f\" in " +
            "      *.gif) convert \"${f}[0]\" -thumbnail 180x120^ -gravity center -extent 180x120 -quality 85 \"$thumb\" 2>/dev/null ;; " +
            "      *) convert \"$f\" -thumbnail 180x120^ -gravity center -extent 180x120 -quality 85 \"$thumb\" 2>/dev/null ;; " +
            "    esac; " +
            "  fi; " +
            "done"
        ]
        onExited: {
            launcherModule.thumbsReady = true
            if (!hashAllProc.running) hashAllProc.running = true
        }
    }

    Process {
        id: hashAllProc
        command: ["bash", "-c",
            "find '" + launcherModule.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | " +
            "while IFS= read -r f; do echo \"$f|$(echo -n \"$f\" | md5sum | cut -d' ' -f1)\"; done"
        ]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|")
                if (parts.length === 2 && parts[0] && parts[1]) {
                    var updated = launcherModule.wallpaperHashes
                    updated[parts[0]] = parts[1]
                    launcherModule.wallpaperHashes = updated
                    launcherModule.wallpaperHashesChanged()
                }
            }
        }
    }

    // ─── IPC ─────────────────────────────────────────────────────────────────

    IpcHandler {
        target: "launcher"
        function toggle() {
            launcherModule.activeTab = 0
            launcherModule.toggleLauncher()
        }
    }

    // ─── Panel per screen ────────────────────────────────────────────────────

    Variants {
        model: Quickshell.screens
        delegate: LauncherPanel {
            required property var modelData
            screen: modelData
        }
    }
}
