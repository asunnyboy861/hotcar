# HotCar Configuration Guide

## ⚙️ Required Configuration

### 1. Info.plist Settings

Since Xcode 15+ uses synchronized file system, Info.plist settings are managed in project settings.

#### Location Permissions

Add these to your target's Info.plist:

1. Open project in Xcode
2. Select "hotcar" target
3. Go to "Info" tab
4. Add the following keys:

```
NSLocationWhenInUseUsageDescription
Value: HotCar needs your location to provide accurate weather data for warm-up calculations.

NSLocationAlwaysAndWhenInUseUsageDescription  
Value: HotCar uses your location to fetch local weather conditions.
```

#### Background Modes (Optional - for future features)

```
UIBackgroundModes
Type: Array
Items:
  - fetch
  - remote-notification
```

### 2. Signing & Capabilities

1. Select "hotcar" target
2. Go to "Signing & Capabilities" tab
3. Select your Team
4. Ensure Bundle Identifier is unique (e.g., com.yourname.hotcar)

### 3. Deployment Target

Verify deployment target:
- iOS Deployment Target: **17.0**
- Devices: **iPhone**

### 4. Build Settings

#### Swift Compiler - Custom Flags

Add to "Other Swift Flags":
```
-D DEBUG  (for Debug configuration)
```

#### Optimization Level

- Debug: **Onone**
- Release: **Osize**

---

## 🎯 Optional Configurations

### Enable SwiftLint (Recommended)

1. Install SwiftLint:
```bash
brew install swiftlint
```

2. Create `.swiftlint.yml` in project root:

```yaml
disabled_rules:
  - line_length
  - function_body_length
  
opt_in_rules:
  - force_unwrapping
  - file_header
  
included:
  - hotcar/hotcar
  - hotcar/hotcarTests
  
excluded:
  - hotcarTests/hotcarUITests

custom_rules:
  no_force_try:
    regex: "try!"
    message: "Avoid using try! without proper error handling"
    severity: warning
```

3. Add SwiftLint build phase:
   - Target → Build Phases → + → New Run Script Phase
   - Script: `if which swiftlint >/dev/null; then swiftlint; fi`

### App Icon Configuration

1. Create app icons in all required sizes
2. Add to `Assets.xcassets/AppIcon.appiconset`
3. Update `Contents.json`

### Accent Color

Current accent color is defined in `ColorPalette.swift`. To change:

1. Open `UI/Theme/ColorPalette.swift`
2. Modify `hotCarPrimary` color:
```swift
static let hotCarPrimary = Color(red: 0.0, green: 0.48, blue: 1.0)
```

---

## 🔧 Development Configuration

### Debug vs Release

#### Debug Configuration
- Full symbols
- No optimization
- Debug assertions enabled
- Print statements active

#### Release Configuration
- Optimized code
- Stripped symbols
- Smaller binary size
- Faster performance

### Environment Variables (for future API keys)

Create `Config.swift`:

```swift
enum Config {
    #if DEBUG
    static let apiEndpoint = "https://api.open-meteo.com/v1"
    #else
    static let apiEndpoint = "https://api.open-meteo.com/v1"
    #endif
}
```

### Feature Flags

For gradual feature rollout:

```swift
enum FeatureFlags {
    static let enableTeslaIntegration = false
    static let enableStatistics = true
    static let enableWidgets = false
}
```

---

## 📱 Testing Configuration

### Simulator Setup

#### Default Simulator
- iPhone 15 Pro (iOS 17.0+)
- Good balance of screen size and performance

#### Additional Test Devices
- iPhone SE (compact layout)
- iPhone 15 Pro Max (large layout)
- iPad Air (adaptive layout)

### Test Plans

Create custom test plans for different scenarios:

1. **Unit Tests** - Algorithm testing
2. **UI Tests** - User interaction testing
3. **Integration Tests** - API integration testing

### Continuous Integration

For GitHub Actions, create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build
      run: xcodebuild -project hotcar/hotcar.xcodeproj -scheme hotcar -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
    
    - name: Test
      run: xcodebuild test -project hotcar/hotcar.xcodeproj -scheme hotcar -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## 🚀 Production Configuration

### App Store Connect Setup

1. **Create App Record**
   - Go to App Store Connect
   - Create new app
   - Bundle ID: com.yourname.hotcar
   - Primary Language: English

2. **App Information**
   - Category: Weather / Utilities
   - Age Rating: 4+
   - Price: $4.99 (One-time purchase)

3. **Build Upload**
   - Archive in Xcode
   - Upload to App Store Connect
   - Select build for review

### Privacy Configuration

#### Privacy Labels

Answer these for App Store:

**Data Used to Track You**: None

**Data Linked to You**: None

**Data Not Linked to You**:
- Location (approximate, for weather)
- Usage Data (app interactions)

#### Privacy Policy

Create simple privacy policy:

```markdown
# HotCar Privacy Policy

## Data Collection

HotCar does NOT collect, store, or share any personal data.

## Location Services

- Location is used ONLY for weather data
- Location data stays on your device
- No third-party sharing

## Data Storage

- All data stored locally on device
- No cloud sync
- No analytics

## Third-Party Services

- Open-Meteo API (weather data)
- No tracking or analytics SDKs

## Children's Privacy

HotCar does not knowingly collect data from children under 13.

## Changes

This policy may be updated. Continued use constitutes acceptance.

## Contact

For privacy questions: privacy@hotcar.app
```

---

## 📊 Analytics Configuration (Optional)

If you want to add analytics (not recommended per us.md):

### Privacy-Friendly Analytics

Consider self-hosted solutions:
- Plausible Analytics
- Fathom Analytics
- Matomo

**Do NOT use**:
- Google Analytics (privacy concerns)
- Facebook Analytics (tracking)
- Firebase Analytics (data collection)

---

## 🔐 Security Best Practices

### API Keys

If adding API keys in future:

1. **Never commit keys to git**
2. Use `.env` file (add to `.gitignore`)
3. Load from environment variables
4. Use Apple's Secure Enclave for sensitive data

### Code Obfuscation

Not necessary for HotCar, but options include:
- Symbol stripping
- Control flow obfuscation
- String encryption

### Jailbreak Detection

Not implemented (not needed for this app type)

---

## 🎨 Customization Guide

### Change Brand Colors

Edit `ColorPalette.swift`:

```swift
// Primary brand color (currently blue)
static let hotCarPrimary = Color(red: 0.0, green: 0.48, blue: 1.0)

// Secondary color (currently orange)
static let hotCarSecondary = Color(red: 1.0, green: 0.59, blue: 0.0)
```

### Change App Name

1. Go to project settings
2. Select target
3. Change "Display Name" in General tab
4. Update in Info.plist: `CFBundleDisplayName`

### Change Bundle ID

1. Go to project settings
2. Select target
3. Change "Bundle Identifier"
4. Update in all entitlement files

---

## 🐛 Common Configuration Issues

### Issue: "No provisioning profiles found"

**Solution**:
1. Go to Xcode → Preferences → Accounts
2. Select your Apple ID
3. Click "Manage Certificates"
4. Add iOS Signing Certificate
5. Download provisioning profiles

### Issue: "Code signing failed"

**Solution**:
1. Check team selection
2. Verify bundle ID uniqueness
3. Ensure certificate is valid
4. Try "Automatically manage signing"

### Issue: "App not appearing on device"

**Solution**:
1. Check device is trusted
2. Go to Settings → General → VPN & Device Management
3. Trust your developer certificate
4. Restart device

### Issue: "Location not updating"

**Solution**:
1. Check Info.plist permissions
2. Verify location services enabled
3. Test on real device (simulator has limited location)
4. Check authorization status

---

## ✅ Configuration Checklist

### Development
- [ ] Xcode 15.0+ installed
- [ ] Team selected in Signing
- [ ] Bundle ID configured
- [ ] Deployment target set to 17.0
- [ ] Location permissions added to Info.plist
- [ ] SwiftLint configured (optional)

### Testing
- [ ] Simulator configured
- [ ] Test plan created
- [ ] Unit tests passing
- [ ] UI tests configured

### Production
- [ ] App Store Connect account setup
- [ ] Privacy policy created
- [ ] App icons prepared
- [ ] Screenshots captured
- [ ] Privacy labels completed
- [ ] Build archived successfully

---

## 📚 Additional Resources

### Apple Documentation
- [App Store Connect Guide](https://help.apple.com/app-store-connect/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Privacy Compliance
- [GDPR Guide](https://gdpr.eu/)
- [CCPA Guide](https://oag.ca.gov/privacy/ccpa)
- [PIPEDA Guide](https://www.priv.gc.ca/)

### Technical Resources
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [Core Location](https://developer.apple.com/documentation/corelocation)

---

## 🎉 Next Steps

After configuration:

1. **Build and Run** - See QUICKSTART.md
2. **Test Functionality** - Verify all features work
3. **Customize Theme** - Adjust colors and fonts
4. **Add Content** - Create sample vehicles
5. **Prepare for Launch** - Follow Week 4 roadmap

Configuration complete! Ready to code! 🚀
