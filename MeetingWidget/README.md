# MeetingWidget

Bar widget displaying your Google Calendar meetings with a full-screen slideout panel.

## Features

- Shows next upcoming meeting in the bar
- **Slideout panel** with 14 days of meetings (side panel like Notepad)
- **Date headers** - Meetings grouped by day (Today, Tomorrow, etc.)
- Color-coded by meeting type:
  - **Blue** - Regular meetings (2+ attendees)
  - **Green** - 1:1 meetings (1 attendee)
  - **Red** - Conflicting meetings
- Countdown timer showing days/hours/minutes until meeting
- Click bar widget to open slideout panel
- Right-click to manually refresh calendar data
- Expandable meeting cards with attendee info
- One-click join for video meetings (Zoom, Meet, Teams, WebEx)
- Keyboard shortcut to toggle slideout

## Requirements

- DankMaterialShell
- [gcal](https://github.com/jimallen/gcal) - Google Calendar CLI tool
- Google OAuth credentials from Google Cloud Console

## Setup

### 1. Install gcal CLI

The widget requires the `gcal` CLI tool to fetch calendar data.

**Via Go Install:**
```bash
go install github.com/jimallen/gcal/cmd/gcal@latest
```

**From Source:**
```bash
git clone https://github.com/jimallen/gcal.git
cd gcal
go build -o gcal ./cmd/gcal
sudo mv gcal /usr/local/bin/
```

Verify installation:
```bash
gcal --help
```

### 2. Create OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Enable the **Google Calendar API**
4. Configure OAuth consent screen:
   - User type: External
   - Add your email as a test user
   - Add scope: `https://www.googleapis.com/auth/calendar.readonly`
5. Create OAuth 2.0 Client ID:
   - Application type: Desktop app
   - Add redirect URI: `http://localhost:8085/callback` (port configurable)
6. Download the JSON credentials file
7. Save to `~/.config/gcal/gcal-credentials.json`:
   ```bash
   mkdir -p ~/.config/gcal
   mv ~/Downloads/client_secret_*.json ~/.config/gcal/gcal-credentials.json
   ```

### 3. Authenticate

```bash
gcal auth               # Uses default port 8085
gcal auth --port 9000   # Use custom port (must match redirect URI)
```

This opens a browser for Google OAuth. Grant calendar access and the token will be saved automatically.

Verify authentication:
```bash
gcal status
```

### 4. Enable Plugin

1. Open DMS Settings -> Plugins
2. Click "Scan for Plugins"
3. Enable MeetingWidget
4. Add `meetingWidget` to your DankBar widget list

## Keyboard Shortcut (Hyprland)

Toggle the meeting slideout with:

```
Super + Ctrl + M
```

Add to `~/.config/hypr/UserConfigs/UserKeybinds.conf`:
```bash
bind = $mainMod CTRL, M, exec, dms ipc call widget toggle meetingWidget
```

## IPC Command

Toggle via IPC (works with any compositor):
```bash
dms ipc call widget toggle meetingWidget
```

## Configuration

Available settings in plugin settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `showCountdown` | true | Show countdown in bar pill |
| `showNextMeetingInBar` | true | Show meeting info in bar (disable for icon-only) |
| `showCountdownInBar` | false | Show only countdown time in bar |
| `refreshMinutes` | 5 | How often to fetch calendar updates (1-30 min) |
| `meetingColor` | #a6c8ff | Regular meeting color |
| `oneOnOneColor` | #c3e88d | 1:1 meeting color |
| `conflictColor` | #ffb4ab | Conflict warning color |
| `noMeetingColor` | #90a4ae | "No meetings" text color |

### Bar Display Modes

- **Full mode** (default): Shows meeting title, countdown, and meeting count
- **Icon only**: Set `showNextMeetingInBar: false` to show just the calendar icon
- **Countdown only**: Set `showCountdownInBar: true` to show just the time until next meeting

## Display States

- **Loading...** - Fetching calendar data
- **Not configured** - gcal not authenticated
- **No meetings** - No upcoming meetings in next 14 days
- **[time]** - Time until next meeting (e.g., "45m", "2h 30m", "3d 5h")

### Time Display Format

| Time Until | Display |
|------------|---------|
| < 1 hour | `45m` |
| 1-24 hours | `2h 30m` |
| > 24 hours | `3d 5h` |
| In progress | `now` |
| Ended | `ended` |

## Meeting Slideout

Click the widget to open a full-height slideout panel on the right side of the screen:

- **Header**: Shows title and meeting count
- **Date headers**: Meetings grouped by day (Today, Tomorrow, Wed Jan 15, etc.)
- **Meeting cards**: Clean two-row layout
  - Row 1: Meeting title + expand chevron
  - Row 2: Time range, attendees, countdown, video icon
- **Expanded view**: Additional details, attendee list, Join button
- **Status bar**: Connection state and last refresh time

### Card Colors

- **Highlighted border**: Next upcoming meeting
- **Colored left bar**: Meeting type indicator
- **Faded**: Past meetings

## Status Indicator

The slideout displays a status indicator showing the gcal service state:

| Status | Color | Description |
|--------|-------|-------------|
| Connected | Green | Successfully connected, shows last refresh time |
| Refreshing | Blue | Currently fetching calendar data |
| Error | Red | Failed to fetch data (check gcal CLI) |
| Not configured | Gray | gcal not authenticated |

**Manual Refresh:**
- Click the refresh button in the slideout status bar
- Right-click the widget in the bar for quick refresh

## gcal CLI Commands

```bash
gcal auth        # Authenticate with Google
gcal status      # Check connection status
gcal events      # Fetch events (JSON output)
gcal events -d 14  # Fetch 14 days of events
gcal calendars   # List available calendars
gcal logout      # Disconnect account
```

See [gcal documentation](https://github.com/jimallen/gcal) for full CLI usage.

## Files

| File | Description |
|------|-------------|
| `MeetingWidget.qml` | Main widget component |
| `MeetingSlideout.qml` | Slideout panel component |
| `MeetingWidgetSettings.qml` | Settings UI |
| `plugin.json` | Plugin manifest |

## License

MIT
