import Quickshell
import Quickshell.Wayland
import QtQuick

import "../modules/bar"

PanelWindow {
    id: barWindow
    property var codexUsage: null
    readonly property bool detailsVisible: codexUsage && codexUsage.panelVisible

    color: "transparent"
    anchors {
        top: false
        left: true
        right: true
        bottom: true
    }
    implicitHeight: barRail.height + 8

    component SectionSeparator: Rectangle {
        width: 1
        height: 14
        color: root.colBorder
        opacity: 0.65
    }

    PopupWindow {
        id: codexUsagePopup
        anchor.item: codexUsageIndicator
        anchor.edges: Edges.Top | Edges.Left
        anchor.gravity: Edges.Top | Edges.Left
        visible: barWindow.detailsVisible
        grabFocus: true
        color: "transparent"
        implicitWidth: 420
        implicitHeight: codexUsageDetails.implicitHeight + panelConnector.height

        onVisibleChanged: {
            if (!visible && barWindow.detailsVisible)
                barWindow.codexUsage.closePanel()
        }

        CodexUsagePanel {
            id: codexUsageDetails
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            usage: barWindow.codexUsage
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

    Rectangle {
        id: barRail
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 4
            rightMargin: 4
            bottomMargin: 4
        }
        height: 26
        radius: 10
        color: root.colBg

    Row {
        id: leftSection
        anchors {
            left: barRail.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        spacing: 6
        CodexUsageBar {
            id: codexUsageIndicator
            usage: barWindow.codexUsage
        }
        SectionSeparator { visible: codexUsageIndicator.visible }
        Workspace {}
        SectionSeparator {}
        Ram {}
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
        Wifi {}
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
