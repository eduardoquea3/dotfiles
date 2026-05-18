import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: delegateRoot
    width: ListView.view.width
    height: modelData.imagePath !== "" ? 240 : 88

    // Theme references (Kanagawa)
    readonly property color colBg: root.colBg
    readonly property color colFg: root.colFg
    readonly property color colBorder: root.colBorder
    readonly property color colBlue: root.colBlue
    readonly property color colRed: root.colRed
    readonly property string fontFamily: root.fontFamily

    property bool isSelected: ListView.isCurrentItem
    property bool isHovered: itemMouseArea.containsMouse

    function select() {
        copyToClipboard.selectedItem = modelData.raw;
        copyToClipboard.running = true;
    }

    function remove() {
        let id = modelData.raw.split('\t')[0];
        deleteEntry.targetRaw = modelData.raw;
        deleteEntry.targetId = id;
        deleteEntry.running = true;
    }

    Rectangle {
        id: itemBox
        anchors.centerIn: parent
        width: parent.width - 32
        height: parent.height
        radius: 16

        scale: itemMouseArea.pressed ? 0.97 : (delegateRoot.isSelected || delegateRoot.isHovered ? 1.015 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        color: delegateRoot.isSelected ? Qt.rgba(delegateRoot.colBlue.r, delegateRoot.colBlue.g, delegateRoot.colBlue.b, 0.18) : (delegateRoot.isHovered ? Qt.lighter(delegateRoot.colBg, 1.08) : delegateRoot.colBg)
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Rectangle {
            id: activeIndicator
            width: 4
            height: delegateRoot.isSelected ? parent.height * 0.45 : 0
            opacity: delegateRoot.isSelected ? 1.0 : 0.0
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
            color: delegateRoot.colBlue
        }

        Image {
            id: imgPreview
            visible: modelData.imagePath !== ""
            source: modelData.imagePath !== "" ? "file://" + modelData.imagePath : ""
            anchors.left: parent.left
            anchors.right: deleteSeparator.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 24
            anchors.rightMargin: 16
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignLeft
            asynchronous: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: imgPreview.width
                    height: imgPreview.height
                    radius: 8
                }
            }
        }

        Text {
            visible: modelData.imagePath === ""
            anchors.left: parent.left
            anchors.right: deleteSeparator.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 24
            anchors.rightMargin: 16
            text: modelData.display
            textFormat: Text.PlainText
            color: delegateRoot.isSelected ? delegateRoot.colFg : delegateRoot.colFg
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font {
                family: delegateRoot.fontFamily
                pixelSize: 16
            }
        }

        Rectangle {
            id: deleteSeparator
            width: 1
            height: 40
            anchors.right: deleteIconBtn.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            color: delegateRoot.isSelected ? delegateRoot.colFg : delegateRoot.colBorder
            opacity: delegateRoot.isSelected ? 0.5 : 0.3
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        Rectangle {
            id: deleteIconBtn
            z: 1
            width: 44
            height: 44
            radius: 22
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            color: deleteMouseArea.containsMouse ? delegateRoot.colRed : "transparent"
            scale: deleteMouseArea.pressed ? 0.85 : (deleteMouseArea.containsMouse ? 1.1 : 1.0)
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰆴"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                color: deleteMouseArea.containsMouse ? "#ffffff" : delegateRoot.colRed
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                onClicked: mouse => {
                    mouse.accepted = true;
                    delegateRoot.remove();
                }
            }
        }

        MouseArea {
            id: itemMouseArea
            anchors.fill: parent
            anchors.rightMargin: 60
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: delegateRoot.ListView.view.currentIndex = index
            onClicked: delegateRoot.select()
        }
    }
}
