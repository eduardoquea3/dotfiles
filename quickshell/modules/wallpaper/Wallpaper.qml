import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: wallpaperModule

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string wallpaperPath: homePath + "/.config/hypr/img"
    readonly property string wallpaperStatePath: wallpaperPath + "/.wallpaper"
    property bool wallpaperVisible: false
    property var wallpaperList: []
    property string currentWallpaperPath: ""
    property string selectedWallpaperPath: ""
    property string pendingWallpaperPath: ""
    property string applyError: ""
    property int daemonRetryCount: 0
    readonly property int daemonRetryLimit: 5

    function toggleWallpaper() {
        if (!wallpaperVisible && wallpaperList.length > 0) {
            var currentIndex = indexForPath(currentWallpaperPath);
            selectedWallpaperPath = currentIndex >= 0 ? wallpaperList[currentIndex].path : wallpaperList[0].path;
        }
        wallpaperVisible = !wallpaperVisible;
    }

    function indexForPath(path) {
        if (!path)
            return -1;

        for (var i = 0; i < wallpaperList.length; i++) {
            var entryPath = wallpaperList[i].path;
            var entryName = entryPath.substring(entryPath.lastIndexOf("/") + 1);
            if (entryPath === path || entryName === path)
                return i;

        }
        return -1;
    }

    function selectWallpaperIndex(index) {
        if (index >= 0 && index < wallpaperList.length)
            selectedWallpaperPath = wallpaperList[index].path;

    }

    function syncSelectedWallpaper() {
        var currentIndex = indexForPath(currentWallpaperPath);
        if (currentIndex >= 0)
            selectedWallpaperPath = wallpaperList[currentIndex].path;

    }

    function applyWallpaper(wallpath) {
        if (!wallpath || wallpaperList.length === 0)
            return ;

        pendingWallpaperPath = wallpath;
        selectedWallpaperPath = wallpath;
        applyError = "";
        daemonRetryCount = 0;
        wallpaperVisible = false;
        daemonCheckProc.running = true;
    }

    function loadWallpaperList() {
        wallpaperList = [];
        if (!wallpaperListProc.running)
            wallpaperListProc.running = true;

    }

    Component.onCompleted: {
        wallpaperStateProc.running = true;
        loadWallpaperList();
    }

    Process {
        id: wallpaperListProc

        command: ["find", wallpaperModule.wallpaperPath, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.gif", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")", "!", "-name", ".*"]

        stdout: StdioCollector {
            onStreamFinished: {
                var entries = this.text.split("\n").map(function(path) {
                    return path.trim();
                }).filter(function(path) {
                    return path.length > 0;
                }).sort().map(function(path) {
                    return {
                        "name": path.substring(path.lastIndexOf("/") + 1),
                        "path": path
                    };
                });
                wallpaperModule.wallpaperList = entries;
                var currentIndex = wallpaperModule.indexForPath(wallpaperModule.currentWallpaperPath);
                wallpaperModule.selectedWallpaperPath = currentIndex >= 0 ? entries[currentIndex].path : (entries.length > 0 ? entries[0].path : "");
            }
        }

    }

    Process {
        id: wallpaperStateProc

        command: ["cat", wallpaperModule.wallpaperStatePath]

        stdout: StdioCollector {
            onStreamFinished: {
                wallpaperModule.currentWallpaperPath = this.text.trim();
                wallpaperModule.syncSelectedWallpaper();
            }
        }

    }

    Process {
        id: daemonCheckProc

        command: ["pgrep", "-x", "awww-daemon"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                daemonWaitTimer.stop();
                applyWallProc.running = true;
            } else if (wallpaperModule.daemonRetryCount < wallpaperModule.daemonRetryLimit) {
                if (wallpaperModule.daemonRetryCount === 0)
                    Quickshell.execDetached(["awww-daemon"]);

                wallpaperModule.daemonRetryCount++;
                daemonWaitTimer.start();
            } else {
                wallpaperModule.applyError = "Wallpaper daemon did not become ready.";
                wallpaperModule.wallpaperVisible = true;
            }
        }
    }

    Timer {
        id: daemonWaitTimer

        interval: 250
        repeat: false
        onTriggered: daemonCheckProc.running = true
    }

    Process {
        id: applyWallProc

        command: ["awww", "img", wallpaperModule.pendingWallpaperPath, "--transition-type", "any", "--transition-fps", "60"]
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                if (wallpaperModule.daemonRetryCount < wallpaperModule.daemonRetryLimit) {
                    wallpaperModule.daemonRetryCount++;
                    daemonWaitTimer.start();
                } else {
                    wallpaperModule.applyError = "Wallpaper could not be applied.";
                    wallpaperModule.wallpaperVisible = true;
                }
                return ;
            }

            wallpaperModule.currentWallpaperPath = wallpaperModule.pendingWallpaperPath;
            saveWallpaperProc.command = ["bash", "-c", "printf '%s\\n' \"$1\" > \"$2\"", "_", wallpaperModule.pendingWallpaperPath, wallpaperModule.wallpaperStatePath];
            saveWallpaperProc.running = true;
        }
    }

    Process {
        id: saveWallpaperProc
    }

    IpcHandler {
        function toggle() {
            wallpaperModule.toggleWallpaper();
        }

        target: "wallpaper"
    }

    Variants {
        model: Quickshell.screens

        delegate: WallpaperPanel {
            required property var modelData

            screen: modelData
        }

    }

}
