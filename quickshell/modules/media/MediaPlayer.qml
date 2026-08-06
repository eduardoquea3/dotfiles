import QtQuick

Item {
    id: mediaPlayer

    property var player: null
    property real position: 0
    property real length: 0
    readonly property bool playing: player && player.isPlaying
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0

    function formatTime(value) {
        const seconds = Number(value);
        if (!isFinite(seconds) || seconds <= 0)
            return "0:00";

        const minutes = Math.floor(seconds / 60);
        const remainder = Math.floor(seconds % 60);
        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder;
    }

    function refreshProgress() {
        position = player && player.positionSupported ? (Number(player.position) || 0) / 1000000 : 0;
        length = player && player.lengthSupported ? (Number(player.length) || 0) / 1000000 : 0;
    }

    implicitWidth: 332
    implicitHeight: 128
    width: implicitWidth
    height: implicitHeight

    Timer {
        interval: 500
        running: mediaPlayer.player !== null
        repeat: true
        triggeredOnStart: true
        onTriggered: mediaPlayer.refreshProgress()
    }

    Connections {
        function onPositionChanged() {
            mediaPlayer.refreshProgress();
        }

        function onLengthChanged() {
            mediaPlayer.refreshProgress();
        }

        target: mediaPlayer.player
    }

    Rectangle {
        anchors.fill: parent
        radius: 13
        color: root.colBg

        Item {
            anchors.fill: parent
            anchors.margins: 12

            Image {
                id: artwork

                anchors.left: parent.left
                anchors.top: parent.top
                width: 48
                height: 48
                source: mediaPlayer.player ? mediaPlayer.player.trackArtUrl : ""
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: source !== "" && status === Image.Ready
            }

            Rectangle {
                anchors.fill: artwork
                visible: !artwork.visible
                radius: 8
                color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "󰎆"
                    color: root.colPurple
                    font.family: root.fontFamily
                    font.pixelSize: 20
                }

            }

            Text {
                anchors.left: artwork.right
                anchors.leftMargin: 10
                anchors.right: controls.left
                anchors.rightMargin: 8
                anchors.top: artwork.top
                text: mediaPlayer.player && mediaPlayer.player.trackTitle ? mediaPlayer.player.trackTitle : mediaPlayer.player ? mediaPlayer.player.identity : ""
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 1
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                anchors.left: artwork.right
                anchors.leftMargin: 10
                anchors.right: controls.left
                anchors.rightMargin: 8
                anchors.top: artwork.top
                anchors.topMargin: 25
                text: {
                    if (!mediaPlayer.player)
                        return "";

                    return mediaPlayer.player.trackArtist || mediaPlayer.player.trackAlbum || mediaPlayer.player.identity;
                }
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
                elide: Text.ElideRight
            }

            Row {
                id: controls

                anchors.right: parent.right
                anchors.verticalCenter: artwork.verticalCenter
                spacing: 7

                Text {
                    visible: mediaPlayer.player && mediaPlayer.player.canGoPrevious
                    text: "󰒮"
                    color: previousMouse.containsMouse ? root.colFg : root.colBlue
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 5

                    MouseArea {
                        id: previousMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaPlayer.player.previous()
                    }

                }

                Text {
                    visible: mediaPlayer.player && mediaPlayer.player.canTogglePlaying
                    text: mediaPlayer.playing ? "󰏤" : "󰐊"
                    color: playMouse.containsMouse ? root.colFg : root.colGreen
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 6

                    MouseArea {
                        id: playMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaPlayer.player.togglePlaying()
                    }

                }

                Text {
                    visible: mediaPlayer.player && mediaPlayer.player.canGoNext
                    text: "󰒭"
                    color: nextMouse.containsMouse ? root.colFg : root.colBlue
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 5

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaPlayer.player.next()
                    }

                }

            }

            Rectangle {
                id: progressTrack

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 13
                height: 5
                radius: height / 2
                color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.34)
                visible: mediaPlayer.player && mediaPlayer.player.positionSupported

                Rectangle {
                    width: parent.width * mediaPlayer.progress
                    height: parent.height
                    radius: parent.radius
                    color: root.colGreen
                }

            }

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: mediaPlayer.formatTime(mediaPlayer.position)
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 1
                visible: progressTrack.visible
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: mediaPlayer.formatTime(mediaPlayer.length)
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 1
                visible: progressTrack.visible
            }

        }

    }

}
