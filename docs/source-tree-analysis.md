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
│   ├── MeetingWidget.qml           # Main bar widget with slideout
│   ├── MeetingSlideout.qml         # Full-height side panel
│   └── MeetingWidgetSettings.qml   # Settings panel
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
| `MeetingWidget.qml` | 796 | Main plugin with bar pills and slideout |
| `MeetingSlideout.qml` | 173 | Full-height side panel for meeting list |
| `MeetingWidgetSettings.qml` | 273 | Settings UI with OAuth setup |

**Keyboard Shortcut:** `Super + Ctrl + M` - Toggle meeting slideout (Hyprland)

#### CenterWidget

| File | LOC | Purpose |
|------|-----|---------|
| `CenterWidget.qml` | 206 | Main plugin with time/date/weather |
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
import Quickshell.Wayland         // WlrLayershell (slideout)
import qs.Common                  // Theme, StyledText, SettingsData
import qs.Services                // WeatherService, CompositorService
import qs.Widgets                 // DankIcon, DankListView
import qs.Modules.Plugins         // PluginComponent, PluginSettings
```

### Import Usage by Component

| Component | QtQuick | Quickshell | Quickshell.Io | Quickshell.Wayland | qs.Common | qs.Services | qs.Widgets | qs.Modules.Plugins |
|-----------|---------|------------|---------------|-------------------|-----------|-------------|------------|-------------------|
| MeetingWidget | x | x | x | x | x | x | x | x |
| MeetingSlideout | x | x | - | x | x | x | x | - |
| MeetingWidgetSettings | x | - | - | - | x | - | x | x |
| CenterWidget | x | x | - | - | x | x | x | x |
| CenterWidgetSettings | x | - | - | - | x | - | x | x |

## File Relationships

### MeetingWidget

```
plugin.json
    ├── component ──────────────> MeetingWidget.qml
    │                                   │
    │                                   ├── Uses gcal CLI (via Process)
    │                                   ├── Defines bar pills
    │                                   ├── Contains MeetingSlideout
    │                                   └── pillClickAction → slideout.toggle()
    │
    │       MeetingSlideout.qml <───────┘
    │               │
    │               ├── PanelWindow with WlrLayershell
    │               ├── Right-edge anchored slideout
    │               └── Meeting list with date headers
    │
    └── settings ───────────────> MeetingWidgetSettings.qml
                                        │
                                        └── Provides OAuth setup UI
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
~/.config/gcal/
├── gcal-credentials.json        # OAuth client credentials (MeetingWidget)
└── gcal-token.json              # OAuth tokens (MeetingWidget)

~/.config/DankMaterialShell/
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
**Click Handler**: `pillClickAction` → Opens slideout panel

### 3. IPC Integration (MeetingWidget)

**Command**: `dms ipc call widget toggle meetingWidget`
**Keybind**: `Super + Ctrl + M` (Hyprland only)
**Flow**: IPC → triggerPopout() → pillClickAction() → slideout.toggle()

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
| CompositorService | MeetingWidget | Screen scale for slideout |
