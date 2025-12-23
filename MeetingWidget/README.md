# MeetingWidget

Bar widget displaying your next Google Calendar meeting with one-click join.

## Features

- Shows next upcoming meeting in the bar
- Color-coded by meeting type:
  - **Blue** - Regular meetings (2+ attendees)
  - **Green** - 1:1 meetings (1 attendee)
  - **Red** - Conflicting meetings
- Countdown timer ("in 45m", "Now")
- Click to open Meetings tab in DankDash
- Optional Meetings tab in DankDash with full meeting list

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

1. Open DMS Settings → Plugins
2. Click "Scan for Plugins"
3. Enable MeetingWidget
4. Add `MeetingWidget` to your DankBar widget list

## Configuration

Available settings in plugin settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `showMeetingsTab` | true | Show Meetings tab in DankDash |
| `showCountdown` | true | Show time until meeting |
| `refreshMinutes` | 5 | How often to fetch calendar updates |
| `meetingColor` | #a6c8ff | Regular meeting color |
| `oneOnOneColor` | #c3e88d | 1:1 meeting color |
| `conflictColor` | #ffb4ab | Conflict warning color |
| `noMeetingColor` | #90a4ae | "No meetings" text color |

## Display States

- **Loading...** - Fetching calendar data
- **Not configured** - gcal not authenticated
- **No meetings** - No upcoming meetings in next 48h
- **[Title] in [time]** - Next meeting with countdown
- **[Title] Now** - Meeting currently in progress

## Meetings Tab

When enabled, adds a Meetings tab to DankDash with:
- Expandable accordion for each meeting
- Attendee list with count
- Join buttons for video meetings (Zoom, Meet, Teams, WebEx)
- Conflict indicators
- Color-coded meeting types

## gcal CLI Commands

```bash
gcal auth        # Authenticate with Google
gcal status      # Check connection status
gcal events      # Fetch events (JSON output)
gcal calendars   # List available calendars
gcal logout      # Disconnect account
```

See [gcal documentation](https://github.com/jimallen/gcal) for full CLI usage.

## License

MIT
