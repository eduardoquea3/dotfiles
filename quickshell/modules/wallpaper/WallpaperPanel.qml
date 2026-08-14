import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: wallpaperPanel

    function syncGridSelection() {
        if (wallpaperGrid.count === 0)
            return ;

        var index = wallpaperModule.indexForPath(wallpaperModule.selectedWallpaperPath);
        wallpaperGrid.currentIndex = index >= 0 ? index : 0;
        wallpaperGrid.positionViewAtIndex(wallpaperGrid.currentIndex, GridView.Contain);
        wallpaperGrid.forceActiveFocus();
    }

    visible: wallpaperModule.wallpaperVisible
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: wallpaperModule.wallpaperVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Timer {
        id: focusTimer

        interval: 40
        repeat: false
        onTriggered: wallpaperPanel.syncGridSelection()
    }

    Rectangle {
        id: overlay

        anchors.fill: parent
        color: Qt.rgba(0.01, 0.02, 0.03, 0.68)
        opacity: wallpaperModule.wallpaperVisible ? 1 : 0
        enabled: wallpaperModule.wallpaperVisible

        MouseArea {
            anchors.fill: parent
            enabled: wallpaperModule.wallpaperVisible
            onClicked: wallpaperModule.wallpaperVisible = false
        }

        Rectangle {
            id: contentPanel

            anchors.centerIn: parent
            width: Math.min(parent.width * 0.9, 1040)
            height: Math.min(parent.height * 0.84, 720)
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.97)
            radius: 18
            border.width: 1
            border.color: Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.45)
            opacity: wallpaperModule.wallpaperVisible ? 1 : 0
            scale: wallpaperModule.wallpaperVisible ? 1 : 0.96

            MouseArea {
                anchors.fill: parent
                onClicked: {
                }
            }

            Item {
                id: header

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 76

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    anchors.top: parent.top
                    anchors.topMargin: 17
                    text: "Wallpapers"
                    color: root.walForeground
                    font.family: root.fontFamily
                    font.pixelSize: 22
                    font.bold: true
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 23
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 13
                    text: wallpaperModule.wallpaperList.length + " images  /  " + wallpaperModule.wallpaperPath
                    color: root.walColor8
                    font.family: root.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideMiddle
                    width: parent.width - 46
                }

            }

            GridView {
                id: wallpaperGrid

                anchors.top: header.bottom
                anchors.bottom: footer.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                clip: true
                cellWidth: width / 3
                cellHeight: Math.max(122, Math.min(190, cellWidth * 0.72 + 28))
                model: wallpaperModule.wallpaperList
                cacheBuffer: 400
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                keyNavigationEnabled: false
                onCurrentIndexChanged: wallpaperModule.selectWallpaperIndex(currentIndex)
                Keys.onPressed: function(event) {
                    var nextIndex = currentIndex;
                    if (event.key === Qt.Key_Right) {
                        nextIndex = Math.min(currentIndex + 1, count - 1);
                    } else if (event.key === Qt.Key_Left) {
                        nextIndex = Math.max(currentIndex - 1, 0);
                    } else if (event.key === Qt.Key_Down) {
                        nextIndex = Math.min(currentIndex + 3, count - 1);
                    } else if (event.key === Qt.Key_Up) {
                        nextIndex = Math.max(currentIndex - 3, 0);
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (currentIndex >= 0 && currentIndex < count)
                            wallpaperModule.applyWallpaper(wallpaperModule.wallpaperList[currentIndex].path);

                        event.accepted = true;
                        return ;
                    } else if (event.key === Qt.Key_Escape) {
                        wallpaperModule.wallpaperVisible = false;
                        event.accepted = true;
                        return ;
                    } else {
                        return ;
                    }
                    if (nextIndex !== currentIndex) {
                        currentIndex = nextIndex;
                        positionViewAtIndex(currentIndex, GridView.Contain);
                    }
                    event.accepted = true;
                }

                Text {
                    anchors.centerIn: parent
                    visible: wallpaperGrid.count === 0
                    text: "No wallpapers found"
                    color: root.walColor8
                    font.family: root.fontFamily
                    font.pixelSize: 14
                }

                delegate: Item {
                    id: wallpaperCell

                    required property int index
                    required property var modelData
                    property bool isCurrent: GridView.isCurrentItem
                    property bool isApplied: wallpaperModule.indexForPath(wallpaperModule.currentWallpaperPath) === index
                    property bool isHovered: wallpaperMouse.containsMouse
                    property real rowIndex: Math.floor(index / 3)
                    property real columnIndex: index % 3
                    property real rowCount: Math.ceil(wallpaperGrid.count / 3)
                    property real centerRow: (rowCount - 1) / 2
                    property real centerColumn: 1
                    property real revealDelay: Math.sqrt(Math.pow(rowIndex - centerRow, 2) + Math.pow(columnIndex - centerColumn, 2)) * 35

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight
                    opacity: 0
                    scale: 0.92
                    transformOrigin: Item.Center
                    Component.onCompleted: {
                        if (wallpaperModule.wallpaperVisible)
                            revealAnimation.start();

                    }

                    Connections {
                        function onWallpaperVisibleChanged() {
                            if (wallpaperModule.wallpaperVisible)
                                revealAnimation.restart();

                        }

                        target: wallpaperModule
                    }

                    SequentialAnimation {
                        id: revealAnimation

                        PauseAnimation {
                            duration: wallpaperCell.revealDelay
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: wallpaperCell
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 240
                                easing.type: Easing.OutCubic
                            }

                            NumberAnimation {
                                target: wallpaperCell
                                property: "scale"
                                from: 0.92
                                to: 1
                                duration: 300
                                easing.type: Easing.OutBack
                                easing.overshoot: 0.35
                            }

                        }

                    }

                    Rectangle {
                        id: thumbnailCard

                        anchors.fill: parent
                        anchors.margins: 5
                        radius: 12
                        color: wallpaperCell.isApplied ? Qt.rgba(root.walColor2.r, root.walColor2.g, root.walColor2.b, 0.16) : wallpaperCell.isCurrent ? Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.18) : Qt.rgba(0, 0, 0, 0.24)
                        border.width: wallpaperCell.isApplied ? 2 : wallpaperCell.isCurrent ? 1 : 0
                        border.color: wallpaperCell.isApplied ? root.walColor2 : root.walColor13
                        scale: wallpaperCell.isHovered ? 1.025 : 1

                        ClippingRectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 10
                            color: "#20242a"

                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData.path
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize.width: 420
                                sourceSize.height: 280
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "#ffffff"
                                opacity: wallpaperCell.isHovered ? 0.07 : 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                    }

                                }

                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 46
                                visible: wallpaperCell.isHovered || wallpaperCell.isCurrent || wallpaperCell.isApplied

                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.leftMargin: 9
                                    anchors.rightMargin: 9
                                    anchors.bottomMargin: 8
                                    text: modelData.name
                                    color: "#ffffff"
                                    font.family: root.fontFamily
                                    font.pixelSize: 10
                                    font.bold: wallpaperCell.isApplied || wallpaperCell.isCurrent
                                    elide: Text.ElideMiddle
                                }

                                gradient: Gradient {
                                    GradientStop {
                                        position: 0
                                        color: "#00000000"
                                    }

                                    GradientStop {
                                        position: 1
                                        color: "#d9000000"
                                    }

                                }

                            }

                            Rectangle {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 7
                                width: 30
                                height: 18
                                radius: 9
                                color: root.walColor2
                                visible: wallpaperCell.isApplied

                                Text {
                                    anchors.centerIn: parent
                                    text: "ON"
                                    color: root.walBackground
                                    font.family: root.fontFamily
                                    font.pixelSize: 8
                                    font.bold: true
                                }

                            }

                        }

                        MouseArea {
                            id: wallpaperMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    wallpaperGrid.currentIndex = wallpaperCell.index;
                                    wallpaperModule.selectWallpaperIndex(wallpaperCell.index);
                                }
                            }
                            onClicked: wallpaperModule.applyWallpaper(modelData.path)
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 130
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 130
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

            Item {
                id: footer

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 40

                Text {
                    anchors.centerIn: parent
                    text: "SUPER+W toggle   arrows navigate   Enter apply   Esc close"
                    color: root.walColor8
                    font.family: root.fontFamily
                    font.pixelSize: 10
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }

        }

    }

    Connections {
        function onWallpaperVisibleChanged() {
            if (wallpaperModule.wallpaperVisible)
                focusTimer.restart();

        }

        function onWallpaperListChanged() {
            if (wallpaperModule.wallpaperVisible)
                focusTimer.restart();

        }

        target: wallpaperModule
    }

}
