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
    readonly property bool detailsVisible: codexUsage && codexUsage.panelVisible

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

    component SectionSeparator: Rectangle {
        width: visible ? 1 : 0
        height: visible ? 14 : 0
        color: root.colBorder
        opacity: 0.65
    }

    component BarSurface: PanelWindow {
        id: contentRoot
        property bool topAnchored: false
        screen: barRoot.screen

        color: "transparent"
        anchors {
            top: contentRoot.topAnchored
            left: true
            right: true
            bottom: !contentRoot.topAnchored
        }

        implicitHeight: barRail.height + 8

        Rectangle {
            id: barRail
            anchors {
                left: parent.left
                right: parent.right
            top: contentRoot.topAnchored ? parent.top : undefined
            bottom: contentRoot.topAnchored ? undefined : parent.bottom
                leftMargin: 4
                rightMargin: 4
                topMargin: 4
                bottomMargin: 4
            }
            height: 26
            color: "transparent"

            Rectangle {
                id: leftIsland
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: leftSection.implicitWidth + 12
                height: parent.height
                radius: 10
                color: root.colBg
            }

            Rectangle {
                id: rightIsland
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: rightSection.implicitWidth + 12
                height: parent.height
                radius: 10
                color: root.colBg
            }

            PopupWindow {
                id: codexUsagePopup
                anchor.item: codexUsageIndicator
                anchor.edges: Edges.Top | Edges.Left
                anchor.gravity: Edges.Top | Edges.Left
                visible: barRoot.detailsVisible
                grabFocus: true
                color: "transparent"
                implicitWidth: 420
                implicitHeight: codexUsageDetails.implicitHeight + panelConnector.height

                onVisibleChanged: {
                    if (!visible && barRoot.detailsVisible)
                        barRoot.codexUsage.closePanel()
                }

                CodexUsagePanel {
                    id: codexUsageDetails
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    usage: barRoot.codexUsage
                }

                Rectangle {
                    id: panelConnector
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                    }
                    width: Math.max(64, codexUsageIndicator.width + 12)
                    height: 6
                    color: root.colBg
                }
            }

            Row {
                id: leftSection
                anchors {
                    left: leftIsland.left
                    right: leftIsland.right
                    leftMargin: 6
                    verticalCenter: parent.verticalCenter
                }
                spacing: 6
                CodexUsageBar {
                    id: codexUsageIndicator
                    usage: barRoot.codexUsage
                }
                SectionSeparator { visible: codexUsageIndicator.visible }
                Workspace {}
                SectionSeparator {}
                Ram {}
            }

            Row {
                id: rightSection
                anchors {
                    left: rightIsland.left
                    right: rightIsland.right
                    rightMargin: 6
                    verticalCenter: parent.verticalCenter
                }
                spacing: 6
                Brightness {}
                SectionSeparator { visible: root.showBrightnessModule }
                Volume {}
                SectionSeparator { visible: wifiModule.visible }
                Wifi {
                    id: wifiModule
                }
                SectionSeparator {}
                Date {}
                SectionSeparator {}
                Battery {}
                SectionSeparator { visible: root.showBatteryModule }
                Time {}
                SectionSeparator {}
                Wlogout {}
            }
        }
    }

    BarSurface {
        visible: barRoot.barVisible && barRoot.barPosition === "top"
        topAnchored: true
    }

    BarSurface {
        visible: barRoot.barVisible && barRoot.barPosition !== "top"
        topAnchored: false
    }
}
