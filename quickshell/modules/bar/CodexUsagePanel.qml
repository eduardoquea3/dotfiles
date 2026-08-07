import QtQuick
import QtQuick.Layouts

Item {
    id: codexUsagePanel

    property var usage: null

    width: 420
    implicitHeight: detailsCard.implicitHeight
    height: implicitHeight

    function usageColor(value) {
        if (usage.errorText !== "")
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

    Rectangle {
        id: detailsCard
        anchors.fill: parent
        implicitHeight: content.implicitHeight + 32
        radius: 12
        color: root.colBg

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: ""
                    color: root.colBlue
                    font.family: root.fontFamily
                    font.pixelSize: 18
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
                        text: usage.accountEmail !== "" ? usage.accountEmail : usage.sourceName
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: 9
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: "↻"
                    color: root.colBlue
                    font.pixelSize: 18

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: usage.refresh()
                    }
                }
            }

            Rectangle {
                visible: usage.errorText !== ""
                Layout.fillWidth: true
                implicitHeight: errorText.implicitHeight + 14
                radius: root.radius
                color: Qt.rgba(root.colRed.r, root.colRed.g, root.colRed.b, 0.16)

                Text {
                    id: errorText
                    anchors.fill: parent
                    anchors.margins: 7
                    text: usage.errorText
                    color: root.colRed
                    font.family: root.fontFamily
                    font.pixelSize: 9
                    wrapMode: Text.WordWrap
                }
            }

            LimitCard {
                Layout.fillWidth: true
                title: "5h limit"
                percent: usage.primaryPercent
                resetText: usage.primaryReset !== "" ? usage.primaryReset : formatDate(usage.primaryResetAt)
                barColor: usageColor(usage.primaryPercent)
            }

            LimitCard {
                Layout.fillWidth: true
                title: "Weekly limit"
                percent: usage.secondaryPercent
                resetText: usage.secondaryReset !== "" ? usage.secondaryReset : formatDate(usage.secondaryResetAt)
                barColor: usageColor(usage.secondaryPercent)
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 8

                MetaItem { label: "Login"; value: usage.loginMethod !== "" ? usage.loginMethod : "--" }
                MetaItem { label: "Provider"; value: usage.providerId }
                MetaItem { label: "Source"; value: usage.sourceName !== "" ? usage.sourceName : "--" }
                MetaItem { label: "CodexBar"; value: usage.versionText !== "" ? "v" + usage.versionText : "--" }
                MetaItem { label: "Credits"; value: usage.creditsRemaining + " remaining" }
                MetaItem { label: "Credit events"; value: String(usage.creditEventsCount) }
            }

            Text {
                Layout.fillWidth: true
                text: usage.loading ? "Refreshing..." : "Updated " + formatDate(usage.updatedAt)
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: 8
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    component LimitCard: Rectangle {
        id: card
        property string title: ""
        property int percent: -1
        property string resetText: ""
        property color barColor: root.colBlue

        implicitHeight: cardContent.implicitHeight + 18
        radius: 8
        color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.12)

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 9
            spacing: 5

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
                height: 6
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

    component MetaItem: ColumnLayout {
        property string label: ""
        property string value: ""
        Layout.fillWidth: true
        spacing: 1

        Text {
            text: parent.label
            color: root.colBorder
            font.family: root.fontFamily
            font.pixelSize: 8
        }

        Text {
            text: parent.value
            color: root.colFg
            font.family: root.fontFamily
            font.pixelSize: 10
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
