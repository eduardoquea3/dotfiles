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

    function ensureBarConfig() {
        if (!barConfigInitProc.running)
            barConfigInitProc.running = true;
    }

    Process {
        id: barConfigInitProc
        command: [
            "bash",
            "-c",
            "if [ ! -f '" + barRoot.configPath + "' ]; then printf '%s\\n' '{\"position\":\"bottom\"}' > '" + barRoot.configPath + "'; fi"
        ]
        running: false
        onExited: barRoot.reloadBarConfig()
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

    Component.onCompleted: ensureBarConfig()

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
                property bool panelRequested: contentRoot.visible && barRoot.detailsVisible
                property bool keepVisible: false

                anchor.item: codexUsageIndicator
                anchor.edges: contentRoot.topAnchored
                    ? Edges.Bottom | Edges.Left
                    : Edges.Top | Edges.Left
                anchor.gravity: contentRoot.topAnchored
                    ? Edges.Bottom | Edges.Left
                    : Edges.Top | Edges.Left
                visible: keepVisible && contentRoot.visible
                grabFocus: true
                color: "transparent"
                implicitWidth: 420
                implicitHeight: codexUsageDetails.implicitHeight + 8

                onPanelRequestedChanged: {
                    if (panelRequested) {
                        keepVisible = true
                        hideAnimation.stop()
                        showAnimation.restart()
                    } else if (keepVisible) {
                        showAnimation.stop()
                        hideAnimation.restart()
                    }
                }

                Component.onCompleted: {
                    if (panelRequested) {
                        keepVisible = true
                        showAnimation.start()
                    }
                }

                onVisibleChanged: {
                    if (!visible && contentRoot.visible && barRoot.detailsVisible)
                        barRoot.codexUsage.closePanel()
                }

                ParallelAnimation {
                    id: showAnimation
                    NumberAnimation {
                        target: codexUsageDetails
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: codexUsageDetails
                        property: "scale"
                        from: 0.94
                        to: 1
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                ParallelAnimation {
                    id: hideAnimation
                    NumberAnimation {
                        target: codexUsageDetails
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 140
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: codexUsageDetails
                        property: "scale"
                        from: 1
                        to: 0.96
                        duration: 140
                        easing.type: Easing.InCubic
                    }
                    onFinished: {
                        if (!codexUsagePopup.panelRequested)
                            codexUsagePopup.keepVisible = false
                    }
                }

                CodexUsagePanel {
                    id: codexUsageDetails
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: contentRoot.topAnchored ? parent.top : undefined
                        bottom: contentRoot.topAnchored ? undefined : parent.bottom
                        topMargin: contentRoot.topAnchored ? 8 : 0
                        bottomMargin: contentRoot.topAnchored ? 0 : 8
                    }
                    usage: barRoot.codexUsage
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
                SectionSeparator { visible: wifiModule.visible || bluetoothModule.visible }
                Wifi {
                    id: wifiModule
                }
                SectionSeparator { visible: wifiModule.visible && bluetoothModule.visible }
                Bluetooth {
                    id: bluetoothModule
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
