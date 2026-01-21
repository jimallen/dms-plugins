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

    Ref {
        service: WeatherService
    }

    readonly property color timeColor: pluginData.timeColor || "#d8bbf2"
    readonly property color dateColor: pluginData.dateColor || "#bcc2ff"
    readonly property color weatherColor: pluginData.weatherColor || "#cac1e9"
    readonly property bool showWeather: pluginData.showWeather !== undefined ? pluginData.showWeather : true
    readonly property bool useDynamicTempColor: pluginData.dynamicTempColor !== undefined ? pluginData.dynamicTempColor : true
    readonly property bool useDynamicIconColor: pluginData.dynamicIconColor !== undefined ? pluginData.dynamicIconColor : true

    function getTempColor(tempC) {
        if (tempC === null || tempC === undefined) return weatherColor;
        // Cold: blue, Cool: cyan, Mild: green, Warm: yellow, Hot: orange, Very hot: red
        if (tempC <= 0) return "#7eb8da";       // Freezing - icy blue
        if (tempC <= 10) return "#88c4ea";      // Cold - light blue
        if (tempC <= 15) return "#7ddfc3";      // Cool - cyan/teal
        if (tempC <= 20) return "#98e089";      // Mild - green
        if (tempC <= 25) return "#d4e157";      // Warm - yellow-green
        if (tempC <= 30) return "#ffca28";      // Hot - yellow/orange
        if (tempC <= 35) return "#ffa726";      // Very hot - orange
        return "#ff7043";                        // Extreme - red-orange
    }

    function getConditionColor(wCode) {
        if (wCode === null || wCode === undefined) return weatherColor;
        // WMO Weather codes
        // 0: Clear sky
        if (wCode === 0) return "#ffd54f";      // Sunny - yellow
        // 1-3: Partly cloudy
        if (wCode <= 3) return "#b0bec5";       // Cloudy - gray-blue
        // 45, 48: Fog
        if (wCode === 45 || wCode === 48) return "#90a4ae";  // Fog - muted gray
        // 51-57: Drizzle
        if (wCode >= 51 && wCode <= 57) return "#4fc3f7";    // Drizzle - light blue
        // 61-67: Rain
        if (wCode >= 61 && wCode <= 67) return "#29b6f6";    // Rain - blue
        // 71-77: Snow
        if (wCode >= 71 && wCode <= 77) return "#e0e0e0";    // Snow - white/light gray
        // 80-82: Rain showers
        if (wCode >= 80 && wCode <= 82) return "#42a5f5";    // Showers - blue
        // 85-86: Snow showers
        if (wCode >= 85 && wCode <= 86) return "#b3e5fc";    // Snow showers - icy blue
        // 95-99: Thunderstorm
        if (wCode >= 95 && wCode <= 99) return "#ab47bc";    // Thunderstorm - purple
        return weatherColor;
    }

    readonly property color dynamicTempColor: {
        if (!useDynamicTempColor) return weatherColor;
        if (!WeatherService.weather || !WeatherService.weather.available) return weatherColor;
        return getTempColor(WeatherService.weather.temp);
    }

    readonly property color dynamicIconColor: {
        if (!useDynamicIconColor) return weatherColor;
        if (!WeatherService.weather || !WeatherService.weather.available) return weatherColor;
        return getConditionColor(WeatherService.weather.wCode);
    }

    // Track which section was clicked (0 = date/time, 1 = weather)
    property int clickedSection: 0

    // Use pill's position handling - accepts (x, y, width, section, screen) from PluginComponent
    pillClickAction: (x, y, width, section, screen) => {
        const tabIndex = root.clickedSection === 1 ? (SettingsData.weatherEnabled ? 3 : 0) : 0;
        const barPosition = root.axis?.edge === "left" ? 2 : (root.axis?.edge === "right" ? 3 : (root.axis?.edge === "top" ? 0 : 1));

        if (PopoutService.dankDashPopout) {
            PopoutService.dankDashPopout.setTriggerPosition(x, y, width, section, screen, barPosition, root.barThickness, root.barSpacing, root.barConfig);
            PopoutService.toggleDankDash(tabIndex);
        } else {
            // Store for repositioning after IPC
            root.pendingX = x;
            root.pendingY = y;
            root.pendingWidth = width;
            root.pendingSection = section;
            root.pendingScreen = screen;
            root.pendingBarPosition = barPosition;
            root.pendingTabIndex = tabIndex;
            root.pendingOpen = true;
            Quickshell.execDetached(["dms", "ipc", "call", "dash", "toggle", "calendar"]);
        }
    }

    // Position storage for first-time activation
    property real pendingX: 0
    property real pendingY: 0
    property real pendingWidth: 0
    property string pendingSection: "center"
    property var pendingScreen: null
    property int pendingBarPosition: 0
    property int pendingTabIndex: 0
    property bool pendingOpen: false

    // Watch for dankDashPopout becoming available
    Connections {
        target: PopoutService
        function onDankDashPopoutChanged() {
            if (PopoutService.dankDashPopout && root.pendingOpen) {
                root.pendingOpen = false;
                PopoutService.dankDashPopout.dashVisible = false;
                Qt.callLater(() => {
                    PopoutService.dankDashPopout.setTriggerPosition(
                        root.pendingX, root.pendingY, root.pendingWidth,
                        root.pendingSection, root.pendingScreen,
                        root.pendingBarPosition, root.barThickness, root.barSpacing, root.barConfig
                    );
                    PopoutService.dankDashPopout.currentTabIndex = root.pendingTabIndex;
                    PopoutService.dankDashPopout.dashVisible = true;
                });
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            id: row
            spacing: Theme.spacingS

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            // Time and Date section - opens calendar
            Item {
                width: dateRow.width
                height: dateRow.height

                Row {
                    id: dateRow
                    spacing: Theme.spacingS

                    StyledText {
                        id: timeText
                        text: clock.date ? Qt.formatTime(clock.date, "h:mm AP") : ""
                        font.pixelSize: Theme.fontSizeMedium
                        color: root.timeColor
                    }

                    StyledText {
                        text: "•"
                        font.pixelSize: Theme.fontSizeSmall
                        color: "#908f9c"
                    }

                    StyledText {
                        id: dateText
                        text: clock.date ? Qt.formatDate(clock.date, "dddd, MMMM d") : ""
                        font.pixelSize: Theme.fontSizeMedium
                        color: root.dateColor
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: root.clickedSection = 0  // Calendar
                }
            }

            StyledText {
                id: weatherSep
                visible: root.showWeather && SettingsData.weatherEnabled && WeatherService.weather
                text: "•"
                font.pixelSize: Theme.fontSizeSmall
                color: "#908f9c"
            }

            // Weather section - opens weather tab
            Item {
                visible: root.showWeather && SettingsData.weatherEnabled && WeatherService.weather
                width: weatherRow.width
                height: weatherRow.height

                Row {
                    id: weatherRow
                    spacing: Theme.spacingXS

                    DankIcon {
                        id: weatherIcon
                        name: WeatherService.weather ? WeatherService.getWeatherIcon(WeatherService.weather.wCode) : "cloud"
                        size: Theme.iconSize - 6
                        color: root.dynamicIconColor
                    }

                    StyledText {
                        id: tempText
                        text: {
                            if (!WeatherService.weather || !WeatherService.weather.available) return "--°C";
                            var temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                            return temp + "°" + (SettingsData.useFahrenheit ? "F" : "C");
                        }
                        font.pixelSize: Theme.fontSizeMedium
                        color: root.dynamicTempColor
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: root.clickedSection = 1  // Weather
                }
            }
        }
    }

    verticalBarPill: Component {
        Column {
            id: col
            spacing: Theme.spacingXS

            SystemClock {
                id: clockV
                precision: SystemClock.Minutes
            }

            // Time and Date section - opens calendar
            Item {
                width: dateCol.width
                height: dateCol.height
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    id: dateCol
                    spacing: Theme.spacingXS

                    StyledText {
                        text: clockV.date ? Qt.formatTime(clockV.date, "hh:mm") : ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.timeColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: clockV.date ? Qt.formatDate(clockV.date, "M/d") : ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.dateColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: root.clickedSection = 0  // Calendar
                }
            }

            // Weather section - opens weather tab
            Item {
                visible: root.showWeather && SettingsData.weatherEnabled && WeatherService.weather
                width: weatherCol.width
                height: weatherCol.height
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    id: weatherCol
                    spacing: Theme.spacingXS

                    DankIcon {
                        name: WeatherService.weather ? WeatherService.getWeatherIcon(WeatherService.weather.wCode) : "cloud"
                        size: Theme.iconSize - 8
                        color: root.dynamicIconColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: {
                            if (!WeatherService.weather || !WeatherService.weather.available) return "--°";
                            var temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                            return temp + "°";
                        }
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.dynamicTempColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: root.clickedSection = 1  // Weather
                }
            }
        }
    }
}
