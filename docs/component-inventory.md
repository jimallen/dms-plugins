# Component Inventory

## Overview

This document catalogs all QML components in the dms-plugins repository, organized by plugin and purpose.

## Component Summary

### MeetingWidget

| Component | Type | Purpose | Lines |
|-----------|------|---------|-------|
| MeetingWidget | PluginComponent | Main plugin with bar widget and slideout | 796 |
| MeetingSlideout | PanelWindow | Full-height side panel for meeting list | 173 |
| MeetingWidgetSettings | PluginSettings | Configuration panel | 273 |

### CenterWidget

| Component | Type | Purpose | Lines |
|-----------|------|---------|-------|
| CenterWidget | PluginComponent | Time/date/weather display | 206 |
| CenterWidgetSettings | PluginSettings | Configuration panel | 107 |

**Total Lines of Code**: ~1,555 LOC (5 components)

---

## MeetingWidget Components

### MeetingWidget.qml

**Type**: `PluginComponent`
**Purpose**: Main bar widget with slideout panel showing 14 days of meetings

#### Keyboard Shortcut (Hyprland)

```
Super + Ctrl + M    Toggle meeting slideout
```

```bash
# Add to ~/.config/hypr/UserConfigs/UserKeybinds.conf
bind = $mainMod CTRL, M, exec, dms ipc call widget toggle meetingWidget
```

For other compositors, use the IPC command directly or configure an equivalent keybind.

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `refreshMinutes` | int | 5 | Calendar refresh interval |
| `showCountdown` | bool | true | Show countdown in bar |
| `showNextMeetingInBar` | bool | true | Show meeting info (false = icon only) |
| `showCountdownInBar` | bool | false | Show only countdown time |
| `meetingColor` | color | #a6c8ff | Regular meeting color |
| `oneOnOneColor` | color | #c3e88d | 1:1 meeting color |
| `conflictColor` | color | #ffb4ab | Conflict indicator color |
| `noMeetingColor` | color | #90a4ae | Empty state color |
| `events` | var | [] | Cached calendar events (14 days) |
| `nextEvent` | var | null | Next upcoming meeting |
| `loading` | bool | false | Loading state |
| `configured` | bool | false | OAuth configured |
| `isSlideoutVisible` | bool | readonly | Slideout visibility state |

#### Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `getEventColor` | event | color | Get color based on event type |
| `refresh` | - | void | Trigger calendar refresh |
| `getTimeUntil` | startTime | string | Format time until event (days/hours/minutes) |
| `formatTime` | isoTime | string | Format time display |
| `formatDate` | isoTime | string | Format date display |
| `formatDateHeader` | isoTime | string | Format date header (Today, Tomorrow, etc.) |
| `getDuration` | start, end | string | Calculate meeting duration |
| `findNextEvent` | - | void | Find and set nextEvent |
| `isEventPast` | event | bool | Check if event has ended |
| `isNextMeeting` | event | bool | Check if this is next meeting |
| `isSameDay` | time1, time2 | bool | Check if two times are same day |
| `getDateKey` | isoTime | string | Get date key for grouping |

---

### MeetingSlideout.qml

**Type**: `PanelWindow`
**Purpose**: Full-height side panel for meeting list with slide animation

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `layerNamespace` | string | "dms:meeting-slideout" | Wayland layer namespace |
| `isVisible` | bool | false | Panel visibility state |
| `targetScreen` | var | null | Target screen for panel |
| `slideoutWidth` | real | 380 | Panel width |
| `title` | string | "Upcoming Meetings" | Header title |
| `subtitle` | string | "" | Header subtitle |
| `content` | alias | - | Default property for content |

#### Functions

| Function | Description |
|----------|-------------|
| `show()` | Show the slideout panel |
| `hide()` | Hide the slideout panel |
| `toggle()` | Toggle visibility |

#### Wayland Integration

Uses `WlrLayershell` for Wayland layer shell:
- `WlrLayershell.layer`: Top
- `WlrLayershell.exclusiveZone`: 0
- Anchored to top, bottom, right edges

---

### MeetingWidgetSettings.qml

**Type**: `PluginSettings`
**Purpose**: User preferences and OAuth setup instructions

#### Settings

| Setting Key | Type | Default | Description |
|-------------|------|---------|-------------|
| `showCountdown` | Toggle | true | Show countdown in bar |
| `showNextMeetingInBar` | Toggle | true | Show meeting info in bar |
| `showCountdownInBar` | Toggle | false | Show only countdown time |
| `refreshMinutes` | Slider | 5 | Refresh interval (1-30 min) |
| `meetingColor` | Color | #a6c8ff | Meeting color |
| `conflictColor` | Color | #ffb4ab | Conflict color |
| `noMeetingColor` | Color | #90a4ae | No meeting color |

---

## CenterWidget Components

### CenterWidget.qml

**Type**: `PluginComponent`
**Purpose**: Time, date, and weather display with dynamic colors

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `popoutService` | var | null | Service for DankDash popout |
| `timeColor` | color | #d8bbf2 | Time text color |
| `dateColor` | color | #bcc2ff | Date text color |
| `weatherColor` | color | #cac1e9 | Fallback weather color |
| `showWeather` | bool | true | Show weather display |
| `useDynamicTempColor` | bool | true | Dynamic temp colors |
| `useDynamicIconColor` | bool | true | Dynamic icon colors |
| `dynamicTempColor` | color | computed | Temperature-based color |
| `dynamicIconColor` | color | computed | Condition-based color |

#### Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `getTempColor` | tempC | color | Get color for temperature value |
| `getConditionColor` | wCode | color | Get color for WMO weather code |

#### Temperature Color Mapping

| Range | Color | Description |
|-------|-------|-------------|
| <= 0C | #7eb8da | Freezing - icy blue |
| <= 10C | #88c4ea | Cold - light blue |
| <= 15C | #7ddfc3 | Cool - cyan/teal |
| <= 20C | #98e089 | Mild - green |
| <= 25C | #d4e157 | Warm - yellow-green |
| <= 30C | #ffca28 | Hot - yellow/orange |
| <= 35C | #ffa726 | Very hot - orange |
| > 35C | #ff7043 | Extreme - red-orange |

#### Weather Condition Color Mapping

| WMO Code | Color | Condition |
|----------|-------|-----------|
| 0 | #ffd54f | Clear sky - yellow |
| 1-3 | #b0bec5 | Partly cloudy - gray-blue |
| 45, 48 | #90a4ae | Fog - muted gray |
| 51-57 | #4fc3f7 | Drizzle - light blue |
| 61-67 | #29b6f6 | Rain - blue |
| 71-77 | #e0e0e0 | Snow - white |
| 80-82 | #42a5f5 | Rain showers - blue |
| 85-86 | #b3e5fc | Snow showers - icy blue |
| 95-99 | #ab47bc | Thunderstorm - purple |

---

### CenterWidgetSettings.qml

**Type**: `PluginSettings`
**Purpose**: Display options and color configuration

#### Settings

| Setting Key | Type | Default | Description |
|-------------|------|---------|-------------|
| `showDate` | Toggle | true | Show date display |
| `showWeather` | Toggle | true | Show weather display |
| `showSeconds` | Toggle | false | Show seconds in time |
| `dynamicTempColor` | Toggle | true | Dynamic temperature colors |
| `dynamicIconColor` | Toggle | true | Dynamic icon colors |
| `timeColor` | Color | #d8bbf2 | Time text color |
| `dateColor` | Color | #bcc2ff | Date text color |
| `weatherColor` | Color | #cac1e9 | Fallback weather color |
| `separatorColor` | Color | #908f9c | Separator dot color |

---

## Design System Usage

### Theme Properties Used

| Property | Usage |
|----------|-------|
| `Theme.spacingXS` | Tight spacing |
| `Theme.spacingS` | Small spacing |
| `Theme.spacingM` | Medium spacing |
| `Theme.cornerRadius` | Card rounding |
| `Theme.fontSizeSmall` | Secondary text |
| `Theme.fontSizeMedium` | Body text |
| `Theme.fontSizeLarge` | Headers |
| `Theme.surfaceText` | Primary text color |
| `Theme.surfaceVariantText` | Secondary text color |
| `Theme.iconSize` | Standard icon size |

### Shared Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| `StyledText` | qs.Common | Themed text |
| `DankIcon` | qs.Widgets | Material icons |
| `DankListView` | qs.Widgets | Themed list |
| `ToggleSetting` | qs.Modules.Plugins | Toggle control |
| `SliderSetting` | qs.Modules.Plugins | Slider control |
| `ColorSetting` | qs.Modules.Plugins | Color picker |
| `PluginComponent` | qs.Modules.Plugins | Plugin base |
| `PluginSettings` | qs.Modules.Plugins | Settings base |
| `SystemClock` | Quickshell | Time updates |
| `WeatherService` | qs.Services | Weather data |

---

## Reusability Analysis

### Reusable Patterns

1. **Process + StdioCollector** - CLI communication (MeetingWidget)
2. **Timer-based refresh** - Periodic data updates (both)
3. **Dynamic color mapping** - Value-to-color functions (CenterWidget)
4. **Horizontal/Vertical pill variants** - Adaptive bar layouts (both)
5. **Expandable list delegate** - Accordion UI (MeetingWidget)

### Cross-Plugin Patterns

| Pattern | MeetingWidget | CenterWidget |
|---------|---------------|--------------|
| Bar pill variants | x | x |
| Settings panel | x | x |
| Color customization | x | x |
| Timer refresh | x | x |
| Service integration | gcal CLI | WeatherService |
