import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property var popoutService: null

    readonly property int refreshMinutes: pluginData.refreshMinutes || 5
    readonly property bool showCountdown: pluginData.showCountdown !== undefined ? pluginData.showCountdown : true
    readonly property color meetingColor: pluginData.meetingColor || "#a6c8ff"
    readonly property color oneOnOneColor: pluginData.oneOnOneColor || "#c3e88d"
    readonly property color conflictColor: pluginData.conflictColor || "#ffb4ab"
    readonly property color noMeetingColor: pluginData.noMeetingColor || "#90a4ae"

    property var events: []
    property var nextEvent: null
    property bool loading: false
    property bool configured: false
    property string errorMessage: ""

    function getEventColor(event) {
        if (!event) return noMeetingColor
        if (event.hasConflict) return conflictColor
        if (event.attendeeCount === 1) return oneOnOneColor
        return meetingColor
    }

    function refresh() {
        if (eventsProcess.running) return
        loading = true
        eventsProcess.running = true
    }

    function getTimeUntil(startTime) {
        let start = new Date(startTime)
        let now = new Date()
        let diff = start - now

        if (diff < 0) return "now"

        let hours = Math.floor(diff / (1000 * 60 * 60))
        let minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))

        if (hours > 0) return hours + "h " + minutes + "m"
        return minutes + "m"
    }

    function formatTime(isoTime) {
        let d = new Date(isoTime)
        return Qt.formatTime(d, "h:mm AP")
    }

    function findNextEvent() {
        let now = new Date()
        for (let e of events) {
            let end = new Date(e.end)
            if (end > now) {
                nextEvent = e
                return
            }
        }
        nextEvent = null
    }

    function joinMeeting(url) {
        if (url) Qt.openUrlExternally(url)
    }

    Component.onCompleted: {
        statusProcess.running = true
    }

    Timer {
        interval: root.refreshMinutes * 60 * 1000
        running: root.configured
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        interval: 60000
        running: root.configured && root.showCountdown
        repeat: true
        onTriggered: root.findNextEvent()
    }

    Process {
        id: statusProcess
        command: ["gcal", "status"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let result = JSON.parse(text)
                    root.configured = result.configured && result.authorized
                    if (root.configured) {
                        root.refresh()
                    } else {
                        root.errorMessage = result.message || "Not configured"
                    }
                } catch (e) {
                    root.errorMessage = "Failed to parse status"
                }
            }
        }
    }

    Process {
        id: eventsProcess
        command: ["gcal", "events"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                try {
                    let result = JSON.parse(text)
                    if (result.success) {
                        root.events = result.events || []
                        root.errorMessage = ""
                        root.findNextEvent()
                    } else {
                        root.errorMessage = result.message || result.error
                    }
                } catch (e) {
                    root.errorMessage = "Failed to parse events"
                }
            }
        }
    }

    readonly property bool showMeetingsTab: pluginData.showMeetingsTab !== undefined ? pluginData.showMeetingsTab : true

    pillClickAction: (x, y, width, section, screen) => {
        const tabIndex = showMeetingsTab ? 3 : 0
        popoutService?.toggleDankDash(tabIndex, x, y, width, section, screen)
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
                    name: root.nextEvent ? "event" : "event_busy"
                    size: Theme.iconSize - 6
                    color: root.getEventColor(root.nextEvent)
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    visible: !root.configured
                    text: "Not configured"
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.noMeetingColor
                }

                StyledText {
                    visible: root.configured && root.loading
                    text: "Loading..."
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.noMeetingColor
                }

                StyledText {
                    visible: root.configured && !root.loading && !root.nextEvent
                    text: "No meetings"
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.noMeetingColor
                }

                StyledText {
                    visible: root.configured && !root.loading && root.nextEvent
                    text: {
                        if (!root.nextEvent) return ""
                        let countdown = root.showCountdown ? " in " + root.getTimeUntil(root.nextEvent.start) : ""
                        let title = root.nextEvent.title
                        if (title.length > 20) title = title.substring(0, 18) + "..."
                        return title + countdown
                    }
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.getEventColor(root.nextEvent)
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
                    name: root.nextEvent ? "event" : "event_busy"
                    size: Theme.iconSize - 8
                    color: root.nextEvent?.hasConflict ? root.conflictColor :
                           root.nextEvent ? root.meetingColor : root.noMeetingColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    visible: root.configured && !root.loading && root.nextEvent && root.showCountdown
                    text: root.nextEvent ? root.getTimeUntil(root.nextEvent.start) : ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: root.nextEvent?.hasConflict ? root.conflictColor : root.meetingColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    visible: root.configured && !root.loading && root.events.length > 0
                    text: root.events.length.toString()
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
