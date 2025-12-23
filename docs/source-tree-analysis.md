# Source Tree Analysis

## Directory Structure

```
dms-plugins/
├── docs/                           # Generated documentation (this folder)
│   ├── index.md                    # Documentation entry point
│   ├── project-overview.md         # Project summary
│   ├── architecture.md             # Architecture documentation
│   ├── source-tree-analysis.md     # This file
│   ├── development-guide.md        # Development instructions
│   ├── component-inventory.md      # Component catalog
│   └── project-scan-report.json    # Workflow state file
│
├── MeetingWidget/                  # Google Calendar Plugin
│   ├── plugin.json                 # Plugin manifest (entry point)
│   ├── README.md                   # Plugin documentation
│   ├── MeetingWidget.qml           # Main bar widget component
│   ├── MeetingsTab.qml             # Full meeting list tab
│   ├── MeetingWidgetSettings.qml   # Settings panel
│   └── GCalService.qml             # Calendar data service (singleton)
│
└── CenterWidget/                   # Time/Date/Weather Plugin
    ├── plugin.json                 # Plugin manifest (entry point)
    ├── README.md                   # Plugin documentation
    ├── CenterWidget.qml            # Main bar widget component
    ├── CenterWidgetSettings.qml    # Settings panel
    ├── screenshot.png              # Settings screenshot
    └── widget.png                  # Widget screenshot
```

## Critical Files

### Plugin Entry Points

| File | Purpose |
|------|---------|
| `MeetingWidget/plugin.json` | MeetingWidget manifest |
| `CenterWidget/plugin.json` | CenterWidget manifest |

**MeetingWidget Manifest:**
```json
{
  "id": "meetingWidget",
  "name": "Meeting Widget",
  "type": "widget",
  "capabilities": ["dankbar-widget"],
  "component": "./MeetingWidget.qml",
  "tabComponent": "./MeetingsTab.qml",
  "settings": "./MeetingWidgetSettings.qml",
  "permissions": ["settings_read", "settings_write"]
}
```

**CenterWidget Manifest:**
```json
{
  "id": "centerWidget",
  "name": "Center Widget",
  "type": "widget",
  "capabilities": ["dankbar-widget"],
  "component": "./CenterWidget.qml",
  "settings": "./CenterWidgetSettings.qml",
  "permissions": ["settings_read", "settings_write"]
}
```

### Core Components

#### MeetingWidget

| File | LOC | Purpose |
|------|-----|---------|
| `MeetingWidget.qml` | 233 | Main plugin with bar pill variants |
| `MeetingsTab.qml` | 540 | Full meeting list with expandable cards |
| `MeetingWidgetSettings.qml` | 266 | Settings UI with OAuth setup |
| `GCalService.qml` | 115 | Singleton for calendar data |

#### CenterWidget

| File | LOC | Purpose |
|------|-----|---------|
| `CenterWidget.qml` | 193 | Main plugin with time/date/weather |
| `CenterWidgetSettings.qml` | 107 | Settings UI for colors and display |

### Documentation

| File | Purpose |
|------|---------|
| `MeetingWidget/README.md` | MeetingWidget setup and usage |
| `CenterWidget/README.md` | CenterWidget setup and usage |

## Import Dependencies

### Framework Imports (DMS/Quickshell)

```qml
import QtQuick                    // Core Qt Quick
import Quickshell                 // Shell integration
import Quickshell.Io              // Process, StdioCollector
import qs.Common                  // Theme, StyledText, SettingsData
import qs.Services                // WeatherService
import qs.Widgets                 // DankIcon, DankListView
import qs.Modules.Plugins         // PluginComponent, PluginSettings
```

### Import Usage by Component

| Component | QtQuick | Quickshell | Quickshell.Io | qs.Common | qs.Services | qs.Widgets | qs.Modules.Plugins |
|-----------|---------|------------|---------------|-----------|-------------|------------|-------------------|
| MeetingWidget | x | x | x | x | - | x | x |
| MeetingsTab | x | - | x | x | - | x | - |
| MeetingWidgetSettings | x | - | - | x | - | x | x |
| GCalService | x | x | x | - | - | - | - |
| CenterWidget | x | x | - | x | x | x | x |
| CenterWidgetSettings | x | - | - | x | - | x | x |

## File Relationships

### MeetingWidget

```
plugin.json
    ├── component ──────────────> MeetingWidget.qml
    │                                   │
    │                                   ├── Uses gcal CLI (via Process)
    │                                   └── Defines bar pills
    │
    ├── tabComponent ───────────> MeetingsTab.qml
    │                                   │
    │                                   └── Uses gcal CLI (via Process)
    │
    └── settings ───────────────> MeetingWidgetSettings.qml
                                        │
                                        └── Provides OAuth setup UI

GCalService.qml (Singleton)
    │
    └── Called by: gcal CLI ───────> Google Calendar API
```

### CenterWidget

```
plugin.json
    ├── component ──────────────> CenterWidget.qml
    │                                   │
    │                                   ├── Uses WeatherService (DMS built-in)
    │                                   ├── Uses SystemClock
    │                                   └── Defines bar pills
    │
    └── settings ───────────────> CenterWidgetSettings.qml
                                        │
                                        └── Color and display settings
```

## State and Data Files

### Runtime Files (User Config Directory)

```
~/.config/DankMaterialShell/
├── gcal-credentials.json        # OAuth client credentials (MeetingWidget)
├── gcal-token.json              # OAuth tokens (MeetingWidget)
└── plugins/
    ├── meetingWidget/
    │   └── settings.json        # MeetingWidget settings
    └── centerWidget/
        └── settings.json        # CenterWidget settings
```

### Build/Generated Files

This project has no build step - QML files are interpreted at runtime.

## Key Integration Points

### 1. DMS Plugin System

**Registration**: `plugin.json` → DMS Plugin Registry
**Capabilities**: `dankbar-widget` → Appears in bar widget list
**Permissions**: `settings_read`, `settings_write` → Access to settings storage

### 2. DankBar Integration

**Component**: `horizontalBarPill`, `verticalBarPill`
**Click Handler**: `pillClickAction` → Opens DankDash

### 3. DankDash Integration (MeetingWidget only)

**Component**: `MeetingsTab`
**Tab Registration**: Via `tabComponent`, `tabName`, `tabIcon` in manifest

### 4. Settings Integration

**Component**: `*Settings.qml`
**Registration**: Via `settings` in manifest
**Data Access**: `pluginData` property in components

### 5. Service Integration

| Service | Plugin | Purpose |
|---------|--------|---------|
| gcal CLI | MeetingWidget | Google Calendar API |
| WeatherService | CenterWidget | Weather data |
| SystemClock | CenterWidget | Time updates |
| SettingsData | Both | User preferences |
