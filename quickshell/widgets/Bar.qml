import Quickshell
import Quickshell.Wayland
import QtQuick

import "../modules/bar"
import "../modules/connectivity"

PanelWindow {
    id: barWindow
    WlrLayershell.namespace: "quickshell-bar"
    property var codexUsage: null
    property string connectionPanelType: ""
    property bool refreshingPopupFocusMode: false

    function toggleConnectionPanel(type) {
        connectionPanelType = connectionPanelType === type ? "" : type
    }

    function closeConnectionPanel() {
        connectionPanelType = ""
    }

    Connections {
        target: root

        function onScreenshotActiveChanged() {
            barWindow.refreshingPopupFocusMode = true;
            Qt.callLater(() => barWindow.refreshingPopupFocusMode = false);
        }
    }

    color: "transparent"
    anchors {
        top: root.barPosition === "top"
        left: true
        right: true
        bottom: root.barPosition !== "top"
    }
    implicitHeight: barRail.height

    component SectionSeparator: Rectangle {
        width: 1
        height: 14
        color: root.colBorder
        opacity: 0.20
    }

    PopupWindow {
        id: connectionPopup
        anchor.item: connectionPanelType === "bluetooth" ? bluetoothIndicator : wifiIndicator
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Top | Edges.Right
        visible: barWindow.connectionPanelType !== "" && !barWindow.refreshingPopupFocusMode
        grabFocus: !root.screenshotActive
        color: "transparent"
        implicitWidth: connectionPanel.implicitWidth
        implicitHeight: connectionPanel.implicitHeight + 8

        onVisibleChanged: {
            const dismissedType = barWindow.connectionPanelType;
            if (visible || barWindow.refreshingPopupFocusMode || dismissedType === "")
                return;

            Qt.callLater(() => {
                if (!barWindow.refreshingPopupFocusMode && barWindow.connectionPanelType === dismissedType)
                    barWindow.closeConnectionPanel();
            });
        }

        Shortcut {
            sequence: "Escape"
            context: Qt.WindowShortcut
            enabled: connectionPopup.visible && !root.screenshotActive
            onActivated: barWindow.closeConnectionPanel()
        }

        ConnectionPanel {
            id: connectionPanel
            panelType: barWindow.connectionPanelType
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 8
            }
        }

    }

    Rectangle {
        id: barRail
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 26
        color: Qt.rgba(root.colBg.r, root.colBg.g, root.colBg.b, 1)

    Row {
        id: leftSection
        anchors {
            left: barRail.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        spacing: 6
        Workspace {}
        SectionSeparator {}
        KeyboardLayout {}
        SectionSeparator {}
        Ram {}
        SectionSeparator { visible: codexUsageIndicator.visible }
        CodexUsageBar {
            id: codexUsageIndicator
            usage: barWindow.codexUsage
        }
    }

    Row {
        anchors {
            right: barRail.right
            rightMargin: 6
            verticalCenter: parent.verticalCenter
        }
        spacing: 6
        Brightness {}
        SectionSeparator { visible: root.showBrightnessModule }
        Volume {}
        SectionSeparator {}
        Wifi {
            id: wifiIndicator
        }

        Connections {
            target: wifiIndicator

            function onClicked() {
                barWindow.toggleConnectionPanel("wifi")
            }
        }

        SectionSeparator { visible: wifiIndicator.visible || bluetoothIndicator.visible }

        Bluetooth {
            id: bluetoothIndicator
        }

        Connections {
            target: bluetoothIndicator

            function onClicked() {
                barWindow.toggleConnectionPanel("bluetooth")
            }
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
