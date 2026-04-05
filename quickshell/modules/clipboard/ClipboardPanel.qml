import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: clipboardPanel
    visible: shouldShow || hideTimer.running
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    focusable: true

    property bool isFocusedScreen: screen !== null && screen.name === clipboardModule.activeClipboardScreen
    property bool shouldShow: clipboardModule.clipboardVisible && isFocusedScreen

    onShouldShowChanged: { if (!shouldShow) hideTimer.start() }

    Timer {
        id: hideTimer
        interval: 260
        running: false
    }

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [clipboardPanel]
        active: clipboardPanel.shouldShow
    }

    // ─── Full-screen blur overlay ─────────────────────────────────────────────
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.60)
        opacity: clipboardPanel.shouldShow ? 1 : 0
        enabled: clipboardPanel.shouldShow
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            enabled: clipboardPanel.shouldShow
            onClicked: clipboardModule.clipboardVisible = false
        }

        // ─── Centered clipboard card ──────────────────────────────────────────
        Item {
            id: contentPanel
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.88, 1000)
            height: Math.min(parent.height * 0.86, 740)

            opacity: clipboardPanel.shouldShow ? 1 : 0
            scale: clipboardPanel.shouldShow ? 1.0 : 0.96
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.94)
                radius: 16
                border.width: 1
                border.color: Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.35)

                // Absorb clicks so they don't reach the close MouseArea
                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    // ─── Header with icon ─────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        spacing: 12

                        Text {
                            text: "󰅇"
                            color: root.walColor5
                            font.pixelSize: 20
                            font.family: root.fontFamily
                        }

                        Text {
                            text: "Clipboard"
                            color: root.walForeground
                            font.pixelSize: 16
                            font.bold: true
                            font.family: root.fontFamily
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            visible: clipboardModule.clipboardHistory.length > 0
                            text: (clipboardModule.selectedIndex + 1) + "/" + clipboardModule.clipboardHistory.length
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: root.fontFamily
                            opacity: 0.6
                        }
                    }

                    // ─── Search bar ───────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 12
                        border.width: searchInput.activeFocus ? 1 : 0
                        border.color: root.walColor5
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16; anchors.rightMargin: 16
                            spacing: 10
                            Text { text: ""; color: root.walColor8; font.pixelSize: 16; font.family: root.fontFamily }
                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: root.walForeground
                                font.pixelSize: 15; font.family: root.fontFamily
                                verticalAlignment: TextInput.AlignVCenter
                                selectByMouse: true; clip: true
                                Text {
                                    text: "Search clipboard..."
                                    color: root.walColor8; visible: !parent.text
                                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                    font: parent.font; opacity: 0.6
                                }
                                onTextChanged: {
                                    clipboardModule.searchTerm = text
                                    clipboardModule.selectedIndex = 0
                                    clipGrid.contentY = 0
                                }
                                Keys.priority: Keys.BeforeItem
                                Keys.onPressed: function(event) {
                                    var total = clipboardModule.filteredClips.length
                                    if (event.key === Qt.Key_Down || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_J)) {
                                        clipboardModule.selectedIndex = (clipboardModule.selectedIndex + 1) % total
                                        clipGrid.positionViewAtIndex(clipboardModule.selectedIndex, ListView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_K)) {
                                        clipboardModule.selectedIndex = (clipboardModule.selectedIndex - 1 + total) % total
                                        clipGrid.positionViewAtIndex(clipboardModule.selectedIndex, ListView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (total > 0)
                                            clipboardModule.copyToClipboard(clipboardModule.filteredClips[clipboardModule.selectedIndex].text)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Escape) {
                                        clipboardModule.clipboardVisible = false
                                        event.accepted = true
                                    }
                                }
                            }
                            Text {
                                visible: searchInput.text.length > 0
                                text: "󰅖"; color: root.walColor8; font.pixelSize: 12; font.family: root.fontFamily
                                opacity: clearMouse.containsMouse ? 1.0 : 0.7
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                MouseArea {
                                    id: clearMouse; anchors.fill: parent; anchors.margins: -4
                                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { searchInput.text = ""; searchInput.forceActiveFocus() }
                                }
                            }
                        }
                    }

                    // ─── Clipboard list ───────────────────────────────────────
                    ListView {
                        id: clipGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: clipboardModule.filteredClips
                        cacheBuffer: 400
                        spacing: 8

                        delegate: Rectangle {
                            width: clipGrid.width
                            height: 52
                            radius: 10
                            color: {
                                if (index === clipboardModule.selectedIndex)
                                    return Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.18)
                                if (clipItemMouse.containsMouse)
                                    return Qt.rgba(1, 1, 1, 0.07)
                                return "transparent"
                            }
                            border.width: index === clipboardModule.selectedIndex ? 1 : 0
                            border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.5)
                            Behavior on color { ColorAnimation { duration: 120 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12; anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    text: (index + 1).toString().padStart(2, '0')
                                    color: index === clipboardModule.selectedIndex ? root.walColor5 : root.walColor8
                                    font.pixelSize: 11; font.family: root.fontFamily
                                    opacity: 0.6
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.display
                                    color: index === clipboardModule.selectedIndex ? root.walColor5 : root.walForeground
                                    font.pixelSize: 13; font.family: root.fontFamily
                                    elide: Text.ElideRight
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                Text {
                                    text: "󰆒"
                                    color: root.walColor8
                                    font.pixelSize: 12; font.family: root.fontFamily
                                    opacity: clipItemMouse.containsMouse ? 0.8 : 0.4
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }

                            MouseArea {
                                id: clipItemMouse; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: clipboardModule.copyToClipboard(modelData.text)
                                onContainsMouseChanged: { if (containsMouse) clipboardModule.selectedIndex = index }
                            }
                        }

                        ScrollBar.vertical: ScrollBar { active: true; width: 4; policy: ScrollBar.AsNeeded }

                        Text {
                            anchors.centerIn: parent
                            visible: clipboardModule.clipboardHistory.length === 0
                            text: "No clipboard history"; color: root.walColor8
                            font.pixelSize: 14; font.family: root.fontFamily
                        }
                    }

                    // ─── Help bar ─────────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 28
                        color: Qt.rgba(0, 0, 0, 0.25); radius: 10
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                            Text { text: "↑↓/^k^j nav";  color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "↵ copy";  color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "esc close"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                        }
                    }
                }
            }
        }
    }

    // ─── State reset ──────────────────────────────────────────────────────────
    Connections {
        target: clipboardModule
        function onClipboardVisibleChanged() {
            if (clipboardModule.clipboardVisible) {
                searchInput.text = ""
                clipboardModule.searchTerm = ""
                clipboardModule.selectedIndex = 0
                clipGrid.contentY = 0
                clipboardModule.refreshClipboard()
                focusDelayTimer.start()
            } else {
                searchInput.text = ""
                clipboardModule.searchTerm = ""
                searchInput.focus = false
            }
        }
    }

    Timer {
        id: focusDelayTimer; interval: 50; repeat: false
        onTriggered: exclusiveReleaseTimer.start()
    }

    Timer {
        id: exclusiveReleaseTimer; interval: 100; repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }
}
