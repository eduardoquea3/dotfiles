import "../modules/bar"
import "../modules/control-center"
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
    readonly property int statusMode: 0
    readonly property int controlCenterMode: 1
    readonly property int mode: root.controlCenterOpen ? controlCenterMode : statusMode
    property string selectorType: ""

    function toggleConnectionSelector(type) {
        selectorType = selectorType === type ? "" : type;
    }

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

    visible: barVisible
    Component.onCompleted: reloadBarConfig()
    onBarVisibleChanged: {
        if (!barVisible)
            root.controlCenterOpen = false;

    }
    onBarPositionChanged: root.barPosition = barPosition

    Connections {
        function onControlCenterOpenChanged() {
            if (!root.controlCenterOpen)
                barRoot.selectorType = "";

        }

        target: root
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

    PanelWindow {
        id: barSurface

        screen: barRoot.screen
        visible: barRoot.barVisible
        color: "transparent"
        // Side selectors are siblings of the capsule, so the layer surface must
        // remain tall enough to compose and receive input for them mid-transition.
        implicitHeight: Math.max(barCapsule.height + 8, connectionSelector.open ? connectionSelector.height + 8 : 0)
        exclusiveZone: 34
        exclusionMode: ExclusionMode.Normal
        focusable: false
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: barRoot.barPosition === "top"
            left: true
            right: true
            bottom: barRoot.barPosition !== "top"
        }

        Rectangle {
            id: barCapsule

            readonly property real targetWidth: barRoot.mode === barRoot.statusMode ? moduleRow.implicitWidth + 24 : controlCenter.implicitWidth
            readonly property real targetHeight: barRoot.mode === barRoot.statusMode ? 26 : controlCenter.implicitHeight

            implicitWidth: targetWidth
            implicitHeight: targetHeight
            width: targetWidth
            height: targetHeight
            radius: barRoot.mode === barRoot.statusMode ? height / 2 : 16
            color: root.colBg
            clip: true

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: barRoot.barPosition === "top" ? parent.top : undefined
                bottom: barRoot.barPosition === "top" ? undefined : parent.bottom
                topMargin: 4
                bottomMargin: 4
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                z: 0
                onClicked: root.toggleControlCenter()
            }

            Row {
                id: moduleRow

                z: 1
                anchors.centerIn: parent
                spacing: 6
                opacity: barRoot.mode === barRoot.statusMode ? 1 : 0
                visible: opacity > 0

                Battery {
                }

                Volume {
                }

                Workspace {
                }

                Wifi {
                }

                Time {
                }

                Ram {
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Loader {
                id: controlCenter

                anchors.centerIn: parent
                z: 1
                source: "../modules/control-center/ControlCenter.qml"
                opacity: barRoot.mode === barRoot.controlCenterMode ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Behavior on width {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on height {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on radius {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }

            }

        }

        ConnectionSelector {
            id: connectionSelector

            anchors.left: selectorType === "bluetooth" ? barCapsule.right : undefined
            anchors.leftMargin: selectorType === "bluetooth" ? 10 : 0
            anchors.right: selectorType === "bluetooth" ? undefined : barCapsule.left
            anchors.rightMargin: selectorType === "bluetooth" ? 0 : 10
            anchors.verticalCenter: barCapsule.verticalCenter
            selectorType: barRoot.selectorType
            z: 2
        }

        Connections {
            function onSelectorRequested(type) {
                barRoot.toggleConnectionSelector(type);
            }

            target: controlCenter.item
        }

        mask: Region {
            item: barCapsule
            radius: barCapsule.radius

            Region {
                item: connectionSelector
                radius: 16
                width: connectionSelector.open ? connectionSelector.width : 0
                height: connectionSelector.open ? connectionSelector.height : 0
            }

        }

    }

}
