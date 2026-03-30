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
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    focusable: true

    property bool isFocusedScreen: screen !== null && screen.name === launcherModule.activeLauncherScreen
    property bool shouldShow: launcherModule.launcherVisible && isFocusedScreen

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // ─── Full-screen blur overlay ─────────────────────────────────────────────
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.60)
        opacity: launcherPanel.shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            enabled: launcherPanel.shouldShow
            onClicked: launcherModule.launcherVisible = false
        }

        // ─── Centered launcher card ───────────────────────────────────────────
        Item {
            id: contentPanel
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.88, 1000)
            height: Math.min(parent.height * 0.86, 740)

            opacity: launcherPanel.shouldShow ? 1 : 0
            scale: launcherPanel.shouldShow ? 1.0 : 0.96
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

                    // ─── Tab bar ──────────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: Qt.rgba(0, 0, 0, 0.25)
                        radius: 12
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                radius: 8
                                color: launcherModule.activeTab === 0
                                    ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2)
                                    : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                RowLayout {
                                    anchors.centerIn: parent; spacing: 6
                                    Text { text: "󰀻"; color: launcherModule.activeTab === 0 ? root.walColor5 : root.walColor8; font.pixelSize: 14; font.family: root.fontFamily }
                                    Text { text: "Apps"; color: launcherModule.activeTab === 0 ? root.walColor5 : root.walColor8; font.pixelSize: 13; font.bold: launcherModule.activeTab === 0; font.family: root.fontFamily }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { launcherModule.activeTab = 0; searchInput.forceActiveFocus() } }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                radius: 8
                                color: launcherModule.activeTab === 1
                                    ? Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.2)
                                    : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                RowLayout {
                                    anchors.centerIn: parent; spacing: 6
                                    Text { text: "󰸉"; color: launcherModule.activeTab === 1 ? root.walColor13 : root.walColor8; font.pixelSize: 14; font.family: root.fontFamily }
                                    Text { text: "Walls"; color: launcherModule.activeTab === 1 ? root.walColor13 : root.walColor8; font.pixelSize: 13; font.bold: launcherModule.activeTab === 1; font.family: root.fontFamily }
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { launcherModule.activeTab = 1; if (!launcherModule.wallsLoaded) launcherModule.loadWallpapers(); wallSearchInput.forceActiveFocus() }
                                }
                            }
                        }
                    }

                    // ─── Content area ─────────────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // ── Apps Tab ──────────────────────────────────────────
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 14
                            visible: launcherModule.activeTab === 0
                            opacity: launcherModule.activeTab === 0 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            // Search bar
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
                                            text: "Search apps..."
                                            color: root.walColor8; visible: !parent.text
                                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                            font: parent.font; opacity: 0.6
                                        }
                                        onTextChanged: {
                                            launcherModule.searchTerm = text.toLowerCase()
                                            launcherModule.selectedIndex = 0
                                            appGrid.contentY = 0
                                        }
                                        Keys.priority: Keys.BeforeItem
                                        Keys.onPressed: function(event) {
                                            var cols = Math.max(1, Math.floor(appGrid.width / appGrid.cellWidth))
                                            var total = launcherModule.filteredApps.length
                                            if (event.key === Qt.Key_Right) {
                                                launcherModule.selectedIndex = Math.min(launcherModule.selectedIndex + 1, total - 1)
                                                appGrid.positionViewAtIndex(launcherModule.selectedIndex, GridView.Contain)
                                                event.accepted = true
                                            } else if (event.key === Qt.Key_Left) {
                                                launcherModule.selectedIndex = Math.max(launcherModule.selectedIndex - 1, 0)
                                                appGrid.positionViewAtIndex(launcherModule.selectedIndex, GridView.Contain)
                                                event.accepted = true
                                            } else if (event.key === Qt.Key_Down) {
                                                launcherModule.selectedIndex = Math.min(launcherModule.selectedIndex + cols, total - 1)
                                                appGrid.positionViewAtIndex(launcherModule.selectedIndex, GridView.Contain)
                                                event.accepted = true
                                            } else if (event.key === Qt.Key_Up) {
                                                launcherModule.selectedIndex = Math.max(launcherModule.selectedIndex - cols, 0)
                                                appGrid.positionViewAtIndex(launcherModule.selectedIndex, GridView.Contain)
                                                event.accepted = true
                                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                                if (total > 0)
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
                                        text: "󰅖"; color: root.walColor8; font.pixelSize: 12; font.family: root.fontFamily
                                        opacity: clearAppMouse.containsMouse ? 1.0 : 0.7
                                        Behavior on opacity { NumberAnimation { duration: 100 } }
                                        MouseArea {
                                            id: clearAppMouse; anchors.fill: parent; anchors.margins: -4
                                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: { searchInput.text = ""; searchInput.forceActiveFocus() }
                                        }
                                    }
                                }
                            }

                            // App icon grid
                            GridView {
                                id: appGrid
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                cellWidth: 110
                                cellHeight: 114
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                model: launcherModule.filteredApps
                                cacheBuffer: 400

                                property real targetContentY: 0
                                property bool animatingScroll: false

                                NumberAnimation {
                                    id: appGridScrollAnim
                                    target: appGrid; property: "contentY"
                                    duration: 300; easing.type: Easing.OutCubic
                                    onFinished: appGrid.animatingScroll = false
                                }

                                function smoothScrollTo(newY) {
                                    var maxY = Math.max(0, contentHeight - height)
                                    newY = Math.max(0, Math.min(newY, maxY))
                                    if (animatingScroll) appGridScrollAnim.stop()
                                    animatingScroll = true
                                    appGridScrollAnim.from = contentY
                                    appGridScrollAnim.to = newY
                                    targetContentY = newY
                                    appGridScrollAnim.start()
                                }

                                function smoothScrollBy(delta) {
                                    smoothScrollTo((animatingScroll ? targetContentY : contentY) + delta)
                                }

                                MouseArea {
                                    anchors.fill: parent; propagateComposedEvents: true
                                    onWheel: function(wheel) { appGrid.smoothScrollBy(-wheel.angleDelta.y / 120.0 * 80) }
                                    onClicked:   function(mouse) { mouse.accepted = false }
                                    onPressed:   function(mouse) { mouse.accepted = false }
                                    onReleased:  function(mouse) { mouse.accepted = false }
                                }

                                delegate: Item {
                                    width: appGrid.cellWidth
                                    height: appGrid.cellHeight

                                    Rectangle {
                                        anchors.fill: parent; anchors.margins: 5
                                        radius: 12
                                        color: {
                                            if (index === launcherModule.selectedIndex)
                                                return Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.18)
                                            if (appItemMouse.containsMouse)
                                                return Qt.rgba(1, 1, 1, 0.07)
                                            return "transparent"
                                        }
                                        border.width: index === launcherModule.selectedIndex ? 1 : 0
                                        border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.5)
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        ColumnLayout {
                                            anchors.fill: parent; anchors.margins: 8
                                            spacing: 6

                                            Item {
                                                Layout.fillWidth: true; Layout.fillHeight: true
                                                Image {
                                                    id: appIcon
                                                    anchors.centerIn: parent
                                                    width: 48; height: 48
                                                    source: {
                                                        var icon = modelData.icon
                                                        if (!icon || icon === "") return ""
                                                        if (icon.indexOf("/") === 0) return "file://" + icon
                                                        return "image://icon/" + icon
                                                    }
                                                    fillMode: Image.PreserveAspectFit
                                                    asynchronous: true; cache: true
                                                    visible: status === Image.Ready
                                                }
                                                Text {
                                                    anchors.centerIn: parent
                                                    visible: appIcon.status !== Image.Ready
                                                    text: "󰏠"; color: root.walColor8
                                                    font.pixelSize: 38; font.family: root.fontFamily
                                                }
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.name
                                                color: index === launcherModule.selectedIndex ? root.walColor5 : root.walForeground
                                                font.pixelSize: 11; font.family: root.fontFamily
                                                font.bold: index === launcherModule.selectedIndex
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignHCenter
                                                Behavior on color { ColorAnimation { duration: 120 } }
                                            }
                                        }

                                        MouseArea {
                                            id: appItemMouse; anchors.fill: parent
                                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: launcherModule.launchApp(modelData)
                                            onContainsMouseChanged: { if (containsMouse) launcherModule.selectedIndex = index }
                                        }
                                    }
                                }

                                ScrollBar.vertical: ScrollBar { active: true; width: 4; policy: ScrollBar.AsNeeded }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                visible: launcherModule.filteredApps.length === 0
                                text: "No apps found"; color: root.walColor8
                                font.pixelSize: 14; font.family: root.fontFamily
                            }

                            // Help bar
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 28
                                color: Qt.rgba(0, 0, 0, 0.25); radius: 10
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                                    Text { text: "←→↑↓ nav";  color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "↵ launch";  color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "tab walls"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "esc close"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                                }
                            }
                        }

                        // ── Wallpapers Tab ────────────────────────────────────
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 15
                            visible: launcherModule.activeTab === 1
                            opacity: launcherModule.activeTab === 1 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            // Search bar
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 46
                                color: Qt.rgba(0, 0, 0, 0.3); radius: 12
                                border.width: wallSearchInput.activeFocus ? 1 : 0
                                border.color: root.walColor13
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 10
                                    Text { text: ""; color: root.walColor8; font.pixelSize: 16; font.family: root.fontFamily }
                                    TextInput {
                                        id: wallSearchInput
                                        Layout.fillWidth: true; Layout.fillHeight: true
                                        color: root.walForeground; font.pixelSize: 15; font.family: root.fontFamily
                                        verticalAlignment: TextInput.AlignVCenter; selectByMouse: true; clip: true
                                        Text {
                                            text: "Search wallpapers..."; color: root.walColor8; visible: !parent.text
                                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                            font: parent.font; opacity: 0.6
                                        }
                                        onTextChanged: { launcherModule.wallSearchTerm = text.toLowerCase(); launcherModule.wallSelectedIndex = 0; wallGridView.contentY = 0 }
                                        Keys.priority: Keys.BeforeItem
                                        Keys.onPressed: function(event) {
                                            var cols = Math.max(1, Math.floor(wallGridView.width / wallGridView.cellWidth))
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
                                                if (total > 0) launcherModule.applyWallpaper(launcherModule.filteredWallpapers[launcherModule.wallSelectedIndex])
                                                event.accepted = true
                                            } else if (event.key === Qt.Key_Escape) {
                                                launcherModule.launcherVisible = false
                                                event.accepted = true
                                            } else if (event.key === Qt.Key_Tab) {
                                                launcherModule.activeTab = 0; searchInput.forceActiveFocus(); event.accepted = true
                                            }
                                        }
                                    }
                                    Text {
                                        visible: wallSearchInput.text.length > 0
                                        text: "󰅖"; color: root.walColor8; font.pixelSize: 12; font.family: root.fontFamily
                                        opacity: clearWallMouse.containsMouse ? 1.0 : 0.7
                                        Behavior on opacity { NumberAnimation { duration: 100 } }
                                        MouseArea {
                                            id: clearWallMouse; anchors.fill: parent; anchors.margins: -4
                                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: { wallSearchInput.text = ""; wallSearchInput.forceActiveFocus() }
                                        }
                                    }
                                }
                            }

                            // Wallpaper grid
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: Qt.rgba(0, 0, 0, 0.25); radius: 15; clip: true

                                GridView {
                                    id: wallGridView
                                    anchors.fill: parent; anchors.margins: 10
                                    cellWidth: Math.floor(width / 5)
                                    cellHeight: cellWidth * 0.65 + 24
                                    boundsBehavior: Flickable.StopAtBounds; clip: true; cacheBuffer: 400
                                    model: launcherModule.filteredWallpapers

                                    property real targetContentY: 0
                                    property bool animatingScroll: false

                                    NumberAnimation {
                                        id: wallScrollAnim; target: wallGridView; property: "contentY"
                                        duration: 300; easing.type: Easing.OutCubic
                                        onFinished: wallGridView.animatingScroll = false
                                    }

                                    function smoothScrollTo(newY) {
                                        var maxY = Math.max(0, contentHeight - height)
                                        newY = Math.max(0, Math.min(newY, maxY))
                                        if (animatingScroll) wallScrollAnim.stop()
                                        animatingScroll = true
                                        wallScrollAnim.from = contentY; wallScrollAnim.to = newY
                                        targetContentY = newY; wallScrollAnim.start()
                                    }

                                    function smoothScrollBy(delta) {
                                        smoothScrollTo((animatingScroll ? targetContentY : contentY) + delta)
                                    }

                                    MouseArea {
                                        anchors.fill: parent; propagateComposedEvents: true
                                        onWheel: function(wheel) { wallGridView.smoothScrollBy(-wheel.angleDelta.y / 120.0 * (wallGridView.cellHeight * 0.6)) }
                                        onClicked:  function(mouse) { mouse.accepted = false }
                                        onPressed:  function(mouse) { mouse.accepted = false }
                                        onReleased: function(mouse) { mouse.accepted = false }
                                    }

                                    delegate: Item {
                                        width: wallGridView.cellWidth; height: wallGridView.cellHeight
                                        Rectangle {
                                            anchors.fill: parent; anchors.margins: 4; radius: 10
                                            color: {
                                                if (index === launcherModule.wallSelectedIndex) return Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.25)
                                                if (wallItemMouse.containsMouse) return Qt.rgba(1, 1, 1, 0.08)
                                                return Qt.rgba(0, 0, 0, 0.2)
                                            }
                                            border.width: modelData.path === launcherModule.currentWallpaper ? 2 : index === launcherModule.wallSelectedIndex ? 1 : 0
                                            border.color: modelData.path === launcherModule.currentWallpaper ? root.walColor2 : root.walColor13
                                            Behavior on color { ColorAnimation { duration: 120 } }

                                            ColumnLayout {
                                                anchors.fill: parent; anchors.margins: 4; spacing: 2
                                                Item {
                                                    Layout.fillWidth: true; Layout.fillHeight: true
                                                    Rectangle { anchors.fill: parent; radius: 7; color: Qt.rgba(0.3, 0.3, 0.3, 0.3); visible: wallThumbImage.status !== Image.Ready }
                                                    Image {
                                                        id: wallThumbImage; anchors.fill: parent
                                                        property string thumbHash: (launcherModule.wallpaperHashes && launcherModule.wallpaperHashes[modelData.path]) ? launcherModule.wallpaperHashes[modelData.path] : ""
                                                        source: thumbHash ? "file://" + launcherModule.cachePath + "/wallpaper-thumbs/" + thumbHash + ".jpg" : ""
                                                        fillMode: Image.PreserveAspectCrop; smooth: false; asynchronous: true; cache: true
                                                        sourceSize.width: 180; sourceSize.height: 120; visible: false
                                                        onStatusChanged: { if (status === Image.Error && modelData.path) source = "file://" + modelData.path }
                                                    }
                                                    Rectangle { id: wallThumbMaskRect; anchors.fill: parent; radius: 7; visible: false }
                                                    OpacityMask { anchors.fill: parent; source: wallThumbImage; maskSource: wallThumbMaskRect }
                                                    Rectangle {
                                                        visible: modelData.path === launcherModule.currentWallpaper
                                                        anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 3
                                                        width: 16; height: 16; radius: 8; color: root.walColor2
                                                        Text { anchors.centerIn: parent; text: "󰄬"; color: root.walBackground; font.pixelSize: 10; font.family: root.fontFamily }
                                                    }
                                                }
                                                Text {
                                                    Layout.fillWidth: true; Layout.preferredHeight: 22
                                                    text: modelData.name
                                                    color: modelData.path === launcherModule.currentWallpaper ? root.walColor2 : index === launcherModule.wallSelectedIndex ? root.walColor13 : root.walForeground
                                                    font.pixelSize: 8; font.family: root.fontFamily
                                                    font.bold: index === launcherModule.wallSelectedIndex || modelData.path === launcherModule.currentWallpaper
                                                    elide: Text.ElideMiddle; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                                    Behavior on color { ColorAnimation { duration: 120 } }
                                                }
                                            }

                                            MouseArea {
                                                id: wallItemMouse; anchors.fill: parent
                                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: launcherModule.applyWallpaper(modelData)
                                                onContainsMouseChanged: { if (containsMouse) launcherModule.wallSelectedIndex = index }
                                            }
                                        }
                                    }

                                    ScrollBar.vertical: ScrollBar { active: true; width: 4; policy: ScrollBar.AsNeeded }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: launcherModule.wallsLoaded && launcherModule.filteredWallpapers.length === 0
                                    text: "No wallpapers found"; color: root.walColor8; font.pixelSize: 14; font.family: root.fontFamily
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: !launcherModule.wallsLoaded && launcherModule.wallpaperList.length === 0
                                    text: "Loading..."; color: root.walColor8; font.pixelSize: 13; font.family: root.fontFamily
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.4; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                                        NumberAnimation { from: 1.0; to: 0.4; duration: 600; easing.type: Easing.InOutSine }
                                    }
                                }
                            }

                            // Help bar
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 28
                                color: Qt.rgba(0, 0, 0, 0.25); radius: 10
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                                    Text { text: "←→↑↓ nav"; color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "↵ apply";  color: root.walColor8; font.pixelSize: 10; font.family: root.fontFamily; opacity: 0.7 }
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
        }
    }

    // ─── State reset ──────────────────────────────────────────────────────────
    Connections {
        target: launcherModule
        function onLauncherVisibleChanged() {
            if (launcherModule.launcherVisible) {
                searchInput.text = ""
                wallSearchInput.text = ""
                launcherModule.searchTerm = ""
                launcherModule.selectedIndex = 0
                launcherModule.wallSelectedIndex = 0
                appGrid.contentY = 0
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
        id: focusDelayTimer; interval: 50; repeat: false
        onTriggered: exclusiveReleaseTimer.start()
    }

    Timer {
        id: exclusiveReleaseTimer; interval: 100; repeat: false
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
