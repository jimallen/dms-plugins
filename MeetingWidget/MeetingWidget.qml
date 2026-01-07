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

    readonly property int refreshMinutes: pluginData.refreshMinutes || 5
    readonly property bool showCountdown: pluginData.showCountdown !== undefined ? pluginData.showCountdown : true
    readonly property bool showNextMeetingInBar: pluginData.showNextMeetingInBar !== undefined ? pluginData.showNextMeetingInBar : true
    readonly property bool showCountdownInBar: pluginData.showCountdownInBar !== undefined ? pluginData.showCountdownInBar : false
    readonly property color meetingColor: pluginData.meetingColor || "#a6c8ff"
    readonly property color oneOnOneColor: pluginData.oneOnOneColor || "#c3e88d"
    readonly property color conflictColor: pluginData.conflictColor || "#ffb4ab"
    readonly property color noMeetingColor: pluginData.noMeetingColor || "#90a4ae"
    readonly property bool isSlideoutVisible: meetingSlideout.isVisible

    property var events: []
    property var nextEvent: null
    property bool loading: false
    property bool configured: false
    property string errorMessage: ""
    property date lastRefresh: new Date(0)

    readonly property string statusText: {
        if (!configured) return "Not configured"
        if (loading) return "Refreshing..."
        if (errorMessage) return "Error"
        return "Connected"
    }

    readonly property color statusColor: {
        if (!configured) return noMeetingColor
        if (loading) return meetingColor
        if (errorMessage) return conflictColor
        return oneOnOneColor
    }

    readonly property string lastRefreshText: {
        void lastRefreshTick
        if (lastRefresh.getTime() === 0) return "Never"
        let now = new Date()
        let diff = now - lastRefresh
        let minutes = Math.floor(diff / (1000 * 60))
        if (minutes < 1) return "Just now"
        if (minutes === 1) return "1 min ago"
        if (minutes < 60) return minutes + " mins ago"
        let hours = Math.floor(minutes / 60)
        if (hours === 1) return "1 hour ago"
        return hours + " hours ago"
    }

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

        let days = Math.floor(diff / (1000 * 60 * 60 * 24))
        let hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
        let minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))

        if (days > 0) return days + "d " + hours + "h"
        if (hours > 0) return hours + "h " + minutes + "m"
        return minutes + "m"
    }

    function formatTime(isoTime) {
        let d = new Date(isoTime)
        return Qt.formatTime(d, SettingsData.use24HourClock ? "HH:mm" : "h:mm AP")
    }

    function formatDate(isoTime) {
        let d = new Date(isoTime)
        return Qt.formatDate(d, "ddd, MMM d")
    }

    function getDateKey(isoTime) {
        let d = new Date(isoTime)
        return Qt.formatDate(d, "yyyy-MM-dd")
    }

    function isSameDay(isoTime1, isoTime2) {
        return getDateKey(isoTime1) === getDateKey(isoTime2)
    }

    function formatDateHeader(isoTime) {
        let d = new Date(isoTime)
        let today = new Date()
        let tomorrow = new Date(today)
        tomorrow.setDate(tomorrow.getDate() + 1)

        if (getDateKey(isoTime) === getDateKey(today.toISOString())) {
            return "Today"
        } else if (getDateKey(isoTime) === getDateKey(tomorrow.toISOString())) {
            return "Tomorrow"
        } else {
            return Qt.formatDate(d, "dddd, MMM d")
        }
    }

    function getDuration(startTime, endTime) {
        let start = new Date(startTime)
        let end = new Date(endTime)
        let diff = end - start
        let minutes = Math.floor(diff / (1000 * 60))
        if (minutes >= 60) {
            let hours = Math.floor(minutes / 60)
            let mins = minutes % 60
            return mins > 0 ? hours + "h " + mins + "m" : hours + "h"
        }
        return minutes + "m"
    }

    function isEventPast(event) {
        if (!event || !event.end) return false
        return new Date(event.end) < new Date()
    }

    function isNextMeeting(event) {
        return nextEvent && event && nextEvent.id === event.id
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

    property int lastRefreshTick: 0
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.lastRefreshTick++
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
        command: ["gcal", "events", "-d", "14"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                try {
                    let result = JSON.parse(text)
                    if (result.success) {
                        root.events = result.events || []
                        root.errorMessage = ""
                        root.lastRefresh = new Date()
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
                    color: root.isSlideoutVisible ? Theme.primary : root.getEventColor(root.nextEvent)
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    visible: root.showNextMeetingInBar && !root.configured
                    text: "Not configured"
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.noMeetingColor
                }

                StyledText {
                    visible: root.showNextMeetingInBar && root.configured && root.loading
                    text: "Loading..."
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.noMeetingColor
                }

                StyledText {
                    visible: root.showNextMeetingInBar && root.configured && !root.loading && !root.nextEvent
                    text: "No meetings"
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.noMeetingColor
                }

                StyledText {
                    visible: root.showNextMeetingInBar && root.configured && !root.loading && root.nextEvent
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

                StyledText {
                    visible: !root.showNextMeetingInBar && root.showCountdownInBar && root.configured && !root.loading && root.nextEvent
                    text: root.nextEvent ? root.getTimeUntil(root.nextEvent.start) : ""
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
                    color: root.isSlideoutVisible ? Theme.primary :
                           (root.nextEvent?.hasConflict ? root.conflictColor :
                           root.nextEvent ? root.meetingColor : root.noMeetingColor)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    visible: (root.showNextMeetingInBar && root.showCountdown || root.showCountdownInBar) && root.configured && !root.loading && root.nextEvent
                    text: root.nextEvent ? root.getTimeUntil(root.nextEvent.start) : ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: root.nextEvent?.hasConflict ? root.conflictColor : root.meetingColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    visible: root.showNextMeetingInBar && root.configured && !root.loading && root.events.length > 0
                    text: root.events.length.toString()
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    pillRightClickAction: () => {
        root.refresh()
    }

    pillClickAction: () => {
        meetingSlideout.toggle()
    }

    MeetingSlideout {
        id: meetingSlideout
        targetScreen: root.parentScreen
        slideoutWidth: 380
        title: "Upcoming Meetings"
        subtitle: root.configured ?
            (root.events.length + " meetings in next 14 days") :
            "Calendar not configured"

        property int expandedIndex: -1

        Column {
            anchors.fill: parent
            spacing: Theme.spacingM

            Item {
                width: parent.width
                height: parent.height - statusRow.height - Theme.spacingM

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    clip: true

                    DankListView {
                        id: meetingsList
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        model: root.configured ? root.events : []
                        spacing: Theme.spacingXS

                        delegate: Column {
                            id: meetingDelegate

                            required property var modelData
                            required property int index

                            readonly property bool isPast: root.isEventPast(modelData)
                            readonly property bool isNext: root.isNextMeeting(modelData)
                            readonly property bool isExpanded: meetingSlideout.expandedIndex === index
                            readonly property bool showDateHeader: index === 0 || !root.isSameDay(root.events[index - 1].start, modelData.start)

                            width: meetingsList.width
                            spacing: Theme.spacingXS

                            Item {
                                visible: showDateHeader
                                width: parent.width
                                height: visible ? dateHeaderText.height + Theme.spacingS : 0

                                StyledText {
                                    id: dateHeaderText
                                    text: root.formatDateHeader(modelData.start)
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                id: meetingCard
                                width: parent.width
                                height: delegateContent.implicitHeight + Theme.spacingS * 2
                                radius: Theme.cornerRadius
                                opacity: isPast ? 0.5 : 1.0
                                color: isNext ?
                                    Qt.rgba(root.getEventColor(modelData).r, root.getEventColor(modelData).g, root.getEventColor(modelData).b, 0.15) :
                                    Theme.withAlpha(Theme.surfaceContainer, 0.5)
                                border.color: isNext ? root.getEventColor(modelData) : "transparent"
                            border.width: isNext ? 1 : 0

                            Behavior on height {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Rectangle {
                                width: 4
                                height: parent.height - Theme.spacingS
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacingXS
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 2
                                color: isPast ? Theme.surfaceVariantText : root.getEventColor(modelData)
                            }

                            Column {
                                id: delegateContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.leftMargin: Theme.spacingS + 8
                                anchors.rightMargin: Theme.spacingS
                                anchors.topMargin: Theme.spacingS
                                spacing: Theme.spacingXS

                                // Title row
                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: modelData.title || "Untitled"
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: isPast ? Theme.surfaceVariantText : Theme.surfaceText
                                        elide: Text.ElideRight
                                        width: parent.width - expandChevron.width - Theme.spacingS
                                    }

                                    DankIcon {
                                        id: expandChevron
                                        name: isExpanded ? "expand_less" : "expand_more"
                                        size: 16
                                        color: Theme.surfaceVariantText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Info row: time • attendees on left, countdown + video on right
                                Item {
                                    width: parent.width
                                    height: infoRowLeft.height

                                    Row {
                                        id: infoRowLeft
                                        spacing: Theme.spacingS

                                        StyledText {
                                            text: root.formatTime(modelData.start) + " – " + root.formatTime(modelData.end)
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            visible: modelData.attendeeCount > 0
                                            text: "•"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            visible: modelData.attendeeCount > 0
                                            text: modelData.attendeeCount === 1 ? "1:1" : (modelData.attendeeCount + " attendees")
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: modelData.attendeeCount === 1 ? root.oneOnOneColor : Theme.surfaceVariantText
                                        }
                                    }

                                    Row {
                                        anchors.right: parent.right
                                        spacing: Theme.spacingS

                                        StyledText {
                                            text: {
                                                if (isPast) return "ended"
                                                let timeUntil = root.getTimeUntil(modelData.start)
                                                return timeUntil === "now" ? "now" : timeUntil
                                            }
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: isNext ? root.getEventColor(modelData) : Theme.surfaceVariantText
                                            font.weight: isNext ? Font.Medium : Font.Normal
                                        }

                                        DankIcon {
                                            visible: modelData.meetingUrl && modelData.meetingUrl !== ""
                                            name: "videocam"
                                            size: 14
                                            color: isNext ? root.getEventColor(modelData) : Theme.surfaceVariantText
                                            anchors.verticalCenter: parent.verticalCenter

                                            MouseArea {
                                                id: joinArea
                                                anchors.fill: parent
                                                anchors.margins: -6
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: function(mouse) {
                                                    mouse.accepted = true
                                                    Qt.openUrlExternally(modelData.meetingUrl)
                                                }
                                            }
                                        }
                                    }
                                }

                                Column {
                                    id: expandedContent
                                    width: parent.width
                                    spacing: Theme.spacingS
                                    visible: isExpanded
                                    opacity: isExpanded ? 1 : 0

                                    Behavior on opacity {
                                        NumberAnimation { duration: 150 }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Theme.outlineVariant
                                        opacity: 0.3
                                    }

                                    Row {
                                        spacing: Theme.spacingM
                                        width: parent.width

                                        Column {
                                            spacing: Theme.spacingXS
                                            width: (parent.width - Theme.spacingM) / 2

                                            Row {
                                                spacing: Theme.spacingXS

                                                DankIcon {
                                                    name: "schedule"
                                                    size: 14
                                                    color: Theme.surfaceVariantText
                                                }

                                                StyledText {
                                                    text: root.formatDate(modelData.start)
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceVariantText
                                                }
                                            }

                                            Row {
                                                spacing: Theme.spacingXS

                                                DankIcon {
                                                    name: "timelapse"
                                                    size: 14
                                                    color: Theme.surfaceVariantText
                                                }

                                                StyledText {
                                                    text: root.getDuration(modelData.start, modelData.end)
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceVariantText
                                                }
                                            }
                                        }

                                        Column {
                                            spacing: Theme.spacingXS
                                            width: (parent.width - Theme.spacingM) / 2

                                            Row {
                                                spacing: Theme.spacingXS
                                                visible: modelData.hasConflict

                                                DankIcon {
                                                    name: "warning"
                                                    size: 14
                                                    color: root.conflictColor
                                                }

                                                StyledText {
                                                    text: "Has conflict"
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: root.conflictColor
                                                }
                                            }

                                        }
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: Theme.spacingXS
                                        visible: modelData.attendees && modelData.attendees.length > 0

                                        Row {
                                            spacing: Theme.spacingXS

                                            DankIcon {
                                                name: "group"
                                                size: 14
                                                color: Theme.surfaceVariantText
                                            }

                                            StyledText {
                                                text: "Attendees"
                                                font.pixelSize: Theme.fontSizeSmall
                                                font.weight: Font.Medium
                                                color: Theme.surfaceVariantText
                                            }
                                        }

                                        StyledText {
                                            width: parent.width
                                            text: modelData.attendees ? modelData.attendees.join(", ") : ""
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        id: joinButtonExpanded
                                        visible: modelData.meetingUrl && modelData.meetingUrl !== ""
                                        width: 90
                                        height: 32
                                        radius: Theme.cornerRadius
                                        color: joinAreaExpanded.containsMouse ?
                                            Qt.lighter(root.getEventColor(modelData), 1.2) :
                                            root.getEventColor(modelData)

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: Theme.spacingXS

                                            DankIcon {
                                                name: "videocam"
                                                size: 14
                                                color: Theme.surfaceContainerLowest
                                            }

                                            StyledText {
                                                text: "Join"
                                                font.pixelSize: Theme.fontSizeSmall
                                                font.weight: Font.Medium
                                                color: Theme.surfaceContainerLowest
                                            }
                                        }

                                        MouseArea {
                                            id: joinAreaExpanded
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: function(mouse) {
                                                mouse.accepted = true
                                                Qt.openUrlExternally(modelData.meetingUrl)
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: -1
                                onClicked: {
                                    if (meetingSlideout.expandedIndex === index) {
                                        meetingSlideout.expandedIndex = -1
                                    } else {
                                        meetingSlideout.expandedIndex = index
                                    }
                                }
                            }
                        }
                    }
                }

                StyledText {
                    visible: !root.configured
                    anchors.centerIn: parent
                    text: "Google Calendar not configured"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }

                StyledText {
                    visible: root.configured && root.events.length === 0 && !root.loading
                    anchors.centerIn: parent
                    text: "No upcoming meetings"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }

                StyledText {
                    visible: root.loading
                    anchors.centerIn: parent
                    text: "Loading..."
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }
            }
        }

            Row {
                id: statusRow
                width: parent.width
                spacing: Theme.spacingM

                Row {
                    id: statusInfo
                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: root.statusColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.statusText
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.statusColor
                        font.weight: Font.Medium
                    }

                    StyledText {
                        visible: root.configured && !root.loading
                        text: "• " + root.lastRefreshText
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }

                Item { height: 1; width: parent.width - statusInfo.width - refreshButton.width - Theme.spacingM * 2 }

                Rectangle {
                    id: refreshButton
                    width: 36
                    height: 36
                    radius: 18
                    color: refreshArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                    anchors.verticalCenter: parent.verticalCenter

                    DankIcon {
                        anchors.centerIn: parent
                        name: "refresh"
                        size: 18
                        color: Theme.surfaceText

                        RotationAnimator on rotation {
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                            running: root.loading
                        }
                    }

                    MouseArea {
                        id: refreshArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refresh()
                    }
                }
            }
        }
    }
}
