import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "centerWidget"

    StyledText {
        width: parent.width
        text: "Display Options"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "showDate"
        label: "Show Date"
        description: "Display the date alongside the time"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showWeather"
        label: "Show Weather"
        description: "Display weather information"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showSeconds"
        label: "Show Seconds"
        description: "Display seconds in the time"
        defaultValue: false
    }

    StyledText {
        width: parent.width
        text: "Dynamic Colors"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    ToggleSetting {
        settingKey: "dynamicTempColor"
        label: "Dynamic Temperature Color"
        description: "Temperature changes color based on value (cold=blue, hot=red)"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "dynamicIconColor"
        label: "Dynamic Icon Color"
        description: "Icon changes color based on conditions (sunny=yellow, rain=blue)"
        defaultValue: true
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
        settingKey: "timeColor"
        label: "Time Color"
        description: "Color for the time display"
        defaultValue: "#d8bbf2"
    }

    ColorSetting {
        settingKey: "dateColor"
        label: "Date Color"
        description: "Color for the date display"
        defaultValue: "#bcc2ff"
    }

    ColorSetting {
        settingKey: "weatherColor"
        label: "Weather Color"
        description: "Fallback color when dynamic colors are disabled"
        defaultValue: "#cac1e9"
    }

    ColorSetting {
        settingKey: "separatorColor"
        label: "Separator Color"
        description: "Color for the dot separators"
        defaultValue: "#908f9c"
    }

    StyledText {
        width: parent.width
        text: "Note: Time format and date format are controlled in Settings > Clock. Weather location is controlled in Settings > Weather."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
        topPadding: Theme.spacingM
    }
}
