import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: logoutPanel
    visible: shouldShow
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    focusable: true

    property bool shouldShow: logoutModule.logoutVisible
    property int selectedIndex: 0
    property var options: [
        { label: "Lock", action: () => logoutModule.lock(), destructive: false },
        { label: "Suspend", action: () => logoutModule.suspend(), destructive: false },
        { label: "Logout", action: () => logoutModule.logout(), destructive: false },
        { label: "Restart", action: () => logoutModule.restart(), destructive: true },
        { label: "Shutdown", action: () => logoutModule.shutdown(), destructive: true }
    ]

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [logoutPanel]
        active: shouldShow
    }

    onShouldShowChanged: {
        if (shouldShow) selectedIndex = 0
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.8)
        opacity: shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: logoutModule.logoutVisible = false
        }

        FocusScope {
            anchors.fill: parent
            focus: shouldShow

            GridView {
                id: optionsGrid
                anchors.centerIn: parent
                width: Math.min(1400, parent.width - 60)
                height: 280
                cellWidth: width / 5
                cellHeight: height
                model: logoutPanel.options.length
                interactive: false

                delegate: Item {
                    required property int index
                    width: optionsGrid.cellWidth
                    height: optionsGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 12
                        radius: 16
                        color: index === logoutPanel.selectedIndex
                            ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.5)
                            : Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.15)
                        Behavior on color { ColorAnimation { duration: 100 } }

                        border.width: index === logoutPanel.selectedIndex ? 2 : 1
                        border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, index === logoutPanel.selectedIndex ? 0.8 : 0.3)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Image {
                                sourceSize.width: 70
                                sourceSize.height: 70
                                Layout.alignment: Qt.AlignHCenter
                                smooth: true
                                opacity: index === logoutPanel.selectedIndex ? 1 : 0.85
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                source: {
                                    const icons = [
                                        "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/lock.png",
                                        "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/sleep.png",
                                        "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/logout.png",
                                        "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/restart.png",
                                        "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/power.png"
                                    ]
                                    return icons[index]
                                }
                            }

                            Text {
                                text: logoutPanel.options[index].label
                                color: logoutPanel.options[index].destructive
                                    ? Qt.rgba(1, 0.4, 0.4, 1)
                                    : root.walForeground
                                font.pixelSize: 16
                                font.family: root.fontFamily
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: logoutPanel.selectedIndex = index
                            onClicked: logoutPanel.options[index].action()
                        }
                    }
                }
            }

            Keys.onEscapePressed: {
                logoutModule.logoutVisible = false
                event.accepted = true
            }

            Keys.onLeftPressed: {
                if (selectedIndex > 0) selectedIndex--
                else selectedIndex = options.length - 1
                event.accepted = true
            }

            Keys.onRightPressed: {
                if (selectedIndex < options.length - 1) selectedIndex++
                else selectedIndex = 0
                event.accepted = true
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_H) {
                    if (selectedIndex > 0) selectedIndex--
                    else selectedIndex = options.length - 1
                    event.accepted = true
                }
                else if (event.key === Qt.Key_L) {
                    if (selectedIndex < options.length - 1) selectedIndex++
                    else selectedIndex = 0
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
                    options[selectedIndex].action()
                    event.accepted = true
                }
            }
        }
    }

    Keys.onEscapePressed: logoutModule.logoutVisible = false
}
