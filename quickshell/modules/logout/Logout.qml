import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: logoutModule

    readonly property string homePath: Quickshell.env("HOME")
    property bool logoutVisible: false

    function toggleLogout() {
        logoutVisible = !logoutVisible
    }

    function logout() {
        logoutProc.command = ["bash", "-c", "loginctl terminate-user $USER"]
        logoutProc.running = true
        logoutVisible = false
    }

    function shutdown() {
        logoutProc.command = ["systemctl", "poweroff"]
        logoutProc.running = true
        logoutVisible = false
    }

    function restart() {
        logoutProc.command = ["systemctl", "reboot"]
        logoutProc.running = true
        logoutVisible = false
    }

    function suspend() {
        logoutProc.command = ["systemctl", "suspend"]
        logoutProc.running = true
        logoutVisible = false
    }

    function lock() {
        logoutProc.command = ["bash", "-c", homePath + "/.config/hypr/scripts/lockscreen"]
        logoutProc.running = true
        logoutVisible = false
    }

    Process {
        id: logoutProc
    }

    IpcHandler {
        target: "logout"
        function toggle() {
            logoutModule.toggleLogout()
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: LogoutPanel {
            required property var modelData
            screen: modelData
        }
    }
}
