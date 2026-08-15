import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

PopupWindow {
    id: launcherPanel

    property var targetScreen: null
    property var fallbackWindow: null
    property bool barVisible: true
    property string barPosition: "bottom"
    property var anchorInfo: targetScreen ? root.launcherAnchors[targetScreen.name] || null : null
    property var anchorItem: anchorInfo ? anchorInfo.item : null
    property var anchorWindow: anchorInfo ? anchorInfo.window : null
    property bool usingBarAnchor: barVisible && anchorItem !== null && anchorWindow !== null
    property bool topAnchored: usingBarAnchor && anchorInfo ? anchorInfo.top : barPosition === "top"
    property bool shouldShow: launcherModule.launcherVisible && targetScreen !== null && launcherModule.activeLauncherScreen === targetScreen.name && (usingBarAnchor || (!barVisible && fallbackWindow !== null))

    function focusSearchInput() {
        if (!launcherPanel.shouldShow)
            return ;

        searchInput.forceActiveFocus();
    }

    function openLauncher() {
        focusGrab.active = true;
        searchInput.text = "";
        launcherModule.searchTerm = "";
        launcherModule.selectedIndex = 0;
        appList.positionViewAtBeginning();
        launcherModule.refreshLauncher();
        focusSearchInput();
        Qt.callLater(focusSearchInput);
        focusTimer.restart();
    }

    function closeLauncher() {
        if (focusGrab.active)
            focusGrab.active = false;

        if (launcherModule.launcherVisible)
            launcherModule.launcherVisible = false;

    }

    function updateAnchorRect() {
        if (usingBarAnchor) {
            var itemRect = anchorWindow.itemRect(anchorItem);
            anchor.rect.x = itemRect.x;
            anchor.rect.y = itemRect.y;
            anchor.rect.width = Math.max(1, itemRect.width);
            anchor.rect.height = Math.max(1, itemRect.height);
        } else if (fallbackWindow) {
            anchor.rect.x = Math.max(0, Math.round((fallbackWindow.width - implicitWidth) / 2));
            anchor.rect.y = topAnchored ? 0 : Math.max(0, fallbackWindow.height - implicitHeight - 1);
            anchor.rect.width = 1;
            anchor.rect.height = 1;
        }
    }

    visible: shouldShow
    grabFocus: shouldShow
    onShouldShowChanged: {
        if (!shouldShow) {
            if (visible || focusGrab.active)
                closeLauncher();

            return ;
        }
        if (!usingBarAnchor)
            updateAnchorRect();

        openLauncher();
    }
    onBarVisibleChanged: {
        if (shouldShow)
            updateAnchorRect();

    }
    onVisibleChanged: {
        if (visible) {
            Qt.callLater(focusSearchInput);
            focusTimer.restart();
        }
    }
    onClosed: closeLauncher()
    color: "transparent"
    implicitWidth: 360
    implicitHeight: 380
    anchor.window: shouldShow ? (usingBarAnchor ? anchorWindow : fallbackWindow) : null
    anchor.edges: topAnchored ? Edges.Bottom | Edges.Left : Edges.Top | Edges.Left
    anchor.gravity: topAnchored ? Edges.Bottom | Edges.Left : Edges.Top | Edges.Left

    HyprlandFocusGrab {
        id: focusGrab

        windows: [launcherPanel]
        onCleared: {
            if (!root.screenshotActive)
                closeLauncher();

        }
    }

    Connections {
        function onScreenshotActiveChanged() {
            if (!root.screenshotActive && launcherPanel.shouldShow) {
                focusGrab.active = true;
                focusSearchInput();
                Qt.callLater(focusSearchInput);
            }
        }

        target: root
    }

    Rectangle {
        id: launcherCard

        radius: 19
        color: "#1a1a1a"
        border.color: "#333333"
        border.width: 1

        anchors {
            left: parent.left
            right: parent.right
            top: topAnchored ? parent.top : undefined
            bottom: topAnchored ? undefined : parent.bottom
            topMargin: topAnchored ? 8 : 0
            bottomMargin: topAnchored ? 0 : 8
        }

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Applications"
                    color: root.colFg
                    Layout.leftMargin: 5

                    font {
                        family: root.fontFamily
                        pixelSize: 12
                        weight: Font.Bold
                    }

                }

                Text {
                    text: (launcherModule.filteredApps.length === 0 ? 0 : launcherModule.selectedIndex + 1) + " / " + launcherModule.filteredApps.length
                    color: "#999999"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    Layout.rightMargin: 6

                    font {
                        family: root.fontFamily
                        pixelSize: 9
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: 8
                color: "#252525"
                border.color: searchInput.activeFocus ? "#666666" : "#333333"
                border.width: 1

                TextInput {
                    id: searchInput

                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.colFg
                    clip: true
                    focus: launcherPanel.shouldShow
                    cursorVisible: launcherPanel.shouldShow
                    onTextChanged: {
                        launcherModule.searchTerm = text.toLowerCase();
                        launcherModule.selectedIndex = 0;
                        appList.positionViewAtBeginning();
                    }
                    Keys.onPressed: function(event) {
                        var total = launcherModule.filteredApps.length;
                        if (event.key === Qt.Key_Down) {
                            if (total > 0)
                                launcherModule.selectedIndex = (launcherModule.selectedIndex + 1) % total;

                            appList.positionViewAtIndex(launcherModule.selectedIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            if (total > 0)
                                launcherModule.selectedIndex = launcherModule.selectedIndex <= 0 ? total - 1 : launcherModule.selectedIndex - 1;

                            appList.positionViewAtIndex(launcherModule.selectedIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (total > 0) {
                                closeLauncher();
                                launcherModule.launchApp(launcherModule.filteredApps[launcherModule.selectedIndex]);
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            closeLauncher();
                            event.accepted = true;
                        }
                    }

                    font {
                        family: root.fontFamily
                        pixelSize: 11
                    }

                    Text {
                        text: "search apps..."
                        color: "#777777"
                        font: searchInput.font
                        visible: searchInput.text.length === 0
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }

            ListView {
                id: appList

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 44
                clip: true
                spacing: 2
                model: launcherModule.filteredApps
                currentIndex: launcherModule.selectedIndex
                boundsBehavior: Flickable.StopAtBounds

                Text {
                    anchors.centerIn: parent
                    visible: appList.count === 0
                    text: "no apps found"
                    color: "#666666"

                    font {
                        family: root.fontFamily
                        pixelSize: 10
                    }

                }

                delegate: Rectangle {
                    width: appList.width
                    height: 44
                    radius: 9
                    color: index === launcherModule.selectedIndex ? "#262626" : rowMouse.containsMouse ? "#212121" : "transparent"
                    border.width: index === launcherModule.selectedIndex ? 1 : 0
                    border.color: "#795548"

                    Rectangle {
                        width: 2
                        radius: 5
                        color: root.colPurple
                        opacity: index === launcherModule.selectedIndex ? 1 : 0

                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: 7
                        }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 10

                        IconImage {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            Layout.alignment: Qt.AlignVCenter
                            source: Quickshell.iconPath(modelData.icon, true)
                            asynchronous: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.name
                                color: root.colFg
                                opacity: index === launcherModule.selectedIndex ? 1 : 0.9
                                elide: Text.ElideRight
                                Layout.fillWidth: true

                                font {
                                    family: root.fontFamily
                                    pixelSize: 11
                                    weight: index === launcherModule.selectedIndex ? Font.DemiBold : Font.Medium
                                }

                            }

                            Text {
                                text: modelData.comment
                                visible: text.length > 0
                                color: "#8d8d8d"
                                elide: Text.ElideRight
                                Layout.fillWidth: true

                                font {
                                    family: root.fontFamily
                                    pixelSize: 9
                                }

                            }

                        }

                    }

                    MouseArea {
                        id: rowMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: launcherModule.selectedIndex = index
                        onClicked: {
                            launcherModule.selectedIndex = index;
                            closeLauncher();
                            launcherModule.launchApp(modelData);
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

            }

        }

    }

    Timer {
        id: focusTimer

        interval: 50
        onTriggered: focusSearchInput()
    }

}
