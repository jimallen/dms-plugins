# DMS Plugins

A collection of Qt/QML plugins for [DankMaterialShell](https://github.com/pjtsearch/dank-material-shell).

![DMS Plugins](https://img.shields.io/badge/DMS-Plugins-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Plugins

### MeetingWidget

Google Calendar integration widget showing your next meeting with one-click join.

**Features:**
- Next meeting display with countdown timer
- Color-coded meetings (regular, 1:1, conflicts)
- Meetings tab in DankDash with full list
- One-click join for video meetings (Zoom, Meet, Teams, WebEx)

**Requirements:** [gcal CLI](https://github.com/jimallen/gcal)

[View Documentation](MeetingWidget/README.md)

---

### CenterWidget

Combined time, date, and weather widget with dynamic color theming.

![CenterWidget](CenterWidget/widget.png)

**Features:**
- Time and date display
- Weather integration with temperature and conditions
- Dynamic colors based on temperature and weather
- Fully customizable colors

[View Documentation](CenterWidget/README.md)

## Installation

### Clone Repository

```bash
git clone https://github.com/jimallen/dms-plugins.git
cd dms-plugins
```

### Symlink Plugins

Create symlinks in the DMS plugins directory:

```bash
ln -s $(pwd)/MeetingWidget ~/.config/DankMaterialShell/plugins/MeetingWidget
ln -s $(pwd)/CenterWidget ~/.config/DankMaterialShell/plugins/CenterWidget
```

### Enable Plugins

1. Open DMS Settings → Plugins
2. Click "Scan for Plugins"
3. Enable desired plugins
4. Add widgets to your DankBar

## Documentation

Detailed documentation is available in the [docs](docs/) folder:

- [Project Overview](docs/project-overview.md)
- [Architecture](docs/architecture.md)
- [Component Inventory](docs/component-inventory.md)
- [Development Guide](docs/development-guide.md)

## Development

No build step required - QML files are interpreted at runtime.

1. Edit QML files
2. Reload Quickshell: `quickshell --reload`
3. Test changes

See the [Development Guide](docs/development-guide.md) for details.

## License

MIT
