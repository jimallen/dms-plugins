# DMS Plugins Architecture

## Overview

This repository contains Qt/QML plugins for DankMaterialShell (DMS). Both plugins follow a component-based architecture using QML's declarative model with the DMS plugin system.

## System Architecture

```
+---------------------------+
|   DankMaterialShell       |
|   +-------------------+   |
|   |  Plugin Registry  |   |
|   +-------------------+   |
|           |               |
|     +-----+-----+         |
|     |           |         |
|     v           v         |
| +--------+ +--------+     |
| |Meeting | |Center  |     |
| |Widget  | |Widget  |     |
| +--------+ +--------+     |
|     |           |         |
|     v           v         |
| +--------+ +--------+     |
| |gcal CLI| |Weather |     |
| |        | |Service |     |
| +--------+ +--------+     |
+---------------------------+
```

---

## MeetingWidget Architecture

### Component Hierarchy

```
+-----------------------+
|     PluginSystem      |  <- DMS Plugin Registry
+-----------------------+
          |
          v
+-----------------------+
|    MeetingWidget      |  <- Plugin Entry Point (PluginComponent)
|    +---------------+  |
|    | Bar Pill      |  |  <- Horizontal/Vertical variants
|    +---------------+  |
+-----------------------+
          |
          v
+-----------------------+
|    MeetingsTab        |  <- Full meeting list UI
+-----------------------+
          |
          v
+-----------------------+
|    GCalService        |  <- Singleton (data & API)
+-----------------------+
          |
          v
+-----------------------+
|    gcal CLI           |  <- External process calls
+-----------------------+
          |
          v
+-----------------------+
|  Google Calendar API  |  <- OAuth 2.0 protected
+-----------------------+
```

### MeetingWidget.qml (Entry Point)

**Type**: `PluginComponent`
**Purpose**: Main plugin component registered with DMS plugin system

**Key Properties**:
```qml
property var events: []           // Cached calendar events
property var nextEvent: null      // Next upcoming meeting
property bool loading: false      // Loading state
property bool configured: false   // OAuth status
```

**UI Variants**:
- `horizontalBarPill`: Compact row layout for horizontal DankBar
- `verticalBarPill`: Stacked layout for vertical DankBar

**State Management**:
- Timer-based refresh (configurable, default 5 minutes)
- Process-based CLI calls for data fetching
- Event-driven state updates

### MeetingsTab.qml (Dashboard View)

**Type**: `Item`
**Purpose**: Full meeting list with expandable accordion

**Key Features**:
- `DankListView` with custom delegate
- Expandable meeting cards with attendee details
- Inline join buttons for video meetings
- Time-until and duration calculations

**Visual States**:
- Past meetings (dimmed, 50% opacity)
- Next meeting (highlighted border)
- Conflicts (red indicator)
- 1:1 meetings (green indicator)

### GCalService.qml (Data Service)

**Type**: `Singleton`
**Purpose**: Centralized calendar data management

**Key Methods**:
```qml
function refresh()                    // Fetch latest events
function checkStatus()                // Check OAuth status
function getEventsForDate(date)       // Filter events by date
```

### Data Flow

```
1. Component Initialization
   MeetingWidget.onCompleted
   └── statusProcess.running = true
       └── gcal status
           └── configured && authorized → refresh()

2. Event Refresh Cycle
   refresh()
   └── eventsProcess.running = true
       └── gcal events
           └── Update events[]
               └── findNextEvent()

3. User Interaction
   pillClickAction(...)
   └── popoutService.toggleDankDash(tabIndex, ...)
```

---

## CenterWidget Architecture

### Component Hierarchy

```
+-----------------------+
|     PluginSystem      |  <- DMS Plugin Registry
+-----------------------+
          |
          v
+-----------------------+
|    CenterWidget       |  <- Plugin Entry Point (PluginComponent)
|    +---------------+  |
|    | Bar Pill      |  |  <- Horizontal/Vertical variants
|    +---------------+  |
+-----------------------+
          |
    +-----+-----+
    |           |
    v           v
+--------+ +--------+
|System  | |Weather |
|Clock   | |Service |
+--------+ +--------+
```

### CenterWidget.qml (Entry Point)

**Type**: `PluginComponent`
**Purpose**: Time, date, and weather display with dynamic colors

**Key Properties**:
```qml
property color timeColor: pluginData.timeColor || "#d8bbf2"
property color dateColor: pluginData.dateColor || "#bcc2ff"
property bool showWeather: pluginData.showWeather !== undefined ? pluginData.showWeather : true
property bool useDynamicTempColor: pluginData.dynamicTempColor !== undefined ? pluginData.dynamicTempColor : true
```

**Dynamic Color System**:
```qml
function getTempColor(tempC) {
    if (tempC <= 0) return "#7eb8da";       // Freezing
    if (tempC <= 10) return "#88c4ea";      // Cold
    if (tempC <= 15) return "#7ddfc3";      // Cool
    if (tempC <= 20) return "#98e089";      // Mild
    if (tempC <= 25) return "#d4e157";      // Warm
    if (tempC <= 30) return "#ffca28";      // Hot
    if (tempC <= 35) return "#ffa726";      // Very hot
    return "#ff7043";                        // Extreme
}

function getConditionColor(wCode) {
    if (wCode === 0) return "#ffd54f";      // Sunny
    if (wCode <= 3) return "#b0bec5";       // Cloudy
    if (wCode >= 61 && wCode <= 67) return "#29b6f6";    // Rain
    if (wCode >= 95) return "#ab47bc";      // Thunderstorm
    // ... more conditions
}
```

### Service Integration

**SystemClock**: Updates time display every minute
```qml
SystemClock {
    id: clock
    precision: SystemClock.Minutes
}
```

**WeatherService**: DMS built-in weather data
```qml
Ref {
    service: WeatherService
}
// Access via WeatherService.weather.temp, WeatherService.weather.wCode
```

---

## Common Architecture Patterns

### Plugin Registration

Both plugins use identical registration pattern:
```json
{
  "id": "pluginId",
  "type": "widget",
  "capabilities": ["dankbar-widget"],
  "component": "./Component.qml",
  "settings": "./ComponentSettings.qml",
  "permissions": ["settings_read", "settings_write"]
}
```

### Bar Pill Variants

Both plugins implement dual layouts:
```qml
horizontalBarPill: Component {
    Row { ... }  // Horizontal layout
}

verticalBarPill: Component {
    Column { ... }  // Stacked layout
}
```

### Settings Pattern

Standard settings component structure:
```qml
PluginSettings {
    pluginId: "myPlugin"

    ToggleSetting { settingKey: "option"; defaultValue: true }
    ColorSetting { settingKey: "color"; defaultValue: "#ffffff" }
}
```

### Click Action

Both open DankDash on click:
```qml
pillClickAction: (x, y, width, section, screen) => {
    popoutService?.toggleDankDash(tabIndex, x, y, width, section, screen)
}
```

---

## External Dependencies

### DMS Framework Imports

```qml
import QtQuick                    // Core Qt Quick
import Quickshell                 // Shell integration
import Quickshell.Io              // Process, StdioCollector
import qs.Common                  // Theme, StyledText, SettingsData
import qs.Services                // WeatherService
import qs.Widgets                 // DankIcon, DankListView
import qs.Modules.Plugins         // PluginComponent, PluginSettings
```

### External Services

| Service | Plugin | Type | Purpose |
|---------|--------|------|---------|
| gcal CLI | MeetingWidget | External Process | Google Calendar API |
| WeatherService | CenterWidget | DMS Built-in | Weather data |
| SystemClock | CenterWidget | Quickshell | Time updates |
| SettingsData | Both | DMS Built-in | User preferences |

---

## Design Decisions

### 1. CLI vs. Direct API (MeetingWidget)

**Decision**: Use external `gcal` CLI via `Process` component
**Rationale**:
- OAuth token management handled externally
- Separation of concerns (UI vs. API logic)
- Easier testing and debugging

### 2. Dynamic Colors (CenterWidget)

**Decision**: Temperature and condition-based color mapping
**Rationale**:
- Visual feedback without reading values
- Intuitive understanding at a glance
- Configurable fallback colors

### 3. Timer-based Refresh

**Decision**: Configurable timer instead of push notifications
**Rationale**:
- Simpler implementation
- Respects API quotas
- Adequate for desktop widget use case

### 4. Dual Bar Pill Variants

**Decision**: Separate `horizontalBarPill` and `verticalBarPill`
**Rationale**: Optimal layouts for different DankBar orientations

---

## Security Considerations

- OAuth tokens stored in `~/.config/DankMaterialShell/`
- Credentials file permissions should be user-only (600)
- No sensitive data logged to console
- Read-only calendar scope (`calendar.readonly`)

## Performance Notes

- MeetingWidget: Events limited to 48-hour window
- CenterWidget: Clock precision set to minutes (not seconds)
- UI updates throttled by timer intervals
- Settings loaded once at component creation
