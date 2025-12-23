# CenterWidget for DankMaterialShell

A combined time, date, and weather widget for [DankMaterialShell](https://github.com/DankMaterialShell/dms) with dynamic color support.

![DMS Plugin](https://img.shields.io/badge/DMS-Plugin-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Screenshots

![Widget](widget.png?v=3)

![Settings](screenshot.png?v=3)

## Features

- **Time & Date Display** - Clean, customizable time and date
- **Weather Integration** - Current temperature and conditions
- **Dynamic Temperature Colors** - Temperature text changes color based on temp:
  - Freezing (≤0°C): Icy blue
  - Cold (≤10°C): Light blue
  - Cool (≤15°C): Cyan/teal
  - Mild (≤20°C): Green
  - Warm (≤25°C): Yellow-green
  - Hot (≤30°C): Yellow/orange
  - Very hot (≤35°C): Orange
  - Extreme (>35°C): Red-orange

- **Dynamic Condition Colors** - Weather icon changes color based on conditions:
  - Clear/Sunny: Yellow
  - Cloudy: Gray-blue
  - Fog: Muted gray
  - Drizzle: Light blue
  - Rain: Blue
  - Snow: White/light gray
  - Thunderstorm: Purple

- **Settings Panel** - Customize colors for time, date, weather, and separators
- **Click Action** - Opens DankDash weather tab

## Installation

```bash
cd ~/.config/DankMaterialShell/plugins
git clone https://github.com/jimallen/dms-center-widget.git CenterWidget
```

Then enable the plugin in DMS Settings > Plugins.

## Configuration

Access settings through DMS Settings > Plugins > Center Widget:

- **Show Weather** - Toggle weather display
- **Time Color** - Custom color for time
- **Date Color** - Custom color for date
- **Weather Color** - Fallback color for weather (when dynamic colors are unavailable)
- **Separator Color** - Color for dot separators

## Requirements

- DankMaterialShell
- Weather enabled in DMS Settings

## License

MIT
