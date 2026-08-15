import "../modules/bar"
import "../modules/connectivity"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: barRoot

    readonly property string homePath: Quickshell.env("HOME")
    readonly property string configPath: homePath + "/.config/quickshell/bar.json"
    property bool barVisible: true
    property var screen: null
    property var codexUsage: null
    property string barPosition: "bottom"
    property string connectionPanelType: ""
    readonly property bool detailsVisible: codexUsage && codexUsage.panelVisible

    function toggleConnectionPanel(type) {
        connectionPanelType = connectionPanelType === type ? "" : type;
    }

    function closeConnectionPanel() {
        connectionPanelType = "";
    }

    function loadBarConfig(output) {
        var nextPosition = "bottom";
        try {
            var data = JSON.parse(String(output || "{}").trim() || "{}");
            nextPosition = data.position === "top" ? "top" : "bottom";
        } catch (error) {
            nextPosition = "bottom";
        }
        barPosition = nextPosition;
        root.barPosition = nextPosition;
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

    visible: barVisible
    Component.onCompleted: ensureBarConfig()

    Process {
        id: barConfigInitProc

        command: ["bash", "-c", "if [ ! -f '" + barRoot.configPath + "' ]; then printf '%s\\n' '{\"position\":\"bottom\"}' > '" + barRoot.configPath + "'; fi"]
        running: false
        onExited: barRoot.reloadBarConfig()
    }

    Process {
        id: barConfigProc

        command: ["bash", "-c", "cat '" + barRoot.configPath + "' 2>/dev/null || echo '{\"position\":\"bottom\"}'"]
        running: false

        stdout: SplitParser {
            splitMarker: ""
            onRead: (data) => {
                return barRoot.loadBarConfig(data);
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: barRoot.reloadBarConfig()
    }

    BarSurface {
        visible: barRoot.barVisible && barRoot.barPosition === "top"
        topAnchored: true
    }

    BarSurface {
        visible: barRoot.barVisible && barRoot.barPosition !== "top"
        topAnchored: false
    }

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
        implicitHeight: barRail.height + 8

        anchors {
            top: contentRoot.topAnchored
            left: true
            right: true
            bottom: !contentRoot.topAnchored
        }

        Rectangle {
            id: barRail

            height: 26
            color: "transparent"

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

            Rectangle {
                id: leftIsland

                width: leftSection.implicitWidth + 12
                height: parent.height
                radius: 10
                color: root.colBg

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

            }

            Rectangle {
                id: rightIsland

                width: rightSection.implicitWidth + 12
                height: parent.height
                radius: 10
                color: root.colBg

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

            }

            PopupWindow {
                id: codexUsagePopup

                property bool panelRequested: contentRoot.visible && barRoot.detailsVisible
                property bool keepVisible: false

                anchor.item: codexUsageIndicator
                anchor.edges: contentRoot.topAnchored ? Edges.Bottom | Edges.Left : Edges.Top | Edges.Left
                anchor.gravity: contentRoot.topAnchored ? Edges.Bottom | Edges.Left : Edges.Top | Edges.Left
                visible: keepVisible && contentRoot.visible
                grabFocus: true
                color: "transparent"
                implicitWidth: 420
                implicitHeight: codexUsageDetails.implicitHeight + 8
                onPanelRequestedChanged: {
                    if (panelRequested) {
                        keepVisible = true;
                        connectionHideAnimation.stop();
                        connectionShowAnimation.restart();
                    } else if (keepVisible) {
                        connectionShowAnimation.stop();
                        connectionHideAnimation.restart();
                    }
                }
                Component.onCompleted: {
                    if (panelRequested) {
                        keepVisible = true;
                        connectionShowAnimation.start();
                    }
                }
                onVisibleChanged: {
                    if (!visible && contentRoot.visible && barRoot.detailsVisible)
                        barRoot.codexUsage.closePanel();

                }

                ParallelAnimation {
                    id: connectionShowAnimation

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
                    id: connectionHideAnimation

                    onFinished: {
                        if (!codexUsagePopup.panelRequested)
                            codexUsagePopup.keepVisible = false;

                    }

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

                }

                CodexUsagePanel {
                    id: codexUsageDetails

                    usage: barRoot.codexUsage

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: contentRoot.topAnchored ? parent.top : undefined
                        bottom: contentRoot.topAnchored ? undefined : parent.bottom
                        topMargin: contentRoot.topAnchored ? 8 : 0
                        bottomMargin: contentRoot.topAnchored ? 0 : 8
                    }

                }

            }

            PopupWindow {
                id: connectionPopup

                property bool panelRequested: contentRoot.visible && barRoot.connectionPanelType !== ""
                property bool keepVisible: false

                anchor.item: barRoot.connectionPanelType === "bluetooth" ? bluetoothModule : wifiModule
                anchor.edges: contentRoot.topAnchored ? Edges.Bottom | Edges.Right : Edges.Top | Edges.Right
                anchor.gravity: contentRoot.topAnchored ? Edges.Bottom | Edges.Right : Edges.Top | Edges.Right
                visible: keepVisible && contentRoot.visible
                grabFocus: true
                color: "transparent"
                implicitWidth: connectionPanel.implicitWidth
                implicitHeight: connectionPanel.implicitHeight + 8
                onPanelRequestedChanged: {
                    if (panelRequested) {
                        keepVisible = true;
                        hideAnimation.stop();
                        showAnimation.restart();
                    } else if (keepVisible) {
                        showAnimation.stop();
                        hideAnimation.restart();
                    }
                }
                Component.onCompleted: {
                    if (panelRequested) {
                        keepVisible = true;
                        showAnimation.start();
                    }
                }
                onVisibleChanged: {
                    if (!visible && contentRoot.visible && barRoot.connectionPanelType !== "")
                        barRoot.closeConnectionPanel();

                }

                ParallelAnimation {
                    id: showAnimation

                    NumberAnimation {
                        target: connectionPanel
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: connectionPanel
                        property: "scale"
                        from: 0.94
                        to: 1
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                }

                ParallelAnimation {
                    id: hideAnimation

                    onFinished: {
                        if (!connectionPopup.panelRequested)
                            connectionPopup.keepVisible = false;

                    }

                    NumberAnimation {
                        target: connectionPanel
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 140
                        easing.type: Easing.InCubic
                    }

                    NumberAnimation {
                        target: connectionPanel
                        property: "scale"
                        from: 1
                        to: 0.96
                        duration: 140
                        easing.type: Easing.InCubic
                    }

                }

                ConnectionPanel {
                    id: connectionPanel

                    panelType: contentRoot.visible ? barRoot.connectionPanelType : ""

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: contentRoot.topAnchored ? parent.top : undefined
                        bottom: contentRoot.topAnchored ? undefined : parent.bottom
                        topMargin: contentRoot.topAnchored ? 8 : 0
                        bottomMargin: contentRoot.topAnchored ? 0 : 8
                    }

                }

                Connections {
                    function onCloseRequested() {
                        barRoot.closeConnectionPanel();
                    }

                    target: connectionPanel
                }

            }

            Row {
                id: leftSection

                spacing: 6

                anchors {
                    left: leftIsland.left
                    right: leftIsland.right
                    leftMargin: 6
                    verticalCenter: parent.verticalCenter
                }

                CodexUsageBar {
                    id: codexUsageIndicator

                    usage: barRoot.codexUsage
                    Component.onCompleted: root.registerLauncherAnchor(barRoot.screen.name, codexUsageIndicator, contentRoot, contentRoot.topAnchored)
                    Component.onDestruction: root.unregisterLauncherAnchor(barRoot.screen.name)
                }

                SectionSeparator {
                    visible: codexUsageIndicator.visible
                }

                Workspace {
                }

                SectionSeparator {
                }

                Ram {
                }

            }

            Row {
                id: rightSection

                spacing: 6

                anchors {
                    left: rightIsland.left
                    right: rightIsland.right
                    rightMargin: 6
                    verticalCenter: parent.verticalCenter
                }

                Brightness {
                }

                SectionSeparator {
                    visible: root.showBrightnessModule
                }

                Volume {
                }

                SectionSeparator {
                    visible: wifiModule.visible || bluetoothModule.visible
                }

                Wifi {
                    id: wifiModule
                }

                Connections {
                    function onClicked() {
                        barRoot.toggleConnectionPanel("wifi");
                    }

                    target: wifiModule
                }

                SectionSeparator {
                    visible: wifiModule.visible && bluetoothModule.visible
                }

                Bluetooth {
                    id: bluetoothModule
                }

                Connections {
                    function onClicked() {
                        barRoot.toggleConnectionPanel("bluetooth");
                    }

                    target: bluetoothModule
                }

                SectionSeparator {
                }

                Date {
                }

                SectionSeparator {
                }

                Battery {
                }

                SectionSeparator {
                    visible: root.showBatteryModule
                }

                Time {
                }

                SectionSeparator {
                }

                Wlogout {
                }

            }

        }

    }

}
