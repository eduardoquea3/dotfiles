import QtQuick
import QtQuick.Controls
import Quickshell.Bluetooth
import Quickshell.Networking

Rectangle {
    id: panel

    property string panelType: ""
    property var wifiDevice: null
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothAvailable: bluetoothAdapter !== null
    readonly property bool bluetoothReady: bluetoothAdapter && bluetoothAdapter.state === BluetoothAdapterState.Enabled
    readonly property bool open: panelType === "wifi" || panelType === "bluetooth"
    readonly property bool wifiMode: panelType === "wifi"
    readonly property bool radioEnabled: wifiMode ? Networking.wifiEnabled : bluetoothReady
    readonly property bool radioPowered: wifiMode ? Networking.wifiEnabled : bluetoothAdapter && bluetoothAdapter.enabled
    property var selectedNetwork: null
    property bool passwordMode: false
    property bool passwordVisible: false
    property string connectionError: ""
    property bool scanning: false

    signal closeRequested()

    focus: open
    Keys.onEscapePressed: {
        closeRequested();
        event.accepted = true;
    }

    function requestScan() {
        if (!open || !radioEnabled)
            return;

        scanDebounce.restart();
    }

    function startScan() {
        if (wifiMode && wifiDevice) {
            wifiDevice.scannerEnabled = true;
            scanning = true;
        } else if (!wifiMode && bluetoothReady && !bluetoothAdapter.discovering) {
            bluetoothAdapter.discovering = true;
            scanning = true;
        } else {
            return;
        }

        scanStop.restart();
    }

    function stopScanning() {
        if (!scanning)
            return;

        if (wifiDevice)
            wifiDevice.scannerEnabled = false;
        if (bluetoothAdapter && bluetoothAdapter.discovering)
            bluetoothAdapter.discovering = false;
        scanning = false;
    }

    function closePasswordForm() {
        selectedNetwork = null;
        passwordMode = false;
        passwordVisible = false;
        connectionError = "";
        if (passwordField)
            passwordField.clear();
    }

    function selectWifiNetwork(network) {
        if (network.stateChanging || !Networking.wifiEnabled)
            return;

        if (network.connected) {
            network.disconnect();
            return;
        }

        selectedNetwork = network;
        connectionError = "";
        passwordMode = true;
        passwordVisible = false;
        passwordField.clear();
        passwordField.forceActiveFocus();
    }

    function connectWifi() {
        if (!selectedNetwork)
            return;

        connectionError = "";
        if (selectedNetwork.security === WifiSecurityType.Open)
            selectedNetwork.connect();
        else if (passwordField.text)
            selectedNetwork.connectWithPsk(passwordField.text);
    }

    function forgetWifiNetwork(network) {
        if (network.stateChanging)
            return;

        if (network.connected)
            network.disconnect();
        else
            network.forget();
    }

    function toggleBluetoothDevice(device) {
        if (!bluetoothAdapter || !bluetoothReady || device.pairing)
            return;

        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    function forgetBluetoothDevice(device) {
        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.forget();
    }

    function toggleRadio() {
        if (wifiMode)
            Networking.wifiEnabled = !Networking.wifiEnabled;
        else if (bluetoothAdapter)
            bluetoothAdapter.enabled = !bluetoothAdapter.enabled;
    }

    implicitWidth: 340
    implicitHeight: passwordMode ? 248 : 430
    width: implicitWidth
    height: implicitHeight
    radius: 16
    color: root.colBg
    border.width: 1
    border.color: root.colBorder
    clip: true

    onPanelTypeChanged: {
        closePasswordForm();
        stopScanning();
        if (open)
            requestScan();
    }

    onRadioEnabledChanged: {
        if (open && radioEnabled)
            requestScan();
        else if (!radioEnabled)
            stopScanning();
    }

    onRadioPoweredChanged: {
        if (!radioPowered)
            stopScanning();
    }

    Component.onDestruction: stopScanning()

    Timer {
        id: scanDebounce
        interval: 280
        repeat: false
        onTriggered: panel.startScan()
    }

    Timer {
        id: scanStop
        interval: 12000
        repeat: false
        onTriggered: panel.stopScanning()
    }

    Instantiator {
        model: Networking.devices

        delegate: QtObject {
            required property var modelData

            Component.onCompleted: {
                if (modelData.type === DeviceType.Wifi)
                    panel.wifiDevice = modelData;
            }

            Component.onDestruction: {
                if (panel.wifiDevice === modelData)
                    panel.wifiDevice = null;
            }
        }
    }

    Connections {
        target: panel.selectedNetwork

        function onConnectedChanged() {
            if (panel.selectedNetwork && panel.selectedNetwork.connected)
                panel.closePasswordForm();
        }

        function onConnectionFailed() {
            panel.connectionError = "Could not connect with that password";
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Item {
            width: parent.width
            height: 30

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: (panel.wifiMode ? "󰤨  " : "󰂯  ") + (panel.wifiMode ? "Wi-Fi" : "Bluetooth")
                color: panel.radioEnabled ? (panel.wifiMode ? root.colBlue : root.colPurple) : root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2
                font.bold: true
            }

            Rectangle {
                id: closeButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: 8
                color: closeMouse.containsMouse
                    ? Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.12)
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeMouse.containsMouse ? root.colFg : root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 2
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.closeRequested()
                }
            }

            Item {
                id: radioSwitch
                anchors.right: closeButton.left
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 20
                visible: panel.wifiMode || panel.bluetoothAvailable
                opacity: panel.wifiMode || panel.bluetoothAvailable ? 1 : 0.45

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: panel.radioPowered ? (panel.wifiMode ? root.colBlue : root.colPurple) : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.45)
                }

                Rectangle {
                    width: 14
                    height: 14
                    radius: height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    x: panel.radioPowered ? parent.width - width - 3 : 3
                    color: root.colFg

                    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: panel.wifiMode || panel.bluetoothAvailable
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.toggleRadio()
                }
            }
        }

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: panel.passwordMode ? "Enter the Wi-Fi password" : (panel.radioEnabled ? (panel.wifiMode ? "Nearby networks" : "Nearby devices") : "Turn it on to discover connections")
                color: root.colBorder
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
            }

            Rectangle {
                id: rescanButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: rescanText.implicitWidth + 12
                height: 24
                visible: panel.passwordMode || panel.radioEnabled
                radius: 7
                color: rescanMouse.containsMouse
                    ? Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.12)
                    : "transparent"

                Text {
                    id: rescanText
                    anchors.centerIn: parent
                    text: panel.passwordMode ? "Back" : (panel.wifiMode ? "󰑐  Rescan" : "󰑐  Search")
                    color: rescanMouse.containsMouse ? root.colFg : root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.passwordMode ? panel.closePasswordForm() : panel.requestScan()
                }
            }
        }

        Item {
            width: parent.width
            height: Math.max(0, parent.height - 74)
            visible: !panel.passwordMode

            ListView {
                id: wifiList
                anchors.fill: parent
                clip: true
                visible: panel.wifiMode
                model: panel.wifiDevice ? panel.wifiDevice.networks : null
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds

                Text {
                    anchors.centerIn: parent
                    visible: wifiList.count === 0
                    text: panel.radioEnabled ? "No networks found" : "Wi-Fi is off"
                    color: root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    required property var modelData
                    width: wifiList.width
                    height: 58
                    radius: 10
                    color: wifiDelegateMouse.containsMouse
                        ? Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.28)
                        : (modelData.connected
                            ? Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.18)
                            : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.11))

                    MouseArea {
                        id: wifiDelegateMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.selectWifiNetwork(modelData)
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: wifiAction.left
                        anchors.rightMargin: 8
                        anchors.top: parent.top
                        anchors.topMargin: 9
                        text: modelData.name || "Hidden network"
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: wifiAction.left
                        anchors.rightMargin: 8
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 9
                        text: (modelData.connected ? "Connected" : (modelData.known ? "Saved network" : (modelData.security === WifiSecurityType.Open ? "Open network" : "Password required"))) + "  ·  " + Math.round(modelData.signalStrength * 100) + "%"
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 1
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: wifiAction
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 84
                        height: 28
                        radius: 8
                        visible: modelData.known || modelData.connected
                        color: actionMouse.containsMouse ? root.colFg : Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: "Disconnect"
                            color: actionMouse.containsMouse ? root.colBg : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            font.bold: true
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.forgetWifiNetwork(modelData)
                        }
                    }
                }
            }

            ListView {
                id: bluetoothList
                anchors.fill: parent
                clip: true
                visible: !panel.wifiMode
                model: panel.bluetoothAdapter ? panel.bluetoothAdapter.devices : null
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds

                Text {
                    anchors.centerIn: parent
                    visible: bluetoothList.count === 0
                    text: !panel.bluetoothAvailable ? "No Bluetooth adapter available" : (!panel.bluetoothReady ? "Bluetooth is starting" : "No devices found")
                    color: root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    required property var modelData
                    width: bluetoothList.width
                    height: 58
                    radius: 10
                    color: bluetoothDelegateMouse.containsMouse
                        ? Qt.rgba(root.colPurple.r, root.colPurple.g, root.colPurple.b, 0.3)
                        : (modelData.connected
                            ? Qt.rgba(root.colPurple.r, root.colPurple.g, root.colPurple.b, 0.2)
                            : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.11))

                    MouseArea {
                        id: bluetoothDelegateMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.toggleBluetoothDevice(modelData)
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: bluetoothAction.left
                        anchors.rightMargin: 8
                        anchors.top: parent.top
                        anchors.topMargin: 9
                        text: modelData.deviceName || modelData.name || modelData.address
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: bluetoothAction.left
                        anchors.rightMargin: 8
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 9
                        text: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 1
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: bluetoothAction
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 84
                        height: 28
                        radius: 8
                        visible: modelData.paired || modelData.connected
                        color: bluetoothActionMouse.containsMouse ? root.colFg : Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: "Disconnect"
                            color: bluetoothActionMouse.containsMouse ? root.colBg : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            font.bold: true
                        }

                        MouseArea {
                            id: bluetoothActionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.forgetBluetoothDevice(modelData)
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: Math.max(0, parent.height - 74)
            visible: panel.passwordMode

            Column {
                anchors.fill: parent
                spacing: 10

                Text {
                    width: parent.width
                    text: panel.selectedNetwork ? panel.selectedNetwork.name : ""
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 1
                    font.bold: true
                    elide: Text.ElideRight
                }

                Item {
                    width: parent.width
                    height: 38

                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        leftPadding: 10
                        rightPadding: 38
                        placeholderText: "Password"
                        echoMode: panel.passwordVisible ? TextInput.Normal : TextInput.Password
                        color: root.colFg
                        placeholderTextColor: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        selectByMouse: true
                        background: Rectangle {
                            radius: 9
                            color: Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.12)
                            border.width: passwordField.activeFocus ? 1 : 0
                            border.color: root.colBlue
                        }
                        Keys.onReturnPressed: panel.connectWifi()
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 11
                        anchors.verticalCenter: parent.verticalCenter
                        text: panel.passwordVisible ? "" : ""
                        color: passwordVisibilityMouse.containsMouse ? root.colFg : root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize + 2

                        MouseArea {
                            id: passwordVisibilityMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.passwordVisible = !panel.passwordVisible
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 9
                    color: connectMouse.containsMouse ? root.colBlue : Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.75)

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: root.colBg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        font.bold: true
                    }

                    MouseArea {
                        id: connectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.connectWifi()
                    }
                }

                Text {
                    width: parent.width
                    text: panel.connectionError
                    color: root.colRed
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                }
            }
        }
    }
}
