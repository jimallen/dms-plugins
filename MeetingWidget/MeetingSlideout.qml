import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

pragma ComponentBehavior: Bound

PanelWindow {
    id: root

    property string layerNamespace: "dms:meeting-slideout"
    WlrLayershell.namespace: layerNamespace

    property bool isVisible: false
    property var targetScreen: null
    property real slideoutWidth: 380
    property string title: "Upcoming Meetings"
    property string subtitle: ""
    default property alias content: contentContainer.data

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

            Item {
                id: contentContainer
                anchors.top: headerColumn.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: Theme.spacingM
                anchors.leftMargin: Theme.spacingL
                anchors.rightMargin: Theme.spacingL
                anchors.bottomMargin: Theme.spacingL
            }
        }
    }
}
