import "../bar"
import QtQuick
import QtQuick.Controls
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire

Item {
    id: controlCenter

    property var notificationService: root.notificationService
    property var sink: Pipewire.defaultAudioSink
    readonly property bool mediaVisible: root.mediaPlayer !== null
    readonly property bool bluetoothEnabled: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled

    signal selectorRequested(string type)

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function setVolume(mouseX, width) {
        if (!sink || !sink.audio || width <= 0)
            return ;

        sink.audio.volume = clamp(mouseX / width, 0, 1);
    }

    function setBrightness(mouseX, width) {
        if (!brightness.available || width <= 0)
            return ;

        brightness.setPercent(Math.round(clamp(mouseX / width, 0.01, 1) * 100));
    }

    implicitWidth: 372
    implicitHeight: content.implicitHeight + 28
    width: implicitWidth
    height: implicitHeight

    Brightness {
        id: brightness

        showLabel: false
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.colBg

        Column {
            id: content

            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Loader {
                id: mediaCard

                width: parent.width
                height: visible ? implicitHeight : 0
                visible: controlCenter.mediaVisible
                source: "../media/MediaPlayer.qml"
                onLoaded: item.player = Qt.binding(() => {
                    return root.mediaPlayer;
                })
            }

            Row {
                width: parent.width
                height: 48
                spacing: 10

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    radius: 11
                    color: Networking.wifiEnabled ? Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.18) : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.14)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Networking.wifiEnabled ? "󰤨  Wi-Fi" : "󰤭  Wi-Fi"
                            color: Networking.wifiEnabled ? root.colBlue : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.parent.width - 18
                            text: Networking.wifiEnabled ? "On" : "Off"
                            color: root.colBorder
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: controlCenter.selectorRequested("wifi")
                    }

                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    radius: 11
                    color: controlCenter.bluetoothEnabled ? Qt.rgba(root.colPurple.r, root.colPurple.g, root.colPurple.b, 0.2) : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.14)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: controlCenter.bluetoothEnabled ? "󰂯  Bluetooth" : "󰂲  Bluetooth"
                            color: controlCenter.bluetoothEnabled ? root.colPurple : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: controlCenter.bluetoothEnabled ? "On" : "Off"
                            color: root.colBorder
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            controlCenter.selectorRequested("bluetooth");
                        }
                    }

                }

            }

            Item {
                width: parent.width
                height: 45

                Text {
                    id: volumeLabel

                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: controlCenter.sink && controlCenter.sink.audio && controlCenter.sink.audio.muted ? "󰝟  Volume" : "󰕾  Volume"
                    color: root.colBlue
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                Text {
                    anchors.right: parent.right
                    anchors.baseline: volumeLabel.baseline
                    text: controlCenter.sink && controlCenter.sink.audio ? Math.round(controlCenter.clamp(controlCenter.sink.audio.volume, 0, 1) * 100) + "%" : "--"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Rectangle {
                    id: volumeTrack

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 6
                    radius: height / 2
                    color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.34)

                    Rectangle {
                        width: parent.width * (controlCenter.sink && controlCenter.sink.audio ? controlCenter.clamp(controlCenter.sink.audio.volume, 0, 1) : 0)
                        height: parent.height
                        radius: parent.radius
                        color: root.colBlue
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => {
                            return controlCenter.setVolume(mouse.x, width);
                        }
                        onPositionChanged: (mouse) => {
                            if (pressed)
                                controlCenter.setVolume(mouse.x, width);

                        }
                    }

                }

                MouseArea {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: volumeLabel.implicitWidth + 8
                    height: volumeLabel.implicitHeight
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (controlCenter.sink && controlCenter.sink.audio)
                            controlCenter.sink.audio.muted = !controlCenter.sink.audio.muted;

                    }
                }

            }

            Item {
                width: parent.width
                height: brightness.available ? 45 : 0
                visible: brightness.available

                Text {
                    id: brightnessLabel

                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: "󰃠  Brightness"
                    color: root.colYellow
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                Text {
                    anchors.right: parent.right
                    anchors.baseline: brightnessLabel.baseline
                    text: brightness.percent + "%"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 6
                    radius: height / 2
                    color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.34)

                    Rectangle {
                        width: parent.width * brightness.percent / 100
                        height: parent.height
                        radius: parent.radius
                        color: root.colYellow
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => {
                            return controlCenter.setBrightness(mouse.x, width);
                        }
                        onPositionChanged: (mouse) => {
                            if (pressed)
                                controlCenter.setBrightness(mouse.x, width);

                        }
                    }

                }

            }

            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifications"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 1
                    font.bold: true
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Clear all"
                    color: clearAllMouse.containsMouse ? root.colFg : root.colBlue
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                    visible: notificationList.count > 0

                    MouseArea {
                        id: clearAllMouse

                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (controlCenter.notificationService)
                                controlCenter.notificationService.clearAll();

                        }
                    }

                }

            }

            ListView {
                id: notificationList

                width: parent.width
                height: 150
                clip: true
                spacing: 6
                model: controlCenter.notificationService ? controlCenter.notificationService.trackedNotifications : null
                boundsBehavior: Flickable.StopAtBounds

                Text {
                    anchors.centerIn: parent
                    text: "No notifications"
                    color: root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    visible: notificationList.count === 0
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    required property var modelData

                    width: notificationList.width
                    height: 54
                    radius: 9
                    color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.12)

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: closeNotification.left
                        anchors.rightMargin: 8
                        anchors.top: parent.top
                        anchors.topMargin: 7
                        text: modelData.summary || modelData.appName
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: closeNotification.left
                        anchors.rightMargin: 8
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 7
                        text: modelData.body || modelData.appName
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 1
                        elide: Text.ElideRight
                    }

                    Text {
                        id: closeNotification

                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅖"
                        color: closeMouse.containsMouse ? root.colFg : root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize + 2

                        MouseArea {
                            id: closeMouse

                            anchors.fill: parent
                            anchors.margins: -5
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (controlCenter.notificationService)
                                    controlCenter.notificationService.dismiss(modelData);

                            }
                        }

                    }

                }

            }

        }

    }

}
