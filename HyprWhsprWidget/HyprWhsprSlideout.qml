import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

pragma ComponentBehavior: Bound

PanelWindow {
    id: root

    property string layerNamespace: "dms:hyprwhspr-slideout"
    WlrLayershell.namespace: layerNamespace

    property bool isVisible: false
    property var targetScreen: null
    property real slideoutWidth: 360
    property string title: "HyprWhspr"
    property string subtitle: ""

    property bool isRecording: false
    property bool isServiceRunning: false
    property string currentMode: "toggle"
    property string lastTranscription: ""
    property string errorMessage: ""
    property string backendInfo: ""
    property color recordingColor: "#ef5350"
    property color idleColor: "#90a4ae"
    property color errorColor: "#ffb4ab"

    signal startRecordingRequested()
    signal stopRecordingRequested()
    signal submitRecordingRequested()
    signal toggleRecordingRequested()
    signal restartServiceRequested()
    signal refreshStatusRequested()

    function show() {
        visible = true
        isVisible = true
    }

    function hide() {
        isVisible = false
    }

    function toggle() {
        if (isVisible) {
            hide()
        } else {
            show()
        }
    }

    visible: isVisible
    screen: targetScreen

    anchors.top: true
    anchors.bottom: true
    anchors.right: true

    implicitWidth: slideoutWidth
    implicitHeight: targetScreen ? targetScreen.height : 800

    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: isVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    readonly property real dpr: CompositorService.getScreenScale(root.screen)
    readonly property real alignedWidth: Theme.px(slideoutWidth, dpr)
    readonly property real alignedHeight: Theme.px(targetScreen ? targetScreen.height : 800, dpr)

    mask: Region {
        item: Rectangle {
            x: root.width - alignedWidth
            y: 0
            width: alignedWidth
            height: root.height
        }
    }

    Item {
        id: slideContainer
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: alignedWidth
        height: alignedHeight

        property real slideOffset: alignedWidth

        Connections {
            target: root
            function onIsVisibleChanged() {
                slideContainer.slideOffset = root.isVisible ? 0 : slideContainer.width
            }
        }

        Behavior on slideOffset {
            NumberAnimation {
                id: slideAnimation
                duration: 450
                easing.type: Easing.OutCubic

                onRunningChanged: {
                    if (!running && !root.isVisible) {
                        root.visible = false
                    }
                }
            }
        }

        Item {
            id: contentRect
            layer.enabled: Quickshell.env("DMS_DISABLE_LAYER") !== "true" && Quickshell.env("DMS_DISABLE_LAYER") !== "1"
            layer.smooth: false
            layer.textureSize: Qt.size(width * root.dpr, height * root.dpr)
            opacity: SettingsData.popupTransparency

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            x: Theme.snap(slideContainer.slideOffset, root.dpr)

            Rectangle {
                anchors.fill: parent
                color: Theme.surfaceContainer
                radius: Theme.cornerRadius
            }

            Column {
                id: headerColumn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    height: 32

                    Column {
                        width: parent.width - closeButton.width
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: root.title
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        StyledText {
                            visible: root.subtitle !== ""
                            text: root.subtitle
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }

                    DankActionButton {
                        id: closeButton
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: root.hide()
                    }
                }
            }

            Column {
                id: mainContent
                anchors.top: headerColumn.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: Theme.spacingM
                anchors.leftMargin: Theme.spacingL
                anchors.rightMargin: Theme.spacingL
                anchors.bottomMargin: Theme.spacingL
                spacing: Theme.spacingM

                Rectangle {
                    width: parent.width
                    height: statusSection.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

                    Column {
                        id: statusSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        Row {
                            spacing: Theme.spacingS

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: root.isServiceRunning ?
                                    (root.isRecording ? root.recordingColor : "#4caf50") :
                                    root.errorColor
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: root.isRecording
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 500 }
                                    NumberAnimation { to: 1.0; duration: 500 }
                                }
                            }

                            StyledText {
                                text: root.isServiceRunning ?
                                    (root.isRecording ? "Recording" : "Service Running") :
                                    "Service Not Running"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }
                        }

                        Row {
                            spacing: Theme.spacingM

                            Row {
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "tune"
                                    size: 14
                                    color: Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: "Mode: " + root.currentMode
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }

                            Row {
                                visible: root.backendInfo !== ""
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "memory"
                                    size: 14
                                    color: Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: root.backendInfo
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }
                        }

                        Row {
                            visible: root.errorMessage !== ""
                            spacing: Theme.spacingXS

                            DankIcon {
                                name: "warning"
                                size: 14
                                color: root.errorColor
                            }

                            StyledText {
                                text: root.errorMessage
                                font.pixelSize: Theme.fontSizeSmall
                                color: root.errorColor
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: controlSection.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

                    Column {
                        id: controlSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingM

                        StyledText {
                            text: "Recording Controls"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Rectangle {
                                id: recordButton
                                width: (parent.width - Theme.spacingS) / 2
                                height: 48
                                radius: Theme.cornerRadius
                                color: recordArea.containsMouse ?
                                    Qt.lighter(root.isRecording ? root.errorColor : root.recordingColor, 1.1) :
                                    (root.isRecording ? root.errorColor : root.recordingColor)

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    DankIcon {
                                        name: root.isRecording ? "stop" : "mic"
                                        size: 20
                                        color: "#1a1a1a"
                                    }

                                    StyledText {
                                        text: root.isRecording ? "Stop" : "Record"
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: "#1a1a1a"
                                    }
                                }

                                MouseArea {
                                    id: recordArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.isRecording) {
                                            root.stopRecordingRequested()
                                        } else {
                                            root.startRecordingRequested()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: submitButton
                                width: (parent.width - Theme.spacingS) / 2
                                height: 48
                                radius: Theme.cornerRadius
                                color: submitArea.containsMouse ?
                                    Qt.lighter(Theme.primary, 1.1) : Theme.primary
                                opacity: root.isRecording ? 1.0 : 0.5

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    DankIcon {
                                        name: "send"
                                        size: 20
                                        color: Theme.onPrimary
                                    }

                                    StyledText {
                                        text: "Submit"
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: Theme.onPrimary
                                    }
                                }

                                MouseArea {
                                    id: submitArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: root.isRecording ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    enabled: root.isRecording
                                    onClicked: root.submitRecordingRequested()
                                }
                            }
                        }

                        StyledText {
                            text: "Click to toggle recording. Long-press on bar icon for push-to-talk."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    visible: root.lastTranscription !== ""
                    width: parent.width
                    height: transcriptionSection.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

                    Column {
                        id: transcriptionSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Last Transcription"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            Item { width: parent.width - copyButton.width - 120; height: 1 }

                            Rectangle {
                                id: copyButton
                                width: 70
                                height: 24
                                radius: Theme.cornerRadius / 2
                                color: copyArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingXS

                                    DankIcon {
                                        name: "content_copy"
                                        size: 12
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: "Copy"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                    }
                                }

                                MouseArea {
                                    id: copyArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.execDetached(["wl-copy", root.lastTranscription])
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: transcriptionText.implicitHeight + Theme.spacingS * 2
                            radius: Theme.cornerRadius / 2
                            color: Theme.withAlpha(Theme.surfaceContainer, 0.5)

                            StyledText {
                                id: transcriptionText
                                anchors.fill: parent
                                anchors.margins: Theme.spacingS
                                text: root.lastTranscription
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                wrapMode: Text.WordWrap
                                maximumLineCount: 5
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: actionsSection.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

                    Column {
                        id: actionsSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Quick Actions"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        Row {
                            spacing: Theme.spacingS

                            Rectangle {
                                id: restartButton
                                width: 110
                                height: 36
                                radius: Theme.cornerRadius
                                color: restartArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingXS

                                    DankIcon {
                                        name: "restart_alt"
                                        size: 16
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: "Restart"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                    }
                                }

                                MouseArea {
                                    id: restartArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.restartServiceRequested()
                                }
                            }

                            Rectangle {
                                id: configButton
                                width: 110
                                height: 36
                                radius: Theme.cornerRadius
                                color: configArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingXS

                                    DankIcon {
                                        name: "settings"
                                        size: 16
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: "Config"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                    }
                                }

                                MouseArea {
                                    id: configArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let configPath = Quickshell.env("HOME") + "/.config/hyprwhspr"
                                        Qt.openUrlExternally("file://" + configPath)
                                    }
                                }
                            }

                            Rectangle {
                                id: refreshButton
                                width: 110
                                height: 36
                                radius: Theme.cornerRadius
                                color: refreshArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingXS

                                    DankIcon {
                                        name: "refresh"
                                        size: 16
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: "Refresh"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                    }
                                }

                                MouseArea {
                                    id: refreshArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.refreshStatusRequested()
                                }
                            }
                        }
                    }
                }

                Item { height: 1; width: 1 }
            }
        }
    }
}
