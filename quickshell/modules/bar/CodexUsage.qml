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
                errorText = "empty quota-axi output";
                return;
            }

            var data = JSON.parse(text);
            var item = data && Array.isArray(data.providers)
                ? data.providers.find(function(provider) { return provider.provider === "codex"; })
                : null;
            if (!item) {
                errorText = "Codex quota data not found";
                return;
            }

            var state = item.state || {};
            if (state.status !== "fresh" && state.status !== "stale") {
                errorText = String(state.error || "Codex quota unavailable (" + (state.status || "unknown") + ")");
                return;
            }

            var windows = item.windows || [];
            function windowById(id) {
                return windows.find(function(quotaWindow) { return quotaWindow.id === id; });
            }
            function usedPercent(quotaWindow) {
                var remaining = quotaWindow ? percent(quotaWindow.percentRemaining) : -1;
                return remaining < 0 ? -1 : 100 - remaining;
            }
            function resetDescription(quotaWindow) {
                if (!quotaWindow || !quotaWindow.resetsAt)
                    return "";
                return "at " + quotaWindow.resetsAt;
            }

            var sessionWindow = windowById("five_hour");
            var weeklyWindow = windowById("weekly");
            sourceName = "quota-axi";
            providerName = "Codex";
            versionText = String(data.schemaVersion || "");
            updatedAt = data.generatedAt || "";
            accountEmail = "";
            loginMethod = "";
            providerId = "codex";
            primaryPercent = usedPercent(sessionWindow);
            secondaryPercent = usedPercent(weeklyWindow);
            primaryReset = resetDescription(sessionWindow);
            secondaryReset = resetDescription(weeklyWindow);
            primaryResetAt = sessionWindow ? sessionWindow.resetsAt || "" : "";
            secondaryResetAt = weeklyWindow ? weeklyWindow.resetsAt || "" : "";
            creditsRemaining = Number(item.credits && item.credits.remaining || 0);
            creditEventsCount = 0;
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
        command: ["sh", "-c", "PATH=\"$HOME/.bun/bin:$HOME/.local/bin:$HOME/.opencode/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:$PATH\" exec quota-axi --json"]
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
            codexUsageModule.errorText = message !== "" ? message : "quota-axi exited " + exitCode;
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: codexUsageModule.refresh()
    }

}
