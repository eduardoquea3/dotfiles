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

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [logoutPanel]
        active: shouldShow
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        opacity: shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: logoutModule.logoutVisible = false
        }

        FocusScope {
            anchors.fill: parent
            focus: shouldShow

            Item {
                anchors.centerIn: parent
                width: 500
                height: 480

                scale: shouldShow ? 1 : 0.95
                Behavior on scale { NumberAnimation { duration: 200 } }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.98)
                    radius: 16
                    border.width: 1
                    border.color: Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.4)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        // Header with icon
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4

                            Text {
                                text: "⚡"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "Power Menu"
                                color: root.walForeground
                                font.pixelSize: 18
                                font.bold: true
                                font.family: root.fontFamily
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "Choose an action"
                                color: root.walColor8
                                font.pixelSize: 11
                                font.family: root.fontFamily
                                opacity: 0.6
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(root.walColor8.r, root.walColor8.g, root.walColor8.b, 0.2)
                        }

                        // Button grid (bento style: 3 top, 2 bottom)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            // Top row: 3 buttons with equal width
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10

                                LogoutButton {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                    iconPath: "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/lock.png"
                                    label: "Lock"
                                    onClicked: logoutModule.lock()
                                }

                                LogoutButton {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                    iconPath: "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/sleep.png"
                                    label: "Suspend"
                                    onClicked: logoutModule.suspend()
                                }

                                LogoutButton {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                    iconPath: "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/logout.png"
                                    label: "Logout"
                                    onClicked: logoutModule.logout()
                                }
                            }

                            // Bottom row: 2 buttons with equal width
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10

                                LogoutButton {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                    iconPath: "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/restart.png"
                                    label: "Restart"
                                    destructive: true
                                    onClicked: logoutModule.restart()
                                }

                                LogoutButton {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                    iconPath: "file://" + logoutModule.homePath + "/.config/quickshell/modules/logout/img/power.png"
                                    label: "Shutdown"
                                    destructive: true
                                    onClicked: logoutModule.shutdown()
                                }
                            }
                        }
                    }
                }
            }

            Keys.onEscapePressed: logoutModule.logoutVisible = false
        }
    }

    Keys.onEscapePressed: logoutModule.logoutVisible = false
}
