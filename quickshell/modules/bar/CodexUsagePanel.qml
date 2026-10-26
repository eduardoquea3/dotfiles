import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: codexUsagePanel

    property var usage: null
    readonly property bool barAtTop: root.barPosition === "top"
    readonly property int barOffset: 18
    property bool refreshingPopupFocusMode: false

    visible: usage !== null && usage.panelVisible && !refreshingPopupFocusMode
    color: "transparent"
    width: 438
    implicitHeight: detailsCard.implicitHeight

    WlrLayershell.layer: WlrLayer.Overlay
    anchors {
        top: barAtTop
        left: true
        bottom: !barAtTop
    }
    margins {
        top: barAtTop ? barOffset : 0
        bottom: barAtTop ? 0 : barOffset
        left: 12
    }

    onVisibleChanged: {
        if (visible && !root.screenshotActive)
            focusGrab.active = true;
        else
            focusGrab.active = false;
    }

    Connections {
        target: root

        function onScreenshotActiveChanged() {
            codexUsagePanel.refreshingPopupFocusMode = true;
            focusGrab.active = false;
            Qt.callLater(() => {
                codexUsagePanel.refreshingPopupFocusMode = false;
                if (codexUsagePanel.visible && !root.screenshotActive)
                    focusGrab.active = true;
            });
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [codexUsagePanel]
        onCleared: {
            if (codexUsagePanel.refreshingPopupFocusMode || root.screenshotActive)
                return;
            if (usage)
                usage.closePanel();
        }
    }

    function usageColor(value) {
        if (usage && usage.errorText !== "")
            return root.colRed;
        if (value >= 85)
            return root.colRed;
        if (value >= 60)
            return root.colYellow;
        return root.colBlue;
    }

    function ratio(value) {
        return value < 0 || isNaN(value) ? 0 : Math.min(1, Math.max(0, value / 100));
    }

    function percentLabel(value) {
        return value < 0 || isNaN(value) ? "--" : Math.round(value) + "%";
    }

    function formatDate(isoText) {
        if (!isoText)
            return "";

        var parts = String(isoText).match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):\d{2}Z$/);
        if (!parts)
            return String(isoText);

        var year = Number(parts[1]);
        var month = Number(parts[2]);
        var day = Number(parts[3]);
        var hour = Number(parts[4]) - 5;
        var minute = Number(parts[5]);

        if (hour < 0) {
            hour += 24;
            day -= 1;
            if (day === 0) {
                month -= 1;
                if (month === 0) {
                    month = 12;
                    year -= 1;
                }
                var leapYear = year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
                var monthDays = [31, leapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
                day = monthDays[month - 1];
            }
        }

        function twoDigits(value) { return value < 10 ? "0" + value : String(value); }
        return year
            + "-" + twoDigits(month)
            + "-" + twoDigits(day)
            + " " + twoDigits(hour)
            + ":" + twoDigits(minute)
            + " PET";
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: codexUsagePanel.visible && !root.screenshotActive
        onActivated: {
            if (usage)
                usage.closePanel();
        }
    }

    Rectangle {
        id: detailsCard
        anchors.fill: parent
        implicitHeight: content.implicitHeight + 32
        radius: 20
        color: root.colBg
        border.color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.42)
        border.width: 1

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 11
                    color: Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.12)
                    border.color: Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: root.colBlue
                        font.family: root.fontFamily
                        font.pixelSize: 19
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Codex usage"
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Text {
                        text: usage && usage.accountEmail !== "" ? usage.accountEmail : (usage ? usage.sourceName : "")
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 15
                    color: refreshMouse.containsMouse ? Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.1) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: root.colFg
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: usage.refresh()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.24)
            }

            Text {
                Layout.topMargin: 8
                text: "USAGE LIMITS"
                color: root.colFg
                opacity: 0.82
                font.family: root.fontFamily
                font.pixelSize: 10
                font.letterSpacing: 1.2
                font.bold: true
            }

            LimitCard {
                Layout.fillWidth: true
                title: "5h limit"
                percent: usage ? usage.primaryPercent : -1
                resetText: usage ? (usage.primaryReset !== "" ? usage.primaryReset : formatDate(usage.primaryResetAt)) : ""
                barColor: usageColor(percent)
            }

            LimitCard {
                Layout.fillWidth: true
                title: "Weekly limit"
                percent: usage ? usage.secondaryPercent : -1
                resetText: usage ? (usage.secondaryReset !== "" ? usage.secondaryReset : formatDate(usage.secondaryResetAt)) : ""
                barColor: usageColor(percent)
            }

            Rectangle {
                visible: usage && usage.errorText !== ""
                Layout.fillWidth: true
                implicitHeight: errorText.implicitHeight + 16
                radius: 10
                color: Qt.rgba(root.colRed.r, root.colRed.g, root.colRed.b, 0.16)

                Text {
                    id: errorText
                    anchors.fill: parent
                    anchors.margins: 8
                    text: usage ? usage.errorText : ""
                    color: root.colRed
                    font.family: root.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: usage ? (usage.loading ? "Refreshing..." : "Updated " + formatDate(usage.updatedAt)) : ""
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: 9
            }
        }
    }

    component LimitCard: Rectangle {
        id: card
        property string title: ""
        property int percent: -1
        property string resetText: ""
        property color barColor: root.colBlue

        implicitHeight: cardContent.implicitHeight + 20
        radius: 15
        color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.11)
        border.color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.12)
        border.width: 1

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 14
            spacing: 9

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: card.title
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    text: percentLabel(card.percent)
                    color: card.barColor
                    font.family: root.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 5
                radius: 3
                color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.3)

                Rectangle {
                    width: parent.width * ratio(card.percent)
                    height: parent.height
                    radius: parent.radius
                    color: card.barColor
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Resets"
                    color: root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: 9
                }

                Text {
                    Layout.fillWidth: true
                    text: card.resetText !== "" ? card.resetText : "--"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: 9
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                }
            }
        }
    }
}
