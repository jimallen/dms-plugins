import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "hyprwhsprWidget"

    StyledText {
        width: parent.width
        text: "Display Options"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "showStatusText"
        label: "Show Status Text"
        description: "Display status text (Recording/Ready) next to the icon in the bar"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "pulseAnimation"
        label: "Pulse Animation"
        description: "Enable pulsing animation on the icon while recording"
        defaultValue: true
    }

    StyledText {
        width: parent.width
        text: "Behavior"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    SliderSetting {
        settingKey: "longPressThreshold"
        label: "Push-to-Talk Threshold"
        description: "How long to hold before entering push-to-talk mode (milliseconds)"
        defaultValue: 500
        minimum: 200
        maximum: 1500
        unit: " ms"
    }

    SliderSetting {
        settingKey: "pollInterval"
        label: "Status Poll Interval"
        description: "How often to check hyprwhspr status when idle (seconds)"
        defaultValue: 10
        minimum: 2
        maximum: 60
        unit: " sec"
    }

    StyledText {
        width: parent.width
        text: "Colors"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    ColorSetting {
        settingKey: "recordingColor"
        label: "Recording Color"
        description: "Color displayed while actively recording"
        defaultValue: "#ef5350"
    }

    ColorSetting {
        settingKey: "idleColor"
        label: "Idle Color"
        description: "Color displayed when ready and not recording"
        defaultValue: "#90a4ae"
    }

    ColorSetting {
        settingKey: "errorColor"
        label: "Error Color"
        description: "Color displayed when service is unavailable or errored"
        defaultValue: "#ffb4ab"
    }

    StyledText {
        width: parent.width
        text: "About HyprWhspr"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    Rectangle {
        width: parent.width
        height: aboutColumn.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

        Column {
            id: aboutColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            StyledText {
                width: parent.width
                text: "HyprWhspr is a speech-to-text tool for Hyprland."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
            }

            StyledText {
                width: parent.width
                text: "Controls:"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            Column {
                width: parent.width
                leftPadding: Theme.spacingM
                spacing: 4

                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Click: Toggle recording (start/submit)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Long-press: Push-to-talk (record while held)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Right-click: Open slideout panel"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }
            }

            Item { height: Theme.spacingXS; width: 1 }

            StyledText {
                width: parent.width
                text: "Service Commands:"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            Column {
                width: parent.width
                leftPadding: Theme.spacingM
                spacing: 4

                Row {
                    spacing: Theme.spacingS
                    StyledText {
                        text: "hyprwhspr status"
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: "monospace"
                        color: Theme.primary
                    }
                    StyledText {
                        text: "— Check service health"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }

                Row {
                    spacing: Theme.spacingS
                    StyledText {
                        text: "hyprwhspr state show"
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: "monospace"
                        color: Theme.primary
                    }
                    StyledText {
                        text: "— Current state"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }

                Row {
                    spacing: Theme.spacingS
                    StyledText {
                        text: "systemctl --user status hyprwhspr"
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: "monospace"
                        color: Theme.primary
                    }
                }
            }
        }
    }
}
