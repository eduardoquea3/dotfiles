import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: notificationService

    property bool dndEnabled: root.notificationDnd
    property string barPosition: root.barPosition
    property var currentNotification: null
    readonly property bool popupVisible: currentNotification !== null && !dndEnabled
    readonly property var trackedNotifications: server.trackedNotifications

    function dismiss(notification) {
        if (!notification)
            return ;

        if (currentNotification === notification) {
            currentNotification = null;
            timeout.stop();
        }
        notification.dismiss();
    }

    function clearAll() {
        const notifications = server.trackedNotifications.values || [];
        for (let index = 0; index < notifications.length; index++) dismiss(notifications[index])
    }

    onCurrentNotificationChanged: {
        timeout.stop();
        if (currentNotification)
            timeout.start();

    }
    onDndEnabledChanged: {
        if (dndEnabled)
            timeout.stop();
        else if (currentNotification)
            timeout.start();
    }
    onPopupVisibleChanged: root.notificationPopupVisible = popupVisible

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        imageSupported: true
        actionsSupported: true
        onNotification: (notification) => {
            notification.tracked = true;
            if (!notificationService.dndEnabled)
                notificationService.currentNotification = notification;

        }
    }

    Connections {
        function onClosed() {
            if (notificationService.currentNotification === target) {
                notificationService.currentNotification = null;
                timeout.stop();
            }
        }

        target: notificationService.currentNotification
    }

    Timer {
        id: timeout

        interval: 6000
        repeat: false
        onTriggered: notificationService.currentNotification = null
    }

    Variants {
        model: Quickshell.screens

        delegate: Loader {
            required property var modelData

            source: "NotificationPopup.qml"
        }

    }

}
