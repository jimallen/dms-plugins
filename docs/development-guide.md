# Development Guide

## Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Qt | 6.x | QML runtime |
| Quickshell | Latest | Shell framework |
| DankMaterialShell | Latest | Host shell environment |
| gcal CLI | Latest | Google Calendar integration |

### Development Environment

1. **DankMaterialShell** must be installed and running
2. **gcal** CLI tool must be in PATH
3. Google Cloud project with Calendar API enabled
4. OAuth 2.0 credentials downloaded

## Project Setup

### Clone Repository

```bash
cd ~/Code
git clone <repository-url> dms-plugins
cd dms-plugins
```

### Configure Plugin Location

DMS scans for plugins in configured directories. Ensure `dms-plugins/` is in the scan path:

```bash
# Option 1: Symlink to default plugin directory
ln -s ~/Code/dms-plugins/MeetingWidget ~/.local/share/DankMaterialShell/plugins/MeetingWidget

# Option 2: Add to DMS plugin scan paths in settings
```

### Google Calendar Setup

1. **Create Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create new project or select existing

2. **Enable Calendar API**
   - Navigate to APIs & Services → Library
   - Search for "Google Calendar API"
   - Click Enable

3. **Configure OAuth Consent**
   - Go to OAuth consent screen
   - Select External user type
   - Add your email as test user
   - Add scope: `https://www.googleapis.com/auth/calendar.readonly`

4. **Create OAuth Credentials**
   - Go to Credentials → Create Credentials → OAuth client ID
   - Select "Desktop application"
   - Add redirect URI: `http://localhost:8085/callback`
   - Download JSON

5. **Install Credentials**
   ```bash
   mkdir -p ~/.config/DankMaterialShell
   mv ~/Downloads/client_secret_*.json ~/.config/DankMaterialShell/gcal-credentials.json
   chmod 600 ~/.config/DankMaterialShell/gcal-credentials.json
   ```

6. **Authenticate**
   ```bash
   dms gcal auth
   # or with custom port:
   dms gcal auth --port 9000
   ```

## Development Workflow

### Making Changes

1. **Edit QML Files**
   - Changes are picked up on next DMS reload
   - No build step required

2. **Test Changes**
   ```bash
   # Reload Quickshell to pick up changes
   quickshell --reload

   # Or restart DMS entirely
   dms restart
   ```

3. **Debug Output**
   - Use `console.log()` in QML
   - View logs: `journalctl -f -u dms` or terminal output

### File Structure Best Practices

```
MeetingWidget/
├── plugin.json           # Required: Plugin manifest
├── README.md             # Required: User documentation
├── <PluginName>.qml      # Required: Main component
├── <PluginName>Tab.qml   # Optional: Dashboard tab
├── <PluginName>Settings.qml  # Optional: Settings panel
└── services/             # Optional: Service components
    └── <Service>.qml
```

### QML Patterns Used

#### Singleton Service
```qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    property var data: []

    function refresh() {
        // ...
    }
}
```

#### Process for CLI Calls
```qml
Process {
    id: myProcess
    command: ["my-cli", "subcommand"]
    running: false

    stdout: StdioCollector {
        onStreamFinished: {
            try {
                let result = JSON.parse(text)
                // Handle result
            } catch (e) {
                console.log("Parse error:", e)
            }
        }
    }
}
```

#### Plugin Component
```qml
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Read settings via pluginData
    readonly property int myValue: pluginData.myValue || 5

    // Bar widget variants
    horizontalBarPill: Component { /* ... */ }
    verticalBarPill: Component { /* ... */ }

    // Click handler
    pillClickAction: (x, y, width, section, screen) => {
        popoutService?.toggleDankDash(tabIndex, x, y, width, section, screen)
    }
}
```

#### Settings Component
```qml
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "meetingWidget"

    ToggleSetting {
        settingKey: "myToggle"
        label: "Enable Feature"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "myNumber"
        label: "Value"
        minimum: 1
        maximum: 100
        defaultValue: 50
    }

    ColorSetting {
        settingKey: "myColor"
        label: "Color"
        defaultValue: "#ffffff"
    }
}
```

## Testing

### Manual Testing

1. **Widget Display**
   - Verify bar pill renders correctly
   - Check horizontal and vertical variants
   - Test click opens dashboard

2. **Calendar Integration**
   - Verify events load after auth
   - Check countdown timer updates
   - Test join button opens URL

3. **Settings**
   - Change settings and verify effect
   - Test color pickers
   - Verify persistence across restarts

### CLI Testing

```bash
# Check OAuth status
gcal status

# Fetch events (raw output)
gcal events

# Debug authentication
gcal auth --verbose
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "Not configured" in widget | Run `gcal auth` |
| Events not loading | Check `gcal status` for errors |
| Widget not appearing | Ensure plugin is enabled in Settings |
| Settings not saving | Check plugin permissions in manifest |

### Debug Logging

Add debug output to track state:

```qml
Component.onCompleted: {
    console.log("MyComponent: initializing...")
}

onPropertyChanged: {
    console.log("Property changed:", newValue)
}
```

### Log Locations

- **Quickshell logs**: Terminal or `journalctl -u quickshell`
- **DMS logs**: `~/.local/share/DankMaterialShell/logs/`
- **gcal logs**: Terminal output during auth

## Contributing

### Code Style

- 4-space indentation
- camelCase for properties and functions
- PascalCase for component names
- Descriptive property names

### Pull Request Checklist

- [ ] QML files lint without errors
- [ ] Manual testing completed
- [ ] README updated if needed
- [ ] No hardcoded paths
- [ ] Console.log statements removed (except for debug builds)
