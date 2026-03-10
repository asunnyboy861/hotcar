# HotCar Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- macOS Sonoma 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Apple Developer Account (for testing on device)

### Step 1: Open Project

1. Open Terminal and navigate to project directory:
```bash
cd /Volumes/Untitled/app/20260309/hotcar
```

2. Open the project in Xcode:
```bash
open hotcar/hotcar.xcodeproj
```

### Step 2: Configure Project

1. **Select Target Device**
   - In Xcode, select your iPhone from the device list
   - Or choose a simulator (iPhone 15 Pro recommended)

2. **Signing & Capabilities**
   - Go to project settings → Signing & Capabilities
   - Select your Team
   - Ensure Bundle Identifier is unique

3. **Info.plist Configuration**
   
   Add the following keys to `Info.plist`:
   
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>HotCar needs your location to provide accurate weather data for warm-up calculations.</string>
   
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>HotCar uses your location to fetch local weather conditions.</string>
   
   <key>UIBackgroundModes</key>
   <array>
       <string>fetch</string>
       <string>remote-notification</string>
   </array>
   ```

### Step 3: Build and Run

1. **Clean Build Folder** (if needed):
   - Product → Clean Build Folder (⇧⌘K)

2. **Build Project**:
   - Product → Build (⌘B)

3. **Run App**:
   - Product → Run (⌘R)
   - Or click the Play button ▶️

### Step 4: Test the App

#### Basic Functionality Test

1. **Launch App**
   - App should open to Home screen
   - Temperature should load (default: Toronto)

2. **Add Vehicle**
   - Tap "Add Your First Vehicle" or car icon
   - Fill in vehicle details:
     - Name: "2023 Ford F-150"
     - Year: 2023
     - Type: Truck/Pickup
     - Engine: Gasoline
     - Block Heater: Yes (optional)
   - Tap "Save"

3. **Test Calculator**
   - Temperature should display
   - Recommended warm-up time should calculate
   - Tap "Start Warm-Up" to begin timer

4. **Test Timer**
   - Timer should count down
   - Progress bar should update
   - Tap "Stop Timer" to stop

#### Weather Integration Test

1. **Location Permission**
   - App will request location permission
   - Grant "Allow While Using App"

2. **Temperature Display**
   - Current temperature should update
   - Tomorrow forecast should appear

### Step 5: Run Tests

1. **Unit Tests**
```bash
# In Xcode
Test → Test (⌘U)
```

2. **Specific Test Class**
```bash
# Right-click WarmUpCalculationEngineTests.swift
# Click arrow icon to run tests
```

Expected result: All 10 tests should pass ✅

---

## 🐛 Troubleshooting

### Issue: Build Errors

**Problem**: "No such module" errors

**Solution**:
1. Check that all files are in the correct target
2. Go to File → Get Info → Ensure target is "hotcar"
3. Clean build folder and rebuild

### Issue: Weather Not Loading

**Problem**: Temperature shows "Unable to load"

**Solution**:
1. Check internet connection
2. Verify Open-Meteo API is accessible
3. Check location permissions in Settings

**Test API manually**:
```bash
curl "https://api.open-meteo.com/v1/forecast?latitude=43.6532&longitude=-79.3832&current_weather=true"
```

### Issue: Location Not Working

**Problem**: Location permission denied

**Solution**:
1. Go to Settings → Privacy → Location Services
2. Enable Location Services
3. Find HotCar app and set to "While Using"

### Issue: Simulator Location

**Problem**: Simulator shows wrong location

**Solution**:
1. In Simulator: Features → Location → Custom Location
2. Set to desired coordinates (e.g., Toronto: 43.6532, -79.3832)

---

## 📱 Simulator Setup

### Recommended Simulator Settings

1. **iPhone 15 Pro** (iOS 17.0+)
   - Best for testing modern SwiftUI features
   - Good screen size for layout testing

2. **iPhone SE** (iOS 17.0+)
   - Test compact layouts
   - Ensure usability on smaller screens

3. **iPad Air** (iPadOS 17.0+)
   - Test adaptive layouts
   - Future iPad optimization

### Multiple Simultaneous Simulators

Test on multiple devices:
1. Open multiple simulators from Xcode
2. Run app on both to test different screen sizes

---

## 🔧 Development Tips

### Enable SwiftUI Previews

1. **Canvas Updates**
   - Editor → Canvas (⌥⌘⏎)
   - Enable "Automatically Refresh Canvas"

2. **Live Previews**
   - Click "Live" button in preview
   - Interact with components

### Debugging

1. **Print Statements**
```swift
print("Temperature: \(temperature)")
print("Calculated time: \(warmUpTime) minutes")
```

2. **Xcode Debugger**
   - Set breakpoints by clicking line numbers
   - Use console: `po variableName`

3. **View Hierarchy**
   - Debug → View Debugging → Capture View Hierarchy
   - Inspect SwiftUI view tree

### Performance

1. **Check Build Time**
```bash
defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES
```

2. **Optimize Previews**
   - Use `#if DEBUG` for preview data
   - Keep previews simple

---

## 📊 Code Organization

### Feature Modules

Each feature is self-contained:
```
Features/
├── Home/
│   ├── HomeView.swift
│   └── HomeViewModel.swift
├── WarmUpCalculator/
│   ├── WarmUpCalculationEngine.swift
│   ├── WarmUpCalculatorView.swift
│   └── WarmUpCalculatorViewModel.swift
...
```

### Adding New Features

1. Create folder in `Features/`
2. Add View, ViewModel, Service files
3. Import in ContentView or Navigation

### UI Components

Reusable components in `UI/Components/`:
- Follow single responsibility
- Accept configuration via @State/@Binding
- Include #Preview blocks

---

## 🎨 Design System

### Colors

Access via `Color.hotCarPrimary`, etc.

```swift
// Brand Colors
Color.hotCarPrimary      // Blue
Color.hotCarSecondary    // Orange

// Semantic Colors
Color.warmUpActive       // Red (timer running)
Color.warmUpReady        // Green (complete)
Color.warmUpWaiting      // Yellow (pending)

// Backgrounds
Color.backgroundPrimary   // Darkest
Color.backgroundSecondary // Cards
Color.backgroundCard      // Elevated
```

### Typography

```swift
Font.hotCarDisplay       // 64pt - Temperature
Font.hotCarTimer         // 48pt - Timer
Font.hotCarLargeTitle    // 34pt - Screen titles
Font.hotCarTitle         // 24pt - Card titles
Font.hotCarHeadline      // 18pt - Subheaders
Font.hotCarBody          // 16pt - Body text
Font.hotCarCaption       // 14pt - Captions
Font.hotCarMonospaced    // 48pt - Timer digits
```

### Spacing

```swift
.hotCarSpacingXs   // 4pt
.hotCarSpacingSm   // 8pt
.hotCarSpacingMd   // 16pt
.hotCarSpacingLg   // 24pt
.hotCarSpacingXl   // 32pt
.hotCarSpacingXxl  // 48pt
```

---

## 🧪 Testing Commands

### Run All Tests
```bash
xcodebuild test \
  -project hotcar/hotcar.xcodeproj \
  -scheme hotcar \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Run Specific Test
```bash
xcodebuild test \
  -project hotcar/hotcar.xcodeproj \
  -scheme hotcar \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:hotcarTests/WarmUpCalculationEngineTests
```

---

## 📦 Dependencies

### Built-in Frameworks (No external dependencies)

- **SwiftUI** - UI framework
- **Combine** - Reactive programming
- **CoreLocation** - Location services
- **Foundation** - Base types
- **UserNotifications** - Notifications (future)

### Future Dependencies (Optional)

- **SwiftLint** - Code linting
- **SnapshotTesting** - UI testing
- **SwiftGen** - Asset generation

---

## 🎯 Next Steps

After getting the app running:

1. **Customize Theme**
   - Adjust colors in ColorPalette.swift
   - Modify fonts in Typography.swift

2. **Add Your Vehicle**
   - Test with real vehicle data
   - Verify warm-up calculations

3. **Test in Cold Weather**
   - Use app in actual cold conditions
   - Verify usability with gloves

4. **Explore Code**
   - Review calculation algorithm
   - Understand MVVM pattern

5. **Plan Next Features**
   - Check PROJECT_SUMMARY.md
   - Review us.md roadmap

---

## 📞 Support

### Documentation

- **us.md** - Complete operation guide
- **PROJECT_SUMMARY.md** - Development summary
- **DEVELOPMENT_PROGRESS.md** - Current progress

### Code References

All files are well-documented with:
- Inline comments
- MARK sections
- XML documentation

### Getting Help

1. Check Xcode console for errors
2. Review test output
3. Inspect SwiftUI previews
4. Read us.md for architecture details

---

## ✅ Success Checklist

- [ ] Project builds without errors
- [ ] App launches on simulator/device
- [ ] Temperature loads (or shows default)
- [ ] Can add a vehicle
- [ ] Warm-up time calculates correctly
- [ ] Timer starts and stops
- [ ] All unit tests pass
- [ ] Location permission works
- [ ] UI is responsive

**Congratulations!** You're ready to develop HotCar! 🎉

---

## 🚀 Quick Commands Reference

```bash
# Open project
open hotcar/hotcar.xcodeproj

# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData/hotcar-*

# Run tests
xcodebuild test -project hotcar/hotcar.xcodeproj -scheme hotcar -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Build for release
xcodebuild -project hotcar/hotcar.xcodeproj -scheme hotcar -configuration Release

# Archive for App Store
xcodebuild archive -project hotcar/hotcar.xcodeproj -scheme hotcar -archivePath ./build/hotcar.xcarchive
```

---

Happy Coding! 🌨️🚗🔥
