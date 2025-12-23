# DMS Plugins - Project Overview

## Executive Summary

**dms-plugins** is a repository containing plugins for DankMaterialShell (DMS), a Qt/QML-based desktop shell environment. This repository includes two primary plugins:

1. **MeetingWidget** - Google Calendar integration showing upcoming meetings with one-click join
2. **CenterWidget** - Time, date, and weather display with dynamic color theming

## Project Information

| Attribute | Value |
|-----------|-------|
| **Project Name** | dms-plugins |
| **Repository Type** | Monolith (plugin collection) |
| **Primary Language** | QML (Qt Meta Language) |
| **Framework** | Qt Quick / Quickshell |
| **License** | MIT |
| **Author** | jima |
| **Plugins** | 2 |

## Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **UI Framework** | Qt Quick / QML | Declarative UI development |
| **Shell Framework** | Quickshell | Desktop shell integration |
| **Authentication** | Google OAuth 2.0 | Calendar API access (MeetingWidget) |
| **External API** | Google Calendar API | Event data retrieval |
| **Weather Service** | WeatherService | Weather data (CenterWidget) |
| **CLI Integration** | gcal CLI commands | OAuth flow and data fetching |

## Architecture Overview

The project follows a **plugin-based architecture** designed for the DankMaterialShell ecosystem:

```
DankMaterialShell Plugin Architecture
+------------------+
|    DankBar       |
|   (Host Shell)   |
+--------+---------+
         |
    +----+----+
    |         |
    v         v
+--------+ +--------+
|Meeting | |Center  |
|Widget  | |Widget  |
+--------+ +--------+
    |         |
    v         v
+--------+ +--------+
|Meetings| |Weather |
|Tab     | |Service |
+--------+ +--------+
    |
    v
+--------+
|gcal CLI|
+--------+
```

---

## Plugin: MeetingWidget

### Features

- **Bar Widget**: Compact display of next meeting with countdown timer
- **Color Coding**: Blue (regular), Green (1:1), Red (conflicts)
- **Meetings Tab**: Full meeting list with expandable details
- **One-Click Join**: Direct video meeting access
- **Customizable**: Colors, refresh interval, display options

### Components

| Component | File | Purpose |
|-----------|------|---------|
| Bar Widget | `MeetingWidget.qml` | Main pill displayed in DankBar |
| Meetings Tab | `MeetingsTab.qml` | Full meeting list in DankDash |
| Settings | `MeetingWidgetSettings.qml` | Plugin configuration UI |
| Service | `GCalService.qml` | Singleton for calendar data |
| Manifest | `plugin.json` | Plugin metadata and registration |

### Setup

```bash
# 1. Download OAuth credentials
~/.config/DankMaterialShell/gcal-credentials.json

# 2. Authenticate with Google
dms gcal auth

# 3. Enable plugin in Settings -> Plugins
# 4. Add MeetingWidget to DankBar
```

---

## Plugin: CenterWidget

### Features

- **Time & Date Display**: Clean, customizable time and date
- **Weather Integration**: Current temperature and conditions
- **Dynamic Temperature Colors**: Temperature text changes color based on value:
  - Freezing (<=0C): Icy blue
  - Cold (<=10C): Light blue
  - Mild (<=20C): Green
  - Hot (<=30C): Yellow/orange
  - Extreme (>35C): Red-orange
- **Dynamic Condition Colors**: Weather icon changes based on conditions:
  - Clear/Sunny: Yellow
  - Cloudy: Gray-blue
  - Rain: Blue
  - Snow: White
  - Thunderstorm: Purple
- **Click Action**: Opens DankDash weather tab

### Components

| Component | File | Purpose |
|-----------|------|---------|
| Bar Widget | `CenterWidget.qml` | Time/date/weather pill |
| Settings | `CenterWidgetSettings.qml` | Configuration UI |
| Manifest | `plugin.json` | Plugin metadata |

### Setup

1. Enable plugin in Settings -> Plugins
2. Add CenterWidget to DankBar
3. Configure weather location in DMS Settings (optional)

---

## Getting Started

### Prerequisites

1. DankMaterialShell installed and running
2. For MeetingWidget: Google Cloud Console project with Calendar API enabled
3. OAuth 2.0 credentials configured (MeetingWidget only)

### Quick Setup

**Both Plugins:**
1. Enable in Settings -> Plugins
2. Add to DankBar widget list

**MeetingWidget Additional:**
1. Configure Google OAuth credentials
2. Run `dms gcal auth`

## Documentation Index

- [Architecture Documentation](./architecture.md)
- [Source Tree Analysis](./source-tree-analysis.md)
- [Development Guide](./development-guide.md)
- [Component Inventory](./component-inventory.md)
- [MeetingWidget README](../MeetingWidget/README.md)
- [CenterWidget README](../CenterWidget/README.md)
