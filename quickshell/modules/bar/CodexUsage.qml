import Quickshell.Io
import QtQuick

Item {
    id: codexUsageModule

    property bool panelVisible: false
    property bool loading: false
    property string errorText: ""
    property string sourceName: ""
    property string providerName: "Codex"
    property string versionText: ""
    property string updatedAt: ""
    property string accountEmail: ""
    property string loginMethod: ""
    property string providerId: "codex"
    property int primaryPercent: -1
    property int secondaryPercent: -1
    property string primaryReset: ""
    property string secondaryReset: ""
    property string primaryResetAt: ""
    property string secondaryResetAt: ""
    property int creditsRemaining: 0
    property int creditEventsCount: 0

    readonly property bool hasUsage: primaryPercent >= 0 || secondaryPercent >= 0

    function percent(value) {
        if (value === undefined || value === null)
            return -1;

        var number = Number(value);
        if (isNaN(number))
            return -1;
        return Math.min(100, Math.max(0, number));
    }

    function parseOutput(output) {
        try {
            var text = String(output || "").trim();
            if (text === "") {
                errorText = "empty codexbar output";
                return;
            }

            var data = JSON.parse(text);
            var item = Array.isArray(data) ? data[0] : data;
            if (!item) {
                errorText = "invalid codexbar output";
                return;
            }
            if (item.error) {
                errorText = String(item.error.message || item.error);
                return;
            }

            var usage = item.usage || {};
            var identity = usage.identity || {};
            var credits = item.credits || {};

            sourceName = item.source || "codex-cli";
            providerName = item.provider || identity.providerID || "codex";
            versionText = item.version || "";
            updatedAt = usage.updatedAt || credits.updatedAt || "";
            accountEmail = usage.accountEmail || identity.accountEmail || "";
            loginMethod = usage.loginMethod || identity.loginMethod || "";
            providerId = identity.providerID || item.provider || "codex";
            primaryPercent = percent(usage.primary ? usage.primary.usedPercent : undefined);
            secondaryPercent = percent(usage.secondary ? usage.secondary.usedPercent : undefined);
            primaryReset = usage.primary ? usage.primary.resetDescription || "" : "";
            secondaryReset = usage.secondary ? usage.secondary.resetDescription || "" : "";
            primaryResetAt = usage.primary ? usage.primary.resetsAt || "" : "";
            secondaryResetAt = usage.secondary ? usage.secondary.resetsAt || "" : "";
            creditsRemaining = Number(credits.remaining || 0);
            creditEventsCount = Array.isArray(credits.events) ? credits.events.length : 0;
            errorText = "";
        } catch (error) {
            errorText = "parse failed";
        }
    }

    function refresh() {
        if (!usageProcess.running)
            usageProcess.running = true;
    }

    function togglePanel() {
        panelVisible = !panelVisible;
        if (panelVisible)
            refresh();
    }

    function closePanel() {
        panelVisible = false;
    }

    Process {
        id: usageProcess
        command: ["codexbar", "usage", "--provider", "codex", "--source", "cli", "--format", "json"]
        running: true

        stdout: StdioCollector {
            id: usageStdout
            onStreamFinished: codexUsageModule.parseOutput(text)
        }

        stderr: StdioCollector {
            id: usageStderr
        }

        onRunningChanged: codexUsageModule.loading = running
        onExited: function(exitCode) {
            if (exitCode === 0)
                return;

            var message = String(usageStderr.text || "").trim();
            codexUsageModule.errorText = message !== "" ? message : "codexbar exited " + exitCode;
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: codexUsageModule.refresh()
    }

}
