import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: clipboardWindow

    // Configuration
    property string scriptPath: "$HOME/.config/quickshell/scripts/cliphist-visual.sh"

    // Theme references (Kanagawa)
    readonly property color colBg: root.colBg
    readonly property color colFg: root.colFg
    readonly property color colBorder: root.colBorder
    readonly property color colBlue: root.colBlue
    readonly property color colRed: root.colRed
    readonly property string fontFamily: root.fontFamily

    implicitWidth: 600
    implicitHeight: 750
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clipboard_overlay"
    exclusiveZone: -1

    anchors {
        bottom: true
    }

    margins {
        bottom: 100
    }

    property var allItems: []
    property var filteredItems: []

    HyprlandFocusGrab {
        id: focusGrab
        windows: [clipboardWindow]
        onCleared: closeMenu()
    }

    function closeMenu() {
        clipboardWindow.visible = false;
        focusGrab.active = false;
    }

    function updateSearch() {
        if (searchField.text.trim() === "") {
            clipboardWindow.filteredItems = clipboardWindow.allItems;
            listView.currentIndex = 0;
            return;
        }
        let query = searchField.text.toLowerCase();
        clipboardWindow.filteredItems = clipboardWindow.allItems.filter(item => {
            let str = item.display.toLowerCase();
            let i = 0, j = 0;
            while (i < str.length && j < query.length) {
                if (str[i] === query[j])
                    j++;
                i++;
            }
            return j === query.length;
        });
        listView.currentIndex = 0;
    }

    Process {
        id: fetchHistory
        command: ["bash", "-c", clipboardWindow.scriptPath]
        stdout: StdioCollector {
            onStreamFinished: {
                clipboardWindow.allItems = this.text.split('\n').filter(line => line.trim() !== "").map(line => {
                    let parts = line.split('\t');
                    let id = parts[0];
                    let display = parts[1] || "";
                    let imagePath = parts[2] || "";

                    return {
                        raw: id + '\t' + display,
                        display: display,
                        imagePath: imagePath
                    };
                });
                updateSearch();
            }
        }
    }

    Process {
        id: copyToClipboard
        property string selectedItem: ""
        command: ["bash", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "_", selectedItem]
        onRunningChanged: {
            if (!running && copyToClipboard.selectedItem !== "") {
                closeMenu();
                copyToClipboard.selectedItem = "";
            }
        }
    }

    Process {
        id: deleteEntry
        property string targetRaw: ""
        property string targetId: ""
        command: ["bash", "-c", 'printf "%s" "$1" | cliphist delete && rm -f /tmp/cliphist/"$2".*', "_", targetRaw, targetId]
        onRunningChanged: {
            if (!running && targetRaw !== "") {
                targetRaw = "";
                targetId = "";
                fetchHistory.running = true;
            }
        }
    }

    Process {
        id: clearHistory
        command: ["sh", "-c", "cliphist wipe && rm -rf /tmp/cliphist/*"]
        onRunningChanged: {
            if (!running) {
                clipboardWindow.allItems = [];
                updateSearch();
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle() {
            if (clipboardWindow.visible) {
                closeMenu();
            } else {
                fetchHistory.running = true;
                searchField.text = "";
                clipboardWindow.visible = true;
                focusGrab.active = true;
                searchField.forceActiveFocus();
            }
        }
    }

    Item {
        id: delegateContainer
        anchors.fill: parent
        anchors.margins: 30

        DropShadow {
            anchors.fill: mainUi
            source: mainUi
            radius: 24
            samples: 32
            color: "#80000000"
            verticalOffset: 8
        }

        Rectangle {
            id: mainUi
            anchors.fill: parent
            color: Qt.rgba(clipboardWindow.colBg.r, clipboardWindow.colBg.g, clipboardWindow.colBg.b, 0.94)
            radius: 28
            border.width: 1
            border.color: clipboardWindow.colBorder
            clip: true
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_H) {
                    closeMenu();
                } else if (event.key === Qt.Key_X || event.key === Qt.Key_Delete) {
                    if (listView.currentItem) {
                        listView.currentItem.remove();
                    }
                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                    listView.incrementCurrentIndex();
                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                    listView.decrementCurrentIndex();
                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return || event.key === Qt.Key_L) {
                    if (listView.currentItem)
                        listView.currentItem.select();
                } else if (event.key === Qt.Key_Slash) {
                    searchField.forceActiveFocus();
                    event.accepted = true;
                }
                event.accepted = true;
            }

            // Header
            Item {
                id: headerArea
                width: parent.width
                height: 72
                anchors.top: parent.top
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Clipboard"
                    color: clipboardWindow.colFg
                    font {
                        family: clipboardWindow.fontFamily
                        pixelSize: 26
                    }
                }
                Rectangle {
                    id: clearButton
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    width: clearText.implicitWidth + 32
                    height: 36
                    radius: 18
                    scale: clearMouseArea.pressed ? 0.92 : (clearMouseArea.containsMouse ? 1.05 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }
                    color: clearMouseArea.containsMouse ? clipboardWindow.colRed : "transparent"
                    border.width: 1
                    border.color: clearMouseArea.containsMouse ? clipboardWindow.colRed : clipboardWindow.colBorder
                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "Clear"
                        color: clearMouseArea.containsMouse ? "#ffffff" : clipboardWindow.colBorder
                        font {
                            family: clipboardWindow.fontFamily
                            pixelSize: 16
                        }
                    }
                    MouseArea {
                        id: clearMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clearHistory.running = true
                    }
                }
            }

            Item {
                id: searchArea
                width: parent.width
                height: 80
                anchors.top: headerArea.bottom

                TextField {
                    id: searchField
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    leftPadding: 48
                    rightPadding: searchField.text !== "" ? 48 : 16

                    font.family: clipboardWindow.fontFamily
                    font.pixelSize: 17
                    color: clipboardWindow.colFg
                    selectionColor: Qt.rgba(clipboardWindow.colBlue.r, clipboardWindow.colBlue.g, clipboardWindow.colBlue.b, 0.3)
                    selectedTextColor: clipboardWindow.colFg

                    placeholderText: ""
                    placeholderTextColor: "transparent"

                    background: Rectangle {
                        id: searchBg
                        color: searchField.activeFocus ? Qt.lighter(clipboardWindow.colBg, 1.15) : Qt.lighter(clipboardWindow.colBg, 1.08)
                        radius: 28

                        border.width: searchField.activeFocus ? 2 : 0
                        border.color: clipboardWindow.colBorder

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        // Search icon - only visible when field is empty
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            color: searchField.activeFocus ? clipboardWindow.colBlue : clipboardWindow.colBorder
                            visible: searchField.text === "" && !searchField.activeFocus
                        }

                        // Placeholder text - only visible when field is empty and not focused
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 48
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Search clipboard..."
                            font.family: clipboardWindow.fontFamily
                            font.pixelSize: 17
                            color: clipboardWindow.colBorder
                            visible: searchField.text === "" && !searchField.activeFocus
                        }
                    }

                    onTextChanged: updateSearch()

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down) {
                            listView.incrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            listView.decrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            if (listView.currentItem)
                                listView.currentItem.select();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Delete) {
                            if (listView.currentItem)
                                listView.currentItem.remove();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            closeMenu();
                            event.accepted = true;
                        }
                    }
                }
            }

            Item {
                id: listContainer
                anchors.top: searchArea.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: LinearGradient {
                        width: listContainer.width
                        height: listContainer.height
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "black"
                            }
                            GradientStop {
                                position: 0.85
                                color: "black"
                            }
                            GradientStop {
                                position: 1.0
                                color: "transparent"
                            }
                        }
                    }
                }

                ListView {
                    id: listView
                    anchors.fill: parent
                    topMargin: 12
                    bottomMargin: 24

                    model: clipboardWindow.filteredItems
                    spacing: 8
                    clip: false
                    highlightMoveDuration: 80
                    highlightFollowsCurrentItem: true

                    delegate: ClipboardDelegate {}
                }
            }

            Text {
                id: emptyMessage
                anchors.centerIn: listContainer
                text: clipboardWindow.allItems.length === 0 ? "Clipboard is empty :(" : "No results found :/"
                visible: clipboardWindow.filteredItems.length === 0
                color: clipboardWindow.colBorder
                font.family: clipboardWindow.fontFamily
                font.pixelSize: 18
            }
        }
    }
}
