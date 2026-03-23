import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import "modules/bar"
import "./widgets"

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
    // Launcher state
    // =========================================================
    property string homePath: Quickshell.env("HOME")
    property string configPath: homePath + "/.config/quickshell"
    property string wallpaperPath: homePath + "/.config/hypr/img"
    property string cachePath: homePath + "/.cache"

    property bool barVisible: true
    property bool launcherVisible: false
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

    // =========================================================
    // Functions
    // =========================================================
    function toggleLauncher() { launcherVisible = !launcherVisible }

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
            "swww img '" + wallpaper.path + "' --transition-type any --transition-fps 60" +
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

    // =========================================================
    // Processes
    // =========================================================
    Component.onCompleted: {
        appListProc.running = true
        loadUsageProc.running = true
        currentWallProc.running = true
        thumbDirProc.running = true
    }

    Process {
        id: thumbDirProc
        command: ["mkdir", "-p", root.cachePath + "/wallpaper-thumbs"]
        onExited: root.loadWallpapers()
    }

    Process {
        id: appListProc
        command: ["bash", "-c",
            "for f in /usr/share/applications/*.desktop '" + root.homePath + "/.local/share/applications'/*.desktop; do " +
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
                var current = root.appList.slice()
                current.push({ name: parts[0], exec: parts[1], icon: parts.length > 2 ? parts[2] : "" })
                root.appList = current
            }
        }
    }

    Process { id: launchProc }
    Process { id: saveUsageProc }
    Process { id: applyWallProc }

    Process {
        id: loadUsageProc
        command: ["bash", "-c", "cat '" + root.configPath + "/app_usage.json' 2>/dev/null || echo '{}'"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try { root.appUsage = JSON.parse(data.trim()) } catch(e) { root.appUsage = {} }
            }
        }
    }

    Process {
        id: currentWallProc
        command: ["bash", "-c", "ls -t '" + root.wallpaperPath + "'/*.{jpg,jpeg,png,webp,gif} 2>/dev/null | head -1 || echo ''"]
        stdout: SplitParser { onRead: data => { if (data.trim()) root.currentWallpaper = data.trim() } }
    }

    Process {
        id: wallpaperListProc
        command: ["bash", "-c", "find '" + root.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | sort"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length === 0) return
                var parts = path.split("/")
                var name = parts[parts.length - 1]
                var current = root.wallpaperList.slice()
                current.push({ name: name, path: path })
                root.wallpaperList = current
            }
        }
        onExited: {
            root.wallsLoaded = true
            if (!thumbGenProc.running) thumbGenProc.running = true
        }
    }

    Process {
        id: thumbGenProc
        command: ["bash", "-c",
            "THUMB_DIR='" + root.cachePath + "/wallpaper-thumbs' && " +
            "WALL_DIR='" + root.wallpaperPath + "' && " +
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
            root.thumbsReady = true
            if (!hashAllProc.running) hashAllProc.running = true
        }
    }

    Process {
        id: hashAllProc
        command: ["bash", "-c",
            "find '" + root.wallpaperPath + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' 2>/dev/null | " +
            "while IFS= read -r f; do echo \"$f|$(echo -n \"$f\" | md5sum | cut -d' ' -f1)\"; done"
        ]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|")
                if (parts.length === 2 && parts[0] && parts[1]) {
                    var updated = root.wallpaperHashes
                    updated[parts[0]] = parts[1]
                    root.wallpaperHashes = updated
                    root.wallpaperHashesChanged()
                }
            }
        }
    }

    // =========================================================
    // IPC
    // =========================================================
    IpcHandler {
        target: "bar"
        function toggle() { root.barVisible = !root.barVisible }
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            root.activeTab = 0
            root.toggleLauncher()
        }
    }

    // =========================================================
    // Bar
    // =========================================================
    PanelWindow {
        visible: root.barVisible
        color: "transparent"
        anchors {
            top: false
            left: true
            right: true
            bottom: true
        }
        implicitHeight: 26

        Row {
            anchors {
                left: parent.left
                leftMargin: 4
            }
            spacing: 6
            Workspace {}
            Ram {}
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: 4
            }
            spacing: 6
            Brightness {}
            Volume {}
            Wifi {}
            Date {}
            Battery {}
            Time {}
            Wlogout {}
        }
    }

    // =========================================================
    // Launcher panel
    // =========================================================
    Launcher {}
}
