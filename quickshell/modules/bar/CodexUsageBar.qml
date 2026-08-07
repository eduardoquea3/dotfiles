import QtQuick

Item {
    id: codexUsageBar

    property var usage: null

    readonly property bool hasUsage: usage && usage.hasUsage
    readonly property bool hasError: usage && usage.errorText !== ""

    visible: hasUsage || hasError
    width: visible ? usageText.implicitWidth + 8 : 0
    height: 20

    function usageLabel() {
        if (hasError || !hasUsage)
            return "--";

        var value = usage.primaryPercent >= 0
            ? usage.primaryPercent
            : usage.secondaryPercent;
        return Math.round(value) + "%";
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
        text: " " + codexUsageBar.usageLabel()
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
