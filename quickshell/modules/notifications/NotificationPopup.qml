import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: notificationPopup

    property var notification: notificationService.popupVisible ? notificationService.currentNotification : null
    property string barPosition: notificationService.barPosition
    property int stackOffset: 38

    function iconSource() {
        if (!notification)
            return "";

        if (notification.image)
            return notification.image;

        if (!notification.appIcon)
            return "";

        return notification.appIcon.startsWith("/") ? "file://" + notification.appIcon : "image://icon/" + notification.appIcon;
    }

    screen: modelData
    visible: notification !== null
    implicitWidth: 332
    implicitHeight: 96
    color: "transparent"
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "notification-popup"

    anchors {
        top: notificationPopup.barPosition === "top"
        bottom: notificationPopup.barPosition !== "top"
    }

    margins {
        top: notificationPopup.barPosition === "top" ? notificationPopup.stackOffset : 0
        bottom: notificationPopup.barPosition === "top" ? 0 : notificationPopup.stackOffset
    }

    Rectangle {
        anchors.fill: parent
        radius: 13
        color: root.colBg
        border.color: root.colBorder
        border.width: 1

        Item {
            anchors.fill: parent
            anchors.margins: 12

            Image {
                id: icon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 36
                source: notificationPopup.iconSource()
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: source !== "" && status === Image.Ready
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: icon.visible ? 48 : 0
                anchors.right: dismissButton.left
                anchors.rightMargin: 10
                anchors.top: parent.top
                text: notificationPopup.notification && notificationPopup.notification.summary ? notificationPopup.notification.summary : notificationPopup.notification ? notificationPopup.notification.appName : ""
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 1
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: icon.visible ? 48 : 0
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 24
                text: notificationPopup.notification ? notificationPopup.notification.body : ""
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
                visible: text.length > 0
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: icon.visible ? 48 : 0
                anchors.bottom: parent.bottom
                text: notificationPopup.notification ? notificationPopup.notification.appName : ""
                color: root.colBlue
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 1
                elide: Text.ElideRight
                width: parent.width - (icon.visible ? 48 : 0) - 28
                visible: text.length > 0
            }

            Text {
                id: dismissButton

                anchors.right: parent.right
                anchors.top: parent.top
                text: "󰅖"
                color: dismissMouse.containsMouse ? root.colFg : root.colBorder
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2

                MouseArea {
                    id: dismissMouse

                    anchors.fill: parent
                    anchors.margins: -5
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (notificationPopup.notification)
                            notificationPopup.notification.dismiss();

                    }
                }

            }

        }

    }

}
