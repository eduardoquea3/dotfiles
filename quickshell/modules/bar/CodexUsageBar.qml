import QtQuick

Item {
    id: codexUsageBar

    property var usage: null

    readonly property bool hasUsage: usage && usage.hasUsage
    readonly property bool hasError: usage && usage.errorText !== ""

    visible: hasUsage || hasError
    width: visible ? usageText.implicitWidth + 12 : 0
    height: 20

    function usageLabel() {
        if (hasError)
            return "ERR";

        var labels = [];
        if (usage.primaryPercent >= 0)
            labels.push("5h " + Math.round(usage.primaryPercent) + "%");
        if (usage.secondaryPercent >= 0)
            labels.push("W " + Math.round(usage.secondaryPercent) + "%");
        return labels.join("  ");
    }

    function usageColor() {
        if (hasError)
            return root.colRed;

        var highest = Math.max(usage.primaryPercent, usage.secondaryPercent);
        if (highest >= 85)
            return root.colRed;
        if (highest >= 60)
            return root.colYellow;
        return root.colBlue;
    }

    Text {
        id: usageText
        anchors.centerIn: parent
        text: "󰧑 " + codexUsageBar.usageLabel()
        color: codexUsageBar.usageColor()
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
            bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: usage.togglePanel()
    }
}
