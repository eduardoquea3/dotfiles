import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: keybindsPanel
    visible: shouldShow
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    focusable: true

    property bool shouldShow: keybindsModule.keybindsVisible

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [keybindsPanel]
        active: shouldShow
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        opacity: shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: keybindsModule.keybindsVisible = false
        }

        Item {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.9, 1200)
            height: Math.min(parent.height * 0.9, 800)

            scale: shouldShow ? 1 : 0.95
            Behavior on scale { NumberAnimation { duration: 200 } }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.95)
                radius: 14
                border.width: 1
                border.color: Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.3)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "⌨️"
                            font.pixelSize: 20
                        }

                        Text {
                            text: "Keybindings"
                            color: root.walForeground
                            font.pixelSize: 16
                            font.bold: true
                            font.family: root.fontFamily
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: keybindsModule.filteredCount + "/" + keybindsModule.keybindsList.length
                            color: root.walColor8
                            font.pixelSize: 11
                            font.family: root.fontFamily
                            opacity: 0.6
                        }
                    }

                    // Search bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 10
                        border.width: searchField.activeFocus ? 1 : 0
                        border.color: root.walColor5

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                text: "🔍"
                                font.pixelSize: 14
                            }

                            TextInput {
                                id: searchField
                                Layout.fillWidth: true
                                color: root.walForeground
                                font.pixelSize: 13
                                font.family: root.fontFamily
                                verticalAlignment: TextInput.AlignVCenter
                                onTextChanged: keybindsModule.searchTerm = text

                                Text {
                                    text: "Search..."
                                    color: root.walColor8
                                    visible: !parent.text
                                    opacity: 0.5
                                }

                                Keys.onEscapePressed: keybindsModule.keybindsVisible = false
                                Keys.onPressed: function(event) {
                                    if (event.modifiers & Qt.ControlModifier) {
                                        var itemCount = keybindsModule.filteredKeybinds.length
                                        var currentIndex = gridView.currentIndex < 0 ? 0 : gridView.currentIndex

                                        if (event.key === Qt.Key_J) {
                                            gridView.currentIndex = Math.min(currentIndex + 1, itemCount - 1)
                                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain)
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_K) {
                                            gridView.currentIndex = Math.max(currentIndex - 1, 0)
                                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain)
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_H) {
                                            gridView.contentX = Math.max(gridView.contentX - 300, 0)
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_L) {
                                            gridView.contentX = Math.min(gridView.contentX + 300, gridView.contentWidth - gridView.width)
                                            event.accepted = true
                                        }
                                    }
                                }

                                Component.onCompleted: forceActiveFocus()
                            }

                            Text {
                                visible: searchField.text
                                text: "✕"
                                color: root.walColor8
                                font.pixelSize: 14
                                opacity: clearMouse.containsMouse ? 1 : 0.6

                                MouseArea {
                                    id: clearMouse
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: searchField.text = ""
                                }
                            }
                        }
                    }

                    // Grid
                    GridView {
                        id: gridView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: keybindsModule.filteredKeybinds
                        cellWidth: Math.max(300, Math.floor(width / 2) - 4)
                        cellHeight: 60
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            width: gridView.cellWidth - 4
                            height: gridView.cellHeight - 4
                            radius: 8
                            color: delegateMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            border.width: 1
                            border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2)
                            Behavior on color { ColorAnimation { duration: 100 } }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text {
                                    text: modelData.keys
                                    color: root.walColor5
                                    font.pixelSize: 12
                                    font.family: "Monospace"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.description
                                    color: root.walForeground
                                    font.pixelSize: 10
                                    font.family: root.fontFamily
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                id: delegateMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            active: true
                            width: 5
                            policy: ScrollBar.AsNeeded
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "No keybindings found"
                            color: root.walColor8
                            font.pixelSize: 13
                            font.family: root.fontFamily
                            visible: keybindsModule.filteredKeybinds.length === 0
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: keybindsModule.keybindsVisible = false
}
