import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import "../modules/bar"

Item {
    id: barRoot
    visible: barVisible

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string configPath: homePath + "/.config/quickshell/bar.json"
    property bool barVisible: true
    property var screen: null
    property var codexUsage: null
    property string barPosition: "bottom"

    function loadBarConfig(output) {
        try {
            var data = JSON.parse(String(output || "{}").trim() || "{}");
            barPosition = data.position === "top" ? "top" : "bottom";
        } catch (error) {
            barPosition = "bottom";
        }
    }

    function reloadBarConfig() {
        if (barConfigProc.running)
            barConfigProc.running = false;
        barConfigProc.running = true;
    }

    Process {
        id: barConfigProc
        command: ["bash", "-c", "cat '" + barRoot.configPath + "' 2>/dev/null || echo '{\"position\":\"bottom\"}'"]
        running: false

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => barRoot.loadBarConfig(data)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: barRoot.reloadBarConfig()
    }

    Component.onCompleted: reloadBarConfig()

    PanelWindow {
        id: barSurface
        screen: barRoot.screen
        visible: barRoot.barVisible
        color: "transparent"
        anchors {
            top: barRoot.barPosition === "top"
            left: true
            right: true
            bottom: barRoot.barPosition !== "top"
        }

        implicitHeight: barCapsule.height + 8

        Rectangle {
            id: barCapsule
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: barRoot.barPosition === "top" ? parent.top : undefined
                bottom: barRoot.barPosition === "top" ? undefined : parent.bottom
                topMargin: 4
                bottomMargin: 4
            }
            implicitWidth: moduleRow.implicitWidth + 24
            width: implicitWidth
            height: 26
            radius: height / 2
            color: root.colBg
            border.color: root.colBorder

            Row {
                id: moduleRow
                anchors.centerIn: parent
                spacing: 6

                Battery {}
                Volume {}
                Workspace {}
                Wifi {}
                Time {}
                Ram {}
            }
        }
    }
}
