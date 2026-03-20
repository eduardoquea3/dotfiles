import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: volumeItem
    width: volumeText.implicitWidth + 16
    height: 20

    property var sink: Pipewire.defaultAudioSink
    property bool muted: sink && sink.audio ? sink.audio.muted : false
    property int percent: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    PwObjectTracker {
        objects: [volumeItem.sink]
    }

    function volumeIcon() {
        if (muted || percent === 0) return "󰝟"
        if (percent < 33) return "󰕿"
        if (percent < 66) return "󰖀"
        return "󰕾"
    }

    function volumeColor() {
        if (muted) return root.colBorder
        if (percent > 100) return root.colRed
        return root.colBlue
    }

    Rectangle {
        anchors.centerIn: parent
        width: volumeText.implicitWidth + 16
        height: 20
        radius: root.radius
        border.width: 1
        border.color: volumeColor()
        color: root.colBg

        Text {
            id: volumeText
            anchors.centerIn: parent
            text: volumeIcon() + " " + percent + "%"
            color: volumeColor()
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                if (sink && sink.audio)
                    sink.audio.muted = !sink.audio.muted
            }
            onWheel: wheel => {
                if (!sink || !sink.audio) return
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                sink.audio.volume = Math.max(0.0, Math.min(1.5, sink.audio.volume + delta))
            }
        }
    }
}
