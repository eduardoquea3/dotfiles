import QtQuick
import QtQuick.Layouts

Rectangle {
    required property string iconPath
    required property string label
    property bool destructive: false
    signal clicked()

    radius: 12
    color: buttonMouse.containsMouse
        ? destructive
            ? Qt.rgba(1, 0.3, 0.3, 0.15)
            : Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.1)
        : "transparent"

    border.width: 1.5
    border.color: destructive
        ? Qt.rgba(1, 0.3, 0.3, 0.4)
        : Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.3)

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Image {
            source: iconPath
            sourceSize.width: 40
            sourceSize.height: 40
            Layout.alignment: Qt.AlignHCenter
            smooth: true
            opacity: buttonMouse.containsMouse ? 1 : 0.8
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Text {
            text: label
            color: destructive ? Qt.rgba(1, 0.4, 0.4, 1) : root.walForeground
            font.pixelSize: 11
            font.family: root.fontFamily
            font.bold: destructive
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }

    Keys.onEscapePressed: {
        logoutModule.logoutVisible = false
        event.accepted = true
    }
}
