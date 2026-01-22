# HyprWhspr Widget

A DankMaterialShell widget for controlling [hyprwhspr](https://github.com/goodroot/hyprwhspr) speech-to-text.

## Features

- **Recording Status**: Visual indicator showing recording state with pulse animation
- **Click to Toggle**: Single click starts/stops recording
- **Push-to-Talk**: Long-press (500ms default) for push-to-talk mode
- **Slideout Panel**: Right-click for detailed controls and status
- **Service Monitoring**: Automatic detection of hyprwhspr service status

## Controls

| Action | Result |
|--------|--------|
| Click | Toggle recording (start/stop) |
| Long-press | Push-to-talk (record while held) |
| Right-click | Open slideout panel |

## Recording Modes

The widget adapts to hyprwhspr's configured recording mode:

- **toggle** (default): Click to start, click again to stop and transcribe
- **long_form**: Accumulate multiple recordings, then submit all at once
- **push_to_talk**: Record only while key/button is held
- **auto**: Automatic voice activity detection

## Slideout Panel

The slideout panel provides:
- Service status indicator
- Current mode and backend info
- Large Record/Stop and Submit buttons
- Last transcription with copy-to-clipboard
- Quick actions: Restart service, Open config, Refresh status

## Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Show Status Text | Display "Recording/Ready" text in bar | true |
| Pulse Animation | Animate icon while recording | true |
| Push-to-Talk Threshold | Long-press duration (ms) | 500 |
| Status Poll Interval | How often to check status (sec) | 10 |
| Recording Color | Color when recording | #ef5350 |
| Idle Color | Color when ready | #90a4ae |
| Error Color | Color on error | #ffb4ab |

## Requirements

- [hyprwhspr](https://github.com/goodroot/hyprwhspr) installed and configured
- `hyprwhspr.service` running via systemd user service
- DankMaterialShell with plugin support

## Installation

1. Clone or copy `HyprWhsprWidget/` to `~/.config/DankMaterialShell/plugins/`
2. Restart DankMaterialShell or reload plugins
3. Add the widget to your DankBar configuration

## Control File API

The widget controls hyprwhspr by writing to `~/.config/hyprwhspr/recording_control`:

```bash
echo "start" > ~/.config/hyprwhspr/recording_control  # Start recording
echo "stop" > ~/.config/hyprwhspr/recording_control   # Stop and transcribe
echo "submit" > ~/.config/hyprwhspr/recording_control # Submit (long_form only)
```
