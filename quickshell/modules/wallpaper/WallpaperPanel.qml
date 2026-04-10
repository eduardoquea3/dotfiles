import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: wallpaperPanel
    visible: wallpaperModule.wallpaperVisible
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    focusable: true

    WlrLayershell.keyboardFocus: wallpaperModule.wallpaperVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // ─── Full-screen blur overlay ─────────────────────────────────────────────
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.60)
        opacity: wallpaperModule.wallpaperVisible ? 1 : 0
        enabled: wallpaperModule.wallpaperVisible
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            enabled: wallpaperModule.wallpaperVisible
            onClicked: wallpaperModule.wallpaperVisible = false
        }

        // ─── Centered horizontal carrusel ──────────────────────────────────────
        Item {
            id: contentPanel
            anchors.centerIn: parent
            width: parent.width * 0.98
            height: Math.min(parent.height * 0.75, 550)

            opacity: wallpaperModule.wallpaperVisible ? 1 : 0
            scale: wallpaperModule.wallpaperVisible ? 1.0 : 0.96
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            // Scrollable area for wallpapers
            Flickable {
                id: flickable
                anchors.fill: parent
                contentWidth: Math.max(wallRow.width, width)
                contentHeight: wallRow.height
                interactive: wallRow.width > width
                clip: true

                Row {
                    id: wallRow
                    spacing: 40
                    y: (flickable.height - height) / 2
                    x: Math.max(0, (flickable.width - width) / 2)

                    Repeater {
                        model: wallpaperModule.wallpaperList

                        delegate: Item {
                            id: wallDelegate
                            width: 240
                            height: 380
                            required property int index
                            required property var modelData

                            property bool isSelected: wallpaperModule.selectedWallIndex === index

                            // Parallelogram container
                            Item {
                                anchors.centerIn: parent
                                width: 220
                                height: 340

                                // Rectangle with skew effect (parallelogram)
                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.width: isSelected ? 4 : 2
                                    border.color: isSelected ? Qt.rgba(0.4, 0.6, 0.8, 0.8) : Qt.rgba(0.6, 0.6, 0.6, 0.5)

                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Behavior on border.width { NumberAnimation { duration: 150 } }

                                    // Image with clip
                                    Item {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        clip: true

                                        Image {
                                            anchors.fill: parent
                                            source: "file://" + wallDelegate.modelData.path
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                            cache: true
                                            opacity: isSelected ? 1.0 : 0.8

                                            Behavior on opacity { NumberAnimation { duration: 150 } }
                                        }
                                    }

                                    // Apply skew to create parallelogram
                                    transform: [
                                        Matrix4x4 {
                                            matrix: Qt.matrix4x4(
                                                1,      -0.2,   0, 0,
                                                0,      1,      0, 0,
                                                0,      0,      1, 0,
                                                0,      0,      0, 1
                                            )
                                        }
                                    ]
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wallpaperModule.selectedWallIndex = wallDelegate.index
                                        wallpaperModule.applyWallpaper(wallDelegate.modelData.path)
                                    }
                                }

                                // Wallpaper name below
                                Text {
                                    anchors.top: parent.bottom
                                    anchors.topMargin: 16
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.name.replace(/\.[^.]*$/, '')
                                    color: isSelected ? Qt.rgba(0.4, 0.6, 0.8, 1) : Qt.rgba(0.8, 0.8, 0.8, 1)
                                    font.pixelSize: 12
                                    font.family: "DankMono Nerd Font"
                                    font.bold: isSelected
                                    elide: Text.ElideRight
                                    width: 240

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }

                onContentXChanged: {
                    // Auto-scroll to center selected item
                    var selectedItem = wallRow.children[wallpaperModule.selectedWallIndex]
                    if (selectedItem) {
                        var targetX = selectedItem.x + selectedItem.width / 2 - width / 2
                        contentX = Math.max(0, Math.min(targetX, contentWidth - width))
                    }
                }

                Keys.onPressed: event => {
                    var total = wallpaperModule.wallpaperList.length
                    if (total === 0) return

                    if (event.key === Qt.Key_Right) {
                        // Rotative: wraps around to first when at last
                        wallpaperModule.selectedWallIndex = (wallpaperModule.selectedWallIndex + 1) % total
                        event.accepted = true
                    } else if (event.key === Qt.Key_Left) {
                        // Rotative: wraps around to last when at first
                        wallpaperModule.selectedWallIndex = (wallpaperModule.selectedWallIndex - 1 + total) % total
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (total > 0) {
                            wallpaperModule.applyWallpaper(wallpaperModule.wallpaperList[wallpaperModule.selectedWallIndex].path)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        wallpaperModule.wallpaperVisible = false
                        event.accepted = true
                    }
                }

                Component.onCompleted: {
                    focus = true
                }
            }
        }
    }
}
