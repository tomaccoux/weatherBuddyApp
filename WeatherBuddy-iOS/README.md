# WeatherBuddy 🌤️

An iOS weather app that brings weather data to life with dynamic Rive animations.

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017%2B-green)

## Features

- 🌤️ **Real-time Weather** - Current conditions and 7-day forecast
- 🎨 **Dynamic Animations** - Rive animations that respond to weather
- 📍 **Location Services** - Automatic location detection
- 🔍 **City Search** - Search weather for any city
- 🌡️ **Unit Toggle** - Switch between Fahrenheit and Celsius
- ⚡ **Data Binding** - Seamless sync between data and animation

## Screenshots

[Add screenshots here]

## Tech Stack

- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Animation**: Rive
- **Weather API**: Open-Meteo (Free, no API key required)
- **Architecture**: MVVM
- **Concurrency**: Async/Await
- **Reactive**: Combine

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/WeatherBuddy.git
cd WeatherBuddy
```

2. Open the project:
```bash
open WeatherBuddy.xcodeproj
```

3. Build and run (⌘R)

### Configuration

No API keys required! The app uses the free Open-Meteo weather service.

## Project Structure

```
WeatherBuddy/
├── Views/                  # SwiftUI views
│   ├── RiveWeatherView.swift
│   └── Components/
├── ViewModels/             # View models
│   └── WeatherViewModel.swift
├── Services/               # Business logic
│   ├── WeatherService.swift
│   ├── LocationManager.swift
│   └── RiveDataBindingManager.swift
├── Models/                 # Data models
│   └── RiveModels.swift
├── Configuration/          # App constants
│   └── Constants.swift
└── Resources/              # Assets
    └── weatherbuddy_final.riv
```

## How It Works

### Weather Data Flow

```
User Input → Geocoding → API Request → Data Parsing → 
ViewModel Update → UI Update → Rive Animation Update
```

### Data Binding

WeatherBuddy uses Rive's data binding to connect weather data directly to animations:

1. **Weather data** updates in `MainWeatherViewModel`
2. **SwiftUI observers** detect changes
3. **RiveDataBindingManager** maps data to Rive properties
4. **Rive Runtime** updates animation automatically
5. **UI reflects** new weather conditions

See [DOCUMENTATION.md](DOCUMENTATION.md) for detailed technical information.

## Key Components

### WeatherService
Fetches weather data from Open-Meteo API with automatic temperature conversion to Fahrenheit.

### LocationManager
Handles CoreLocation services, permissions, and reverse geocoding.

### RiveDataBindingManager
Maps app data to Rive animation properties using the Rive Runtime API.

### MainWeatherViewModel
Central state management for weather data, location, and UI state.

## Rive Integration

The app uses a custom Rive animation with:
- **Artboard**: "Main Screen"
- **State Machine**: "State Machine 1"
- **Data Binding**: ViewModels for weather properties

### Rive ViewModel Structure

```
Root
├── Location (String)
├── CurrenyHour (Number)
├── CurrentWeather (ViewModel)
│   ├── Weather (Enum)
│   ├── DayOfWeek (Enum)
│   ├── Degree (Number)
│   ├── FromDegree (Number)
│   └── ToDegree (Number)
└── Forcast (List)
    └── [0..4] (Same properties)
```

## API Reference

### Open-Meteo API

**Endpoint**: `https://api.open-meteo.com/v1/forecast`

**Example Request**:
```
GET /forecast?latitude=32.08&longitude=34.78&
current=temperature_2m,weather_code&
daily=temperature_2m_max,temperature_2m_min,weather_code&
temperature_unit=fahrenheit&timezone=auto
```

**Response**: Current weather, hourly forecast (24h), daily forecast (7d)

## Architecture

### MVVM Pattern

- **Model**: `RiveModels.swift`, `WeatherResponse`
- **View**: `RiveWeatherView.swift`, Components
- **ViewModel**: `MainWeatherViewModel`

### Services Layer

- `WeatherService` - API communication
- `LocationManager` - Location services
- `RiveDataBindingManager` - Animation data sync

## Dependencies

- **RiveRuntime** - Rive animation runtime
- **Foundation** - Core functionality
- **SwiftUI** - UI framework
- **CoreLocation** - Location services
- **Combine** - Reactive programming

Install via Swift Package Manager or CocoaPods.

## Performance

- ⚡ Async/Await for all network calls
- 🎯 Lazy loading of Rive animations
- 🔄 Debounced updates to prevent excessive calls
- 🎨 Smart view reloading on location changes

## Testing

Run tests with `⌘U` or:
```bash
xcodebuild test -scheme WeatherBuddy -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Known Issues

- None currently

## Roadmap

- [ ] Weather alerts
- [ ] Hourly forecast view
- [ ] Favorite locations
- [ ] Widget support
- [ ] Apple Watch app
- [ ] More weather animations (cloudy, thunderstorm, fog)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Troubleshooting

### Rive Animation Not Showing
- Verify `weatherbuddy_final.riv` is in the bundle
- Check artboard and state machine names

### Location Not Working
- Check Info.plist has location usage description
- Verify location permissions are granted
- Test on a real device

### Weather Not Updating
- Check network connection
- Verify Open-Meteo API is accessible

See [DOCUMENTATION.md](DOCUMENTATION.md) for detailed troubleshooting.

## Resources

- [Rive Documentation](https://rive.app/community/doc/ios-swift/docGxl3rEuVF)
- [Open-Meteo API Docs](https://open-meteo.com/en/docs)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

## Credits

- **Weather Data**: [Open-Meteo](https://open-meteo.com/)
- **Animation Runtime**: [Rive](https://rive.app/)
- **Designer**: [Tom Acco](https://github.com/tomaccoux)
- **Rive Animator**: [Tom Acco](https://github.com/tomaccoux)
- **Developer**: [Alon Raz Lev](https://github.com/lealone)

## License

[Add your license here]

---

Made with ❤️ using SwiftUI and Rive

*For detailed technical documentation, see [DOCUMENTATION.md](DOCUMENTATION.md)*
