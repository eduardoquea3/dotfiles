import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: launcherPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true }

    property bool isFocusedScreen: screen !== null && screen.name === launcherModule.activeLauncherScreen

    margins {
        top: 2
        bottom: root.barVisible ? 28 : 2
        left: (launcherModule.launcherVisible && isFocusedScreen) ? 2 : -450
    }
    implicitWidth: 420
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: (launcherModule.launcherVisible && isFocusedScreen) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    Behavior on margins.left { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 1.0)
        radius: 6
        border.width: 1
        border.color: Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.4)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Tab bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                color: Qt.rgba(0, 0, 0, 0.3)
                radius: 12
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    // Apps tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: launcherModule.activeTab === 0 ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "󰀻"
                                color: launcherModule.activeTab === 0 ? root.walColor5 : root.walColor8
                                font.pixelSize: 14
                                font.family: root.fontFamily
                            }
                            Text {
                                text: "Apps"
                                color: launcherModule.activeTab === 0 ? root.walColor5 : root.walColor8
                                font.pixelSize: 13
                                font.bold: launcherModule.activeTab === 0
                                font.family: root.fontFamily
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { launcherModule.activeTab = 0; searchInput.forceActiveFocus() }
                        }
                    }

                    // Wallpapers tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: launcherModule.activeTab === 1 ? Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.2) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "󰸉"
                                color: launcherModule.activeTab === 1 ? root.walColor13 : root.walColor8
                                font.pixelSize: 14
                                font.family: root.fontFamily
                            }
                            Text {
                                text: "Walls"
                                color: launcherModule.activeTab === 1 ? root.walColor13 : root.walColor8
                                font.pixelSize: 13
                                font.bold: launcherModule.activeTab === 1
                                font.family: root.fontFamily
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                launcherModule.activeTab = 1
                                if (!launcherModule.wallsLoaded) launcherModule.loadWallpapers()
                                wallSearchInput.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            // Content area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // ─── Apps Tab ───────────────────────────────────────────────
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                    visible: launcherModule.activeTab === 0
                    opacity: launcherModule.activeTab === 0 ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    // Search
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 12
                        border.width: searchInput.activeFocus ? 1 : 0
                        border.color: root.walColor5
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10
                            Text {
                                text: ""
                                color: root.walColor8
                                font.pixelSize: 14
                                font.family: root.fontFamily
                            }
                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: root.walForeground
                                font.pixelSize: 14
                                font.family: root.fontFamily
                                verticalAlignment: TextInput.AlignVCenter
                                selectByMouse: true
                                clip: true
                                Text {
                                    text: "Search apps..."
                                    color: root.walColor8
                                    visible: !parent.text
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    font: parent.font
                                    opacity: 0.6
                                }
                                onTextChanged: {
                                    launcherModule.searchTerm = text.toLowerCase()
                                    launcherModule.selectedIndex = 0
                                    appListView.contentY = 0
                                }
                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Down) {
                                        launcherModule.selectedIndex = Math.min(launcherModule.selectedIndex + 1, launcherModule.filteredApps.length - 1)
                                        appListView.positionViewAtIndex(launcherModule.selectedIndex, ListView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        launcherModule.selectedIndex = Math.max(launcherModule.selectedIndex - 1, 0)
                                        appListView.positionViewAtIndex(launcherModule.selectedIndex, ListView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (launcherModule.filteredApps.length > 0)
                                            launcherModule.launchApp(launcherModule.filteredApps[launcherModule.selectedIndex])
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Escape) {
                                        launcherModule.launcherVisible = false
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Tab) {
                                        launcherModule.activeTab = 1
                                        if (!launcherModule.wallsLoaded) launcherModule.loadWallpapers()
                                        wallSearchInput.forceActiveFocus()
                                        event.accepted = true
                                    }
                                }
                            }
                            Text {
                                visible: searchInput.text.length > 0
                                text: "󰅖"
                                color: root.walColor8
                                font.pixelSize: 12
                                font.family: root.fontFamily
                                opacity: clearAppMouse.containsMouse ? 1.0 : 0.7
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                MouseArea {
                                    id: clearAppMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { searchInput.text = ""; searchInput.forceActiveFocus() }
                                }
                            }
                        }
                    }

                    // App list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 15
                        clip: true

                        ListView {
                            id: appListView
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4
                            boundsBehavior: Flickable.StopAtBounds
                            currentIndex: launcherModule.selectedIndex
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 100
                            model: launcherModule.filteredApps

                            property real targetContentY: 0
                            property bool animatingScroll: false

                            NumberAnimation {
                                id: appScrollAnim
                                target: appListView
                                property: "contentY"
                                duration: 300
                                easing.type: Easing.OutCubic
                                onFinished: appListView.animatingScroll = false
                            }

                            function smoothScrollTo(newY) {
                                var maxY = Math.max(0, contentHeight - height)
                                newY = Math.max(0, Math.min(newY, maxY))
                                if (animatingScroll) appScrollAnim.stop()
                                animatingScroll = true
                                appScrollAnim.from = contentY
                                appScrollAnim.to = newY
                                targetContentY = newY
                                appScrollAnim.start()
                            }

                            function smoothScrollBy(delta) {
                                smoothScrollTo((animatingScroll ? targetContentY : contentY) + delta)
                            }

                            MouseArea {
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onWheel: function(wheel) { appListView.smoothScrollBy(-wheel.angleDelta.y / 120.0 * 60) }
                                onClicked: function(mouse) { mouse.accepted = false }
                                onPressed: function(mouse) { mouse.accepted = false }
                                onReleased: function(mouse) { mouse.accepted = false }
                            }

                            delegate: Rectangle {
                                width: appListView.width
                                height: 48
                                radius: 12
                                color: {
                                    if (index === launcherModule.selectedIndex)
                                        return Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2)
                                    if (appItemMouse.containsMouse)
                                        return Qt.rgba(1, 1, 1, 0.05)
                                    return "transparent"
                                }
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Rectangle {
                                    visible: index === launcherModule.selectedIndex
                                    width: 3; height: 22; radius: 2
                                    color: root.walColor5
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    anchors.topMargin: 6
                                    anchors.bottomMargin: 6
                                    spacing: 12

                                    Rectangle {
                                        width: 32; height: 32; radius: 8
                                        color: Qt.rgba(0, 0, 0, 0.2)
                                        Image {
                                            id: appIcon
                                            anchors.centerIn: parent
                                            width: 22; height: 22
                                            source: {
                                                var icon = modelData.icon
                                                if (!icon || icon === "") return ""
                                                if (icon.indexOf("/") === 0) return "file://" + icon
                                                return "image://icon/" + icon
                                            }
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            cache: true
                                            visible: status === Image.Ready
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            visible: appIcon.status !== Image.Ready
                                            text: "󰏠"
                                            color: root.walColor8
                                            font.pixelSize: 16
                                            font.family: root.fontFamily
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: index === launcherModule.selectedIndex ? root.walColor5 : root.walForeground
                                            font.pixelSize: 13
                                            font.family: root.fontFamily
                                            font.bold: index === launcherModule.selectedIndex
                                            elide: Text.ElideRight
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.exec
                                            color: root.walColor8
                                            font.pixelSize: 9
                                            font.family: root.fontFamily
                                            elide: Text.ElideRight
                                            opacity: 0.7
                                        }
                                    }

                                    Text {
                                        visible: index === launcherModule.selectedIndex
                                        text: "↵"
                                        color: root.walColor5
                                        font.pixelSize: 14
                                        font.family: root.fontFamily
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: appItemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: launcherModule.launchApp(modelData)
                                    onContainsMouseChanged: { if (containsMouse) launcherModule.selectedIndex = index }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true; width: 4
                                policy: ScrollBar.AsNeeded
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: launcherModule.filteredApps.length === 0
                            text: "No apps found"
                            color: root.walColor8
                            font.pixelSize: 14
                            font.family: root.fontFamily
                        }
                    }

                    // Help bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 10
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            Text { text: "↑↓ nav"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "↵ launch"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "tab walls"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "esc close"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                        }
                    }
                }

                // ─── Wallpapers Tab ─────────────────────────────────────────
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                    visible: launcherModule.activeTab === 1
                    opacity: launcherModule.activeTab === 1 ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    // Search
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 12
                        border.width: wallSearchInput.activeFocus ? 1 : 0
                        border.color: root.walColor13
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10
                            Text {
                                text: ""
                                color: root.walColor8
                                font.pixelSize: 14
                                font.family: root.fontFamily
                            }
                            TextInput {
                                id: wallSearchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: root.walForeground
                                font.pixelSize: 14
                                font.family: root.fontFamily
                                verticalAlignment: TextInput.AlignVCenter
                                selectByMouse: true
                                clip: true
                                Text {
                                    text: "Search wallpapers..."
                                    color: root.walColor8
                                    visible: !parent.text
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    font: parent.font
                                    opacity: 0.6
                                }
                                onTextChanged: {
                                    launcherModule.wallSearchTerm = text.toLowerCase()
                                    launcherModule.wallSelectedIndex = 0
                                    wallGridView.contentY = 0
                                }
                                Keys.onPressed: function(event) {
                                    var cols = 3
                                    var total = launcherModule.filteredWallpapers.length
                                    if (event.key === Qt.Key_Right) {
                                        launcherModule.wallSelectedIndex = Math.min(launcherModule.wallSelectedIndex + 1, total - 1)
                                        wallGridView.positionViewAtIndex(launcherModule.wallSelectedIndex, GridView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Left) {
                                        launcherModule.wallSelectedIndex = Math.max(launcherModule.wallSelectedIndex - 1, 0)
                                        wallGridView.positionViewAtIndex(launcherModule.wallSelectedIndex, GridView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down) {
                                        launcherModule.wallSelectedIndex = Math.min(launcherModule.wallSelectedIndex + cols, total - 1)
                                        wallGridView.positionViewAtIndex(launcherModule.wallSelectedIndex, GridView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        launcherModule.wallSelectedIndex = Math.max(launcherModule.wallSelectedIndex - cols, 0)
                                        wallGridView.positionViewAtIndex(launcherModule.wallSelectedIndex, GridView.Contain)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (total > 0)
                                            launcherModule.applyWallpaper(launcherModule.filteredWallpapers[launcherModule.wallSelectedIndex])
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Escape) {
                                        launcherModule.launcherVisible = false
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Tab) {
                                        launcherModule.activeTab = 0
                                        searchInput.forceActiveFocus()
                                        event.accepted = true
                                    }
                                }
                            }
                            Text {
                                visible: wallSearchInput.text.length > 0
                                text: "󰅖"
                                color: root.walColor8
                                font.pixelSize: 12
                                font.family: root.fontFamily
                                opacity: clearWallMouse.containsMouse ? 1.0 : 0.7
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                MouseArea {
                                    id: clearWallMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { wallSearchInput.text = ""; wallSearchInput.forceActiveFocus() }
                                }
                            }
                        }
                    }

                    // Wallpaper grid
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 15
                        clip: true

                        GridView {
                            id: wallGridView
                            anchors.fill: parent
                            anchors.margins: 10
                            cellWidth: Math.floor(width / 3)
                            cellHeight: cellWidth * 0.65 + 30
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true
                            cacheBuffer: 400
                            model: launcherModule.filteredWallpapers

                            property real targetContentY: 0
                            property bool animatingScroll: false

                            NumberAnimation {
                                id: wallScrollAnim
                                target: wallGridView
                                property: "contentY"
                                duration: 300
                                easing.type: Easing.OutCubic
                                onFinished: wallGridView.animatingScroll = false
                            }

                            function smoothScrollTo(newY) {
                                var maxY = Math.max(0, contentHeight - height)
                                newY = Math.max(0, Math.min(newY, maxY))
                                if (animatingScroll) wallScrollAnim.stop()
                                animatingScroll = true
                                wallScrollAnim.from = contentY
                                wallScrollAnim.to = newY
                                targetContentY = newY
                                wallScrollAnim.start()
                            }

                            function smoothScrollBy(delta) {
                                smoothScrollTo((animatingScroll ? targetContentY : contentY) + delta)
                            }

                            MouseArea {
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onWheel: function(wheel) { wallGridView.smoothScrollBy(-wheel.angleDelta.y / 120.0 * (wallGridView.cellHeight * 0.6)) }
                                onClicked: function(mouse) { mouse.accepted = false }
                                onPressed: function(mouse) { mouse.accepted = false }
                                onReleased: function(mouse) { mouse.accepted = false }
                            }

                            delegate: Item {
                                width: wallGridView.cellWidth
                                height: wallGridView.cellHeight
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    radius: 10
                                    color: {
                                        if (index === launcherModule.wallSelectedIndex)
                                            return Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.25)
                                        if (wallItemMouse.containsMouse)
                                            return Qt.rgba(1, 1, 1, 0.08)
                                        return Qt.rgba(0, 0, 0, 0.2)
                                    }
                                    border.width: {
                                        if (modelData.path === launcherModule.currentWallpaper) return 2
                                        if (index === launcherModule.wallSelectedIndex) return 1
                                        return 0
                                    }
                                    border.color: modelData.path === launcherModule.currentWallpaper ? root.walColor2 : root.walColor13
                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        spacing: 2

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 7
                                                color: Qt.rgba(0.3, 0.3, 0.3, 0.3)
                                                visible: wallThumbImage.status !== Image.Ready
                                            }

                                            Image {
                                                id: wallThumbImage
                                                anchors.fill: parent
                                                property string thumbHash: (launcherModule.wallpaperHashes && launcherModule.wallpaperHashes[modelData.path]) ? launcherModule.wallpaperHashes[modelData.path] : ""
                                                source: thumbHash ? "file://" + launcherModule.cachePath + "/wallpaper-thumbs/" + thumbHash + ".jpg" : ""
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: false
                                                asynchronous: true
                                                cache: true
                                                sourceSize.width: 180
                                                sourceSize.height: 120
                                                visible: false
                                                onStatusChanged: {
                                                    if (status === Image.Error && modelData.path)
                                                        source = "file://" + modelData.path
                                                }
                                            }

                                            Rectangle {
                                                id: wallThumbMaskRect
                                                anchors.fill: parent
                                                radius: 7
                                                visible: false
                                            }

                                            OpacityMask {
                                                anchors.fill: parent
                                                source: wallThumbImage
                                                maskSource: wallThumbMaskRect
                                            }

                                            Rectangle {
                                                visible: modelData.path === launcherModule.currentWallpaper
                                                anchors.top: parent.top
                                                anchors.right: parent.right
                                                anchors.margins: 3
                                                width: 16; height: 16; radius: 8
                                                color: root.walColor2
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "󰄬"
                                                    color: root.walBackground
                                                    font.pixelSize: 10
                                                    font.family: root.fontFamily
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 22
                                            text: modelData.name
                                            color: {
                                                if (modelData.path === launcherModule.currentWallpaper) return root.walColor2
                                                if (index === launcherModule.wallSelectedIndex) return root.walColor13
                                                return root.walForeground
                                            }
                                            font.pixelSize: 8
                                            font.family: root.fontFamily
                                            font.bold: index === launcherModule.wallSelectedIndex || modelData.path === launcherModule.currentWallpaper
                                            elide: Text.ElideMiddle
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }
                                    }

                                    MouseArea {
                                        id: wallItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: launcherModule.applyWallpaper(modelData)
                                        onContainsMouseChanged: { if (containsMouse) launcherModule.wallSelectedIndex = index }
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true; width: 4
                                policy: ScrollBar.AsNeeded
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: launcherModule.wallsLoaded && launcherModule.filteredWallpapers.length === 0
                            text: "No wallpapers found"
                            color: root.walColor8
                            font.pixelSize: 14
                            font.family: root.fontFamily
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: !launcherModule.wallsLoaded && launcherModule.wallpaperList.length === 0
                            text: "Loading..."
                            color: root.walColor8
                            font.pixelSize: 13
                            font.family: root.fontFamily
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.4; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 1.0; to: 0.4; duration: 600; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    // Help bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 10
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            Text { text: "←→↑↓ nav"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "↵ apply"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "tab apps"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                            Item { Layout.fillWidth: true }
                            Text { text: "esc close"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                        }
                    }
                }
            }
        }
    }

    // Reset state when launcher opens/closes
    Connections {
        target: launcherModule
        function onLauncherVisibleChanged() {
            if (launcherModule.launcherVisible) {
                searchInput.text = ""
                wallSearchInput.text = ""
                launcherModule.searchTerm = ""
                launcherModule.selectedIndex = 0
                launcherModule.wallSelectedIndex = 0
                appListView.contentY = 0
                wallGridView.contentY = 0
                launcherModule.refreshLauncher()
                focusDelayTimer.start()
            } else {
                searchInput.text = ""
                wallSearchInput.text = ""
                launcherModule.searchTerm = ""
                launcherModule.wallSearchTerm = ""
                searchInput.focus = false
                wallSearchInput.focus = false
            }
        }
        function onWallSelectedIndexChanged() {
            if (launcherModule.activeTab === 1)
                wallGridView.positionViewAtIndex(launcherModule.wallSelectedIndex, GridView.Contain)
        }
    }

    Timer {
        id: focusDelayTimer
        interval: 50
        repeat: false
        onTriggered: exclusiveReleaseTimer.start()
    }

    Timer {
        id: exclusiveReleaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (launcherModule.activeTab === 0)
                searchInput.forceActiveFocus()
            else {
                if (!launcherModule.wallsLoaded) launcherModule.loadWallpapers()
                wallSearchInput.forceActiveFocus()
            }
        }
    }
}
