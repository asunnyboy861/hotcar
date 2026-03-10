# 🚀 HotCar Quick Reference Card

## 📱 Project Overview

**App Name**: HotCar  
**Platform**: iOS 17.0+  
**Language**: Swift 5.9+  
**UI Framework**: SwiftUI  
**Architecture**: MVVM + Feature Modules  
**Status**: Week 1 Complete ✅  

---

## 🎯 Core Features

### ✅ Completed (Week 1)
- Smart warm-up calculation
- Real-time weather integration
- Vehicle management (CRUD)
- Countdown timer
- Dark mode theme
- Unit tests (14 tests)

### 🚧 In Progress (Week 2)
- Push notifications
- Haptic feedback
- Tesla API integration
- Vehicle enhancements

### 📋 Planned (Week 3-4)
- Statistics module
- iOS Widgets
- Settings & preferences
- App Store submission

---

## 📁 Key Files

### Entry Points
```
hotcar/hotcarApp.swift      - App entry
hotcar/ContentView.swift    - Root view
```

### Main Features
```
Features/Home/
  HomeView.swift           - Main screen
  HomeViewModel.swift

Features/WarmUpCalculator/
  WarmUpCalculationEngine.swift  - Core algorithm
  WarmUpCalculatorView.swift
  WarmUpCalculatorViewModel.swift

Features/VehicleManagement/
  VehicleModel.swift       - Data model
  VehicleService.swift     - CRUD operations
  VehicleListView.swift
  AddVehicleView.swift
```

### UI System
```
UI/Theme/
  ColorPalette.swift       - Colors
  Typography.swift         - Fonts
  Spacing.swift            - Layout

UI/Components/
  TemperatureDisplay.swift
  TimerButton.swift
  VehicleCard.swift
  StatCard.swift
```

---

## 🎨 Design System

### Colors
```swift
Color.hotCarPrimary      // Blue (#007AFF)
Color.hotCarSecondary    // Orange (#FF9500)
Color.warmUpActive       // Red (#FF4747)
Color.warmUpReady        // Green (#33CC33)
```

### Fonts
```swift
Font.hotCarDisplay       // 64pt - Temperature
Font.hotCarTimer         // 48pt - Timer
Font.hotCarLargeTitle    // 34pt - Titles
Font.hotCarBody          // 16pt - Body
```

### Spacing
```swift
.hotCarSpacingSm   // 8pt
.hotCarSpacingMd   // 16pt
.hotCarSpacingLg   // 24pt
```

---

## 🧪 Testing

### Run All Tests
```bash
xcodebuild test \
  -project hotcar/hotcar.xcodeproj \
  -scheme hotcar \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Test Coverage
- ✅ WarmUpCalculationEngine: 100%
- ⏳ Other modules: Pending

---

## 🔧 Quick Commands

### Open Project
```bash
open hotcar/hotcar.xcodeproj
```

### Clean Build
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/hotcar-*
```

### Build
```bash
xcodebuild -project hotcar/hotcar.xcodeproj -scheme hotcar build
```

---

## 📊 Algorithm

### Warm-Up Time Calculation
```swift
let time = WarmUpCalculationEngine.calculateWarmUpTime(
    temperature: -25,      // Current temp (°C)
    vehicleType: .suv,     // Vehicle type
    engineType: .gasoline, // Engine type
    hasBlockHeater: true,  // Has block heater?
    isPluggedIn: true      // Currently plugged in?
)
// Returns: 7 minutes
```

### Factors
1. **Base Time** (from temperature)
   - Mild (0 to -10°C): 3 min
   - Cold (-10 to -20°C): 7 min
   - Very Cold (-20 to -30°C): 12 min
   - Extreme (<-30°C): 18 min

2. **Vehicle Multiplier**
   - Compact: 0.8×
   - Sedan: 1.0×
   - SUV: 1.2×
   - Truck: 1.5×

3. **Engine Multiplier**
   - Gasoline: 1.0×
   - Diesel: 1.5×
   - Hybrid: 0.9×
   - Electric: 0.3×

4. **Block Heater**: 0.5× (if plugged in)

---

## 🌡️ Temperature Colors

| Range | Color | Hex |
|-------|-------|-----|
| Mild (0 to -10°C) | Pale Blue | #99CCFF |
| Cold (-10 to -20°C) | Light Blue | #66B3FF |
| Very Cold (-20 to -30°C) | Blue | #3399FF |
| Extreme (<-30°C) | Purple | #9933CC |

---

## 🚗 Vehicle Types

```swift
enum VehicleType: String, CaseIterable {
    case compact = "compact"  // 0.8× multiplier
    case sedan = "sedan"      // 1.0× multiplier
    case suv = "suv"          // 1.2× multiplier
    case truck = "truck"      // 1.5× multiplier
}
```

## ⚙️ Engine Types

```swift
enum EngineType: String, CaseIterable {
    case gasoline = "gasoline"  // 1.0× multiplier
    case diesel = "diesel"      // 1.5× multiplier
    case hybrid = "hybrid"      // 0.9× multiplier
    case electric = "electric"  // 0.3× multiplier
}
```

---

## 📱 Info.plist Keys

Required for app to function:

```xml
NSLocationWhenInUseUsageDescription
  → "HotCar needs your location to provide accurate weather data."

NSLocationAlwaysAndWhenInUseUsageDescription
  → "HotCar uses your location to fetch local weather conditions."
```

---

## 🎯 Development Workflow

### 1. Open Project
```bash
open hotcar/hotcar.xcodeproj
```

### 2. Select Simulator
Choose iPhone 15 Pro from device list

### 3. Build & Run
Press ⌘R

### 4. Test Features
- Add a vehicle
- Check temperature display
- Start warm-up timer
- Verify calculations

### 5. Run Tests
Press ⌘U

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| README.md | Project overview |
| us.md | Complete operation guide |
| QUICKSTART.md | Setup instructions |
| CONFIGURATION.md | Configuration guide |
| PROJECT_SUMMARY.md | Development summary |
| WEEK1_COMPLETE.md | Week 1 report |

---

## 🔗 API Endpoints

### Open-Meteo Weather API
```
Current Weather:
https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true

Hourly Forecast:
https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&hourly=temperature_2m&forecast_days=2
```

**Example (Toronto)**:
```
https://api.open-meteo.com/v1/forecast?latitude=43.6532&longitude=-79.3832&current_weather=true
```

---

## 💡 Tips

### Debugging
- Use `print()` statements in ViewModel
- Check Xcode console for errors
- Use SwiftUI previews for UI development

### Performance
- Keep views simple
- Use `@StateObject` for ViewModels
- Lazy load images and data

### Best Practices
- One feature per module
- Reuse UI components
- Write tests for new features
- Document complex logic

---

## 🎨 UI Previews

All components support SwiftUI previews:

```swift
#Preview {
    TemperatureDisplay(
        temperature: -25,
        size: .large
    )
    .padding()
    .background(Color.backgroundPrimary)
}
```

Click the preview canvas to see live updates!

---

## 📞 Getting Help

### Check Documentation
1. Read us.md for architecture
2. Check QUICKSTART.md for setup
3. Review CONFIGURATION.md for config

### Debug Issues
1. Check Xcode console
2. Review test output
3. Inspect SwiftUI previews
4. Read error messages carefully

### Common Issues
- **Build errors**: Clean build folder (⇧⌘K)
- **Weather not loading**: Check internet connection
- **Location not working**: Check permissions
- **Preview errors**: Restart preview canvas

---

## ✅ Week 1 Checklist

- [x] Project structure setup
- [x] Theme system implementation
- [x] Core algorithm development
- [x] Weather integration
- [x] Vehicle management
- [x] Unit tests (14 tests)
- [x] Documentation (6 files)

**Status**: Ready for Week 2! 🚀

---

## 🎯 Week 2 Goals

- [ ] Push notifications
- [ ] Haptic feedback
- [ ] Tesla API integration
- [ ] Vehicle edit functionality
- [ ] Improve test coverage to 60%

---

## 📊 Project Stats

- **Files Created**: 26 Swift files
- **Lines of Code**: ~2,500+
- **Unit Tests**: 14 (all passing)
- **Documentation**: 6 comprehensive guides
- **Development Time**: Week 1 complete
- **Target Launch**: Week 4

---

**HotCar** - Cold Weather Warm-Up Timer ❄️🚗🔥  
*Version 1.0.0 (Development)*  
*Last Updated: March 9, 2026*
