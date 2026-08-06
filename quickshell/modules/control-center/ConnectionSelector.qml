import QtQuick
import QtQuick.Controls
import Quickshell.Bluetooth
import Quickshell.Networking

Rectangle {
    id: selector

    property string selectorType: ""
    property var wifiDevice: null
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothAvailable: bluetoothAdapter !== null
    readonly property bool bluetoothPowered: bluetoothAdapter && bluetoothAdapter.enabled
    readonly property bool bluetoothReady: bluetoothAdapter && bluetoothAdapter.state === BluetoothAdapterState.Enabled
    readonly property bool open: selectorType === "wifi" || selectorType === "bluetooth"
    readonly property string title: selectorType === "wifi" ? "Wi-Fi" : "Bluetooth"
    readonly property bool radioEnabled: selectorType === "wifi" ? Networking.wifiEnabled : bluetoothReady

    function requestScan() {
        if (!open || !radioEnabled)
            return ;

        scanDebounce.restart();
    }

    function startScan() {
        if (selectorType === "wifi" && wifiDevice)
            wifiDevice.scannerEnabled = true;
        else if (selectorType === "bluetooth" && bluetoothReady) {
            if (!bluetoothAdapter.discovering)
                bluetoothAdapter.discovering = true;
        }
        else
            return ;

        scanStop.restart();
    }

    function stopScanning() {
        if (wifiDevice)
            wifiDevice.scannerEnabled = false;

        if (bluetoothAdapter && bluetoothAdapter.discovering)
            bluetoothAdapter.discovering = false;

    }

    function wifiStatus(network) {
        if (!Networking.wifiEnabled)
            return "Wi-Fi is off";

        if (network.stateChanging)
            return network.state === ConnectionState.Connecting ? "Connecting" : "Disconnecting";

        if (network.connected)
            return "Connected";

        return network.known ? "Saved network" : "Available";
    }

    function bluetoothStatus(device) {
        if (!bluetoothAvailable || !bluetoothPowered)
            return "Bluetooth is off";

        if (!bluetoothReady)
            return "Bluetooth is starting";

        if (device.pairing)
            return "Pairing";

        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting";

        if (device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting";

        if (device.connected)
            return "Connected";

        return device.paired ? "Paired" : "Available";
    }

    function toggleWifiNetwork(network) {
        if (network.stateChanging || !Networking.wifiEnabled)
            return ;

        if (network.connected)
            network.disconnect();
        else
            network.connect();
    }

    function toggleBluetoothDevice(device) {
        if (!bluetoothAdapter || !bluetoothAdapter.enabled || device.pairing)
            return ;

        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    implicitWidth: 320
    implicitHeight: 382
    width: implicitWidth
    height: implicitHeight
    radius: 16
    color: root.colBg
    border.width: 0
    clip: true
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.96
    visible: opacity > 0
    enabled: open
    transformOrigin: selectorType === "bluetooth" ? Item.Left : Item.Right
    onSelectorTypeChanged: {
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
    Component.onDestruction: stopScanning()

    Timer {
        id: scanDebounce

        interval: 280
        repeat: false
        onTriggered: selector.startScan()
    }

    Timer {
        id: scanStop

        interval: 12000
        repeat: false
        onTriggered: selector.stopScanning()
    }

    // Resolve the Wi-Fi device without snapshotting the native device model.
    Instantiator {
        model: Networking.devices

        delegate: QtObject {
            required property var modelData

            Component.onCompleted: {
                if (modelData.type === DeviceType.Wifi)
                    selector.wifiDevice = modelData;

            }
            Component.onDestruction: {
                if (selector.wifiDevice === modelData)
                    selector.wifiDevice = null;

            }
        }

    }

    Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Item {
                width: parent.width
                height: 34

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: (selectorType === "wifi" ? "󰤨  " : "󰂯  ") + selector.title
                    color: selector.radioEnabled ? (selectorType === "wifi" ? root.colBlue : root.colPurple) : root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 2
                    font.bold: true
                }

                Text {
                    id: radioToggle

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: selectorType === "wifi" ? (selector.radioEnabled ? "Turn off" : "Turn on") : (selector.bluetoothPowered ? "Turn off" : "Turn on")
                    visible: selectorType === "wifi" || selector.bluetoothAvailable
                    color: radioToggleMouse.containsMouse ? root.colFg : (selectorType === "wifi" ? root.colBlue : root.colPurple)
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true

                    MouseArea {
                        id: radioToggleMouse

                        anchors.fill: parent
                        anchors.margins: -5
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (selectorType === "wifi")
                                Networking.wifiEnabled = !Networking.wifiEnabled;
                            else if (bluetoothAdapter)
                                bluetoothAdapter.enabled = !bluetoothAdapter.enabled;
                        }
                    }

                }

            }

            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: selectorType === "bluetooth" && !selector.bluetoothAvailable ? "No Bluetooth adapter available" : (!selector.radioEnabled && selectorType === "bluetooth" && selector.bluetoothPowered ? "Bluetooth is starting" : (selector.radioEnabled ? (selectorType === "wifi" ? "Nearby networks" : "Nearby devices") : "Turn it on to discover devices"))
                    color: root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Text {
                    id: rescan

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: selectorType === "wifi" ? "󰑐  Rescan" : "󰑐  Search"
                    visible: selector.radioEnabled
                    color: rescanMouse.containsMouse ? root.colFg : root.colBorder
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize

                    MouseArea {
                        id: rescanMouse

                        anchors.fill: parent
                        anchors.margins: -5
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: selector.requestScan()
                    }

                }

            }

            Item {
                width: parent.width
                height: Math.max(0, parent.parent.height - 78)

                ListView {
                    id: wifiList

                    anchors.fill: parent
                    clip: true
                    visible: selectorType === "wifi"
                    model: selector.wifiDevice ? selector.wifiDevice.networks : null
                    spacing: 6
                    reuseItems: true
                    cacheBuffer: 320
                    boundsBehavior: Flickable.StopAtBounds

                    Text {
                        anchors.centerIn: parent
                        visible: wifiList.count === 0
                        text: selector.radioEnabled ? "No networks found" : "Wi-Fi is off"
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        required property var modelData

                        width: wifiList.width
                        height: 58
                        radius: 10
                        color: modelData.connected ? Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.18) : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.11)

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
                            text: selector.wifiStatus(modelData) + "  ·  " + Math.round(modelData.signalStrength) + "%"
                            color: root.colBorder
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            elide: Text.ElideRight
                        }

                        Text {
                            id: wifiAction

                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.stateChanging ? "…" : (modelData.connected ? "Disconnect" : "Connect")
                            color: modelData.connected ? root.colBlue : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            font.bold: true

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -5
                                cursorShape: Qt.PointingHandCursor
                                onClicked: selector.toggleWifiNetwork(modelData)
                            }

                        }

                    }

                }

                ListView {
                    id: bluetoothList

                    anchors.fill: parent
                    clip: true
                    visible: selectorType === "bluetooth"
                    model: selector.bluetoothAdapter ? selector.bluetoothAdapter.devices : null
                    spacing: 6
                    reuseItems: true
                    cacheBuffer: 320
                    boundsBehavior: Flickable.StopAtBounds

                    Text {
                        anchors.centerIn: parent
                        visible: bluetoothList.count === 0
                        text: !selector.bluetoothAvailable ? "No Bluetooth adapter available" : (!selector.bluetoothPowered ? "Bluetooth is off" : (selector.radioEnabled ? "No devices found" : "Bluetooth is starting"))
                        color: root.colBorder
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        required property var modelData

                        width: bluetoothList.width
                        height: 58
                        radius: 10
                        color: modelData.connected ? Qt.rgba(root.colPurple.r, root.colPurple.g, root.colPurple.b, 0.2) : Qt.rgba(root.colBorder.r, root.colBorder.g, root.colBorder.b, 0.11)

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
                            text: selector.bluetoothStatus(modelData)
                            color: root.colBorder
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            elide: Text.ElideRight
                        }

                        Text {
                            id: bluetoothAction

                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting ? "…" : (modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair"))
                            color: modelData.connected ? root.colPurple : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            font.bold: true

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -5
                                cursorShape: Qt.PointingHandCursor
                                onClicked: selector.toggleBluetoothDevice(modelData)
                            }

                        }

                    }

                }

            }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 210
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 210
            easing.type: Easing.OutCubic
        }

    }

}
