import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "meetingWidget"

    StyledText {
        width: parent.width
        text: "Display Options"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "showCountdown"
        label: "Show Countdown"
        description: "Display time until next meeting in the bar"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "refreshMinutes"
        label: "Refresh Interval"
        description: "How often to fetch calendar updates (minutes)"
        defaultValue: 5
        minimum: 1
        maximum: 30
        unit: " min"
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
        settingKey: "meetingColor"
        label: "Meeting Color"
        description: "Color for upcoming meetings"
        defaultValue: "#a6c8ff"
    }

    ColorSetting {
        settingKey: "conflictColor"
        label: "Conflict Color"
        description: "Color for conflicting meetings"
        defaultValue: "#ffb4ab"
    }

    ColorSetting {
        settingKey: "noMeetingColor"
        label: "No Meeting Color"
        description: "Color when no meetings are scheduled"
        defaultValue: "#90a4ae"
    }

    StyledText {
        width: parent.width
        text: "Google Calendar Setup"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    Rectangle {
        width: parent.width
        height: oauthColumn.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

        Column {
            id: oauthColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            StyledText {
                width: parent.width
                text: "1. Create Google OAuth Credentials"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                width: parent.width
                text: "Go to console.cloud.google.com and create a project, then:"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width
                leftPadding: Theme.spacingM
                spacing: 4

                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Enable the Google Calendar API"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Configure OAuth consent screen (External, add your email as test user)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Add scope: .../auth/calendar.readonly"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Create OAuth 2.0 Client ID (Desktop app type)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Add redirect URI: http://localhost:<port>/callback"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "  (default port: 8085, configurable via --port flag)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Qt.rgba(Theme.surfaceVariantText.r, Theme.surfaceVariantText.g, Theme.surfaceVariantText.b, 0.7)
                    wrapMode: Text.WordWrap
                }
                StyledText {
                    width: parent.width - Theme.spacingM
                    text: "• Download JSON and save to ~/.config/gcal/gcal-credentials.json"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: setupColumn.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)

        Column {
            id: setupColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            StyledText {
                width: parent.width
                text: "2. Authenticate"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            Row {
                spacing: Theme.spacingS
                DankIcon {
                    name: "login"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "gcal auth"
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "— Connect to Google Calendar"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: Theme.spacingS
                DankIcon {
                    name: "info"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "gcal status"
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "— Check connection status"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: Theme.spacingS
                DankIcon {
                    name: "logout"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "gcal logout"
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "— Disconnect account"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { height: Theme.spacingXS; width: 1 }

            StyledText {
                width: parent.width
                text: "The auth command opens a browser for Google OAuth. Grant calendar access and paste the code back in the terminal."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
            }
        }
    }
}
