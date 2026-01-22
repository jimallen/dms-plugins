import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property bool showStatusText: pluginData.showStatusText !== undefined ? pluginData.showStatusText : true
    readonly property bool pulseAnimation: pluginData.pulseAnimation !== undefined ? pluginData.pulseAnimation : true
    readonly property int longPressThreshold: pluginData.longPressThreshold || 500
    readonly property int pollIntervalIdle: (pluginData.pollInterval || 10) * 1000
    readonly property int pollIntervalRecording: 2000
    readonly property color recordingColor: pluginData.recordingColor || "#ef5350"
    readonly property color idleColor: pluginData.idleColor || "#90a4ae"
    readonly property color errorColor: pluginData.errorColor || "#ffb4ab"
    readonly property bool isSlideoutVisible: hyprwhsprSlideout.isVisible

    property bool isRecording: false
    property bool isServiceRunning: false
    property string currentMode: "toggle"
    property string lastTranscription: ""
    property string errorMessage: ""
    property string backendInfo: ""
    property bool isPushToTalkActive: false

    readonly property string controlFilePath: Quickshell.env("HOME") + "/.config/hyprwhspr/recording_control"

    readonly property color currentColor: {
        if (errorMessage) return errorColor
        if (isRecording) return recordingColor
        return idleColor
    }

    readonly property string statusText: {
        if (errorMessage) return "Error"
        if (!isServiceRunning) return "Stopped"
        if (isRecording) return isPushToTalkActive ? "PTT..." : "Recording..."
        return "Ready"
    }

    function startRecording() {
        Quickshell.execDetached(["sh", "-c", 'echo "start" > ' + controlFilePath])
        isRecording = true
        pollTimer.interval = pollIntervalRecording
    }

    function stopRecording() {
        Quickshell.execDetached(["sh", "-c", 'echo "stop" > ' + controlFilePath])
        isRecording = false
        pollTimer.interval = pollIntervalIdle
    }

    function submitRecording() {
        Quickshell.execDetached(["sh", "-c", 'echo "submit" > ' + controlFilePath])
        isRecording = false
        pollTimer.interval = pollIntervalIdle
    }

    function toggleRecording() {
        if (isRecording) {
            // In toggle mode, "stop" both stops and transcribes
            // In long_form mode, use "submit" to transcribe
            if (currentMode === "long_form") {
                submitRecording()
            } else {
                stopRecording()
            }
        } else {
            startRecording()
        }
    }

    readonly property string configFilePath: Quickshell.env("HOME") + "/.config/hyprwhspr/config.json"

    function refreshStatus() {
        if (!statusProcess.running) {
            statusProcess.running = true
        }
    }

    function loadConfig() {
        if (!configProcess.running) {
            configProcess.running = true
        }
    }

    function restartService() {
        Quickshell.execDetached(["systemctl", "--user", "restart", "hyprwhspr.service"])
        Qt.callLater(refreshStatus)
    }

    Component.onCompleted: {
        loadConfig()
        refreshStatus()
    }

    Timer {
        id: pollTimer
        interval: root.isRecording ? root.pollIntervalRecording : root.pollIntervalIdle
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

    Process {
        id: statusProcess
        command: ["systemctl", "--user", "is-active", "hyprwhspr.service"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let status = text.trim()
                if (status === "active") {
                    root.isServiceRunning = true
                    root.errorMessage = ""
                } else {
                    root.isServiceRunning = false
                    root.errorMessage = status === "inactive" ? "Service stopped" : "Service unavailable"
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim() !== "") {
                    root.isServiceRunning = false
                    root.errorMessage = "Service check failed"
                }
            }
        }
    }

    Process {
        id: configProcess
        command: ["cat", root.configFilePath]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let config = JSON.parse(text)
                    if (config.recording_mode !== undefined) {
                        root.currentMode = config.recording_mode
                    }
                    if (config.model !== undefined) {
                        root.backendInfo = config.model
                    }
                    if (config.transcription_backend !== undefined) {
                        root.backendInfo = config.transcription_backend + "/" + (config.model || "default")
                    }
                } catch (e) {
                    // Config file might not exist yet
                }
            }
        }
    }

    horizontalBarPill: Component {
        Item {
            id: pillItem
            implicitWidth: row.implicitWidth
            implicitHeight: row.implicitHeight

            Row {
                id: row
                spacing: Theme.spacingS

                DankIcon {
                    id: micIcon
                    name: root.errorMessage ? "mic_off" : (root.isRecording ? "mic" : "mic_none")
                    size: Theme.iconSize - 6
                    color: root.isSlideoutVisible ? Theme.primary : root.currentColor
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        running: root.isRecording && root.pulseAnimation
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                    }
                }

                StyledText {
                    visible: root.showStatusText
                    text: root.statusText
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.currentColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Timer {
                id: longPressTimer
                interval: root.longPressThreshold
                repeat: false
                onTriggered: {
                    root.isPushToTalkActive = true
                    root.startRecording()
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        longPressTimer.start()
                    }
                }

                onReleased: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        longPressTimer.stop()
                        if (root.isPushToTalkActive) {
                            root.stopRecording()
                            root.isPushToTalkActive = false
                        }
                    }
                }

                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        hyprwhsprSlideout.toggle()
                    } else if (mouse.button === Qt.LeftButton && !root.isPushToTalkActive) {
                        root.toggleRecording()
                    }
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: col.implicitWidth
            implicitHeight: col.implicitHeight

            Column {
                id: col
                spacing: Theme.spacingXS

                DankIcon {
                    id: micIconV
                    name: root.errorMessage ? "mic_off" : (root.isRecording ? "mic" : "mic_none")
                    size: Theme.iconSize - 8
                    color: root.isSlideoutVisible ? Theme.primary : root.currentColor
                    anchors.horizontalCenter: parent.horizontalCenter

                    SequentialAnimation on opacity {
                        running: root.isRecording && root.pulseAnimation
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                    }
                }

                StyledText {
                    visible: root.showStatusText && root.isRecording
                    text: "REC"
                    font.pixelSize: Theme.fontSizeSmall
                    color: root.recordingColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Timer {
                id: longPressTimerV
                interval: root.longPressThreshold
                repeat: false
                onTriggered: {
                    root.isPushToTalkActive = true
                    root.startRecording()
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        longPressTimerV.start()
                    }
                }

                onReleased: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        longPressTimerV.stop()
                        if (root.isPushToTalkActive) {
                            root.stopRecording()
                            root.isPushToTalkActive = false
                        }
                    }
                }

                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        hyprwhsprSlideout.toggle()
                    } else if (mouse.button === Qt.LeftButton && !root.isPushToTalkActive) {
                        root.toggleRecording()
                    }
                }
            }
        }
    }

    pillClickAction: () => {
        hyprwhsprSlideout.toggle()
    }

    pillRightClickAction: () => {
        root.toggleRecording()
    }

    HyprWhsprSlideout {
        id: hyprwhsprSlideout
        targetScreen: root.parentScreen
        slideoutWidth: 360
        title: "HyprWhspr"
        subtitle: root.isServiceRunning ? ("Mode: " + root.currentMode) : "Service not running"

        isRecording: root.isRecording
        isServiceRunning: root.isServiceRunning
        currentMode: root.currentMode
        lastTranscription: root.lastTranscription
        errorMessage: root.errorMessage
        backendInfo: root.backendInfo
        recordingColor: root.recordingColor
        idleColor: root.idleColor
        errorColor: root.errorColor

        onStartRecordingRequested: root.startRecording()
        onStopRecordingRequested: root.stopRecording()
        onSubmitRecordingRequested: root.submitRecording()
        onToggleRecordingRequested: root.toggleRecording()
        onRestartServiceRequested: root.restartService()
        onRefreshStatusRequested: root.refreshStatus()
    }
}
