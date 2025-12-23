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
- Google OAuth credentials from Google Cloud Console

## Setup

### 1. Create OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Enable the Google Calendar API
3. Configure OAuth consent screen (External, add your email as test user)
4. Add scope: `https://www.googleapis.com/auth/calendar.readonly`
5. Create OAuth 2.0 Client ID (Desktop app type)
6. Add redirect URI: `http://localhost:8085/callback` (port configurable)
7. Download JSON and save to `~/.config/gcal/gcal-credentials.json`

### 2. Authenticate

```bash
gcal auth               # Uses default port 8085
gcal auth --port 9000   # Use custom port (must match redirect URI)
```

### 3. Enable Plugin

1. Open Settings → Plugins
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
- **Not configured** - Google Calendar not set up
- **No meetings** - No upcoming meetings in next 48h
- **[Title] in [time]** - Next meeting with countdown
- **[Title] Now** - Meeting currently in progress

## Meetings Tab

When enabled, adds a Meetings tab to DankDash with:
- Expandable accordion for each meeting
- Attendee list with count
- Join buttons for video meetings
- Conflict indicators
- Color-coded meeting types

## CLI Commands

```bash
gcal auth       # Authenticate with Google
gcal status     # Check connection status
gcal logout     # Disconnect account
gcal events     # Fetch events (for debugging)
```

## License

MIT
