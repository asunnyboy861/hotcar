//
//  AppSettings.swift
//  hotcar
//
//  HotCar Settings - App Settings Model
//  Enhanced with region-based defaults
//

import Foundation

struct AppSettings: Codable {
    // Temperature
    var temperatureUnit: TemperatureUnit
    var defaultTargetTemp: Double = 68.0 // 20°C in Fahrenheit
    
    // Timer
    var defaultTimerDuration: Int = 15
    var autoStartTimer: Bool = false
    var showNotifications: Bool = true
    var hapticFeedback: Bool = true
    var notificationSound: NotificationSound = .default
    
    // Vehicle
    var primaryVehicleId: String?
    var autoDetectLocation: Bool = true
    
    // Appearance
    var darkMode: DarkModeSetting = .system
    
    // Privacy
    var analyticsEnabled: Bool = true
    var crashReportingEnabled: Bool = true
    
    // Weather Alerts
    var enableWeatherAlerts: Bool = true
    var extremeColdThreshold: Double = -30.0
    var temperatureDropThreshold: Double = 10.0
    var enableMorningForecast: Bool = true
    var morningForecastTime: String = "20:00"
    
    // MARK: - Initialization with Region Detection
    
    init() {
        // Detect user's region and set default temperature unit
        let locale = Locale.current
        let regionCode = locale.region?.identifier ?? "US"
        
        // Use Fahrenheit for US, Liberia, Myanmar; Celsius for others
        let fahrenheitRegions = ["US", "LR", "MM"]
        self.temperatureUnit = fahrenheitRegions.contains(regionCode) ? .fahrenheit : .celsius
    }
    
    // MARK: - Nested Types
    
    enum TemperatureUnit: String, Codable, CaseIterable {
        case celsius = "celsius"
        case fahrenheit = "fahrenheit"
        
        var displayName: String {
            switch self {
            case .celsius: return "Celsius (°C)"
            case .fahrenheit: return "Fahrenheit (°F)"
            }
        }
        
        var symbol: String {
            switch self {
            case .celsius: return "°C"
            case .fahrenheit: return "°F"
            }
        }
        
        /// Convert from Celsius to current unit
        func convert(from celsius: Double) -> Double {
            switch self {
            case .celsius:
                return celsius
            case .fahrenheit:
                return (celsius * 9/5) + 32
            }
        }
        
        /// Convert from current unit to Celsius
        func convertToCelsius(_ value: Double) -> Double {
            switch self {
            case .celsius:
                return value
            case .fahrenheit:
                return (value - 32) * 5/9
            }
        }
        
        /// Format temperature with unit symbol
        func format(_ celsius: Double) -> String {
            let value = convert(from: celsius)
            return String(format: "%.0f%@", value, symbol)
        }
        
        /// Format temperature with decimal precision
        func format(_ celsius: Double, decimals: Int) -> String {
            let value = convert(from: celsius)
            let formatString = "%.\(decimals)f%@"
            return String(format: formatString, value, symbol)
        }
    }
    
    enum DarkModeSetting: String, Codable, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
    }
    
    enum NotificationSound: String, Codable, CaseIterable {
        case `default` = "default"
        case gentle = "gentle"
        case loud = "loud"
        case silent = "silent"
        
        var displayName: String {
            switch self {
            case .default: return "Default"
            case .gentle: return "Gentle"
            case .loud: return "Loud"
            case .silent: return "Silent"
            }
        }
        
        var soundName: String? {
            switch self {
            case .default: return nil
            case .gentle: return "note"
            case .loud: return "alarm"
            case .silent: return ""
            }
        }
    }
}

// MARK: - Settings Service

@MainActor
final class SettingsService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SettingsService()
    
    // MARK: - Published Properties
    
    @Published var settings: AppSettings
    
    // MARK: - Dependencies
    
    private let storageKey = "com.hotcar.settings"
    
    // MARK: - Initialization
    
    private init() {
        // Try to load saved settings
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            // Create new settings with region detection
            settings = AppSettings()
        }
    }
    
    // MARK: - Public Methods
    
    func loadSettings() async {
        // Already loaded in init
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
        
        // Post notification for temperature display updates
        NotificationCenter.default.post(
            name: .temperatureUnitDidChange,
            object: nil,
            userInfo: ["unit": settings.temperatureUnit]
        )
    }
    
    func updateTemperatureUnit(_ unit: AppSettings.TemperatureUnit) {
        settings.temperatureUnit = unit
        saveSettings()
    }
    
    func updateDefaultTimerDuration(_ minutes: Int) {
        settings.defaultTimerDuration = minutes
        saveSettings()
    }
    
    func updateAutoStartTimer(_ enabled: Bool) {
        settings.autoStartTimer = enabled
        saveSettings()
    }
    
    func updateNotifications(_ enabled: Bool) {
        settings.showNotifications = enabled
        saveSettings()
    }
    
    func updateHapticFeedback(_ enabled: Bool) {
        settings.hapticFeedback = enabled
        saveSettings()
    }
    
    func updateNotificationSound(_ sound: AppSettings.NotificationSound) {
        settings.notificationSound = sound
        saveSettings()
    }
    
    func updateDarkMode(_ mode: AppSettings.DarkModeSetting) {
        settings.darkMode = mode
        saveSettings()
    }
    
    func updatePrimaryVehicle(_ vehicleId: String?) {
        settings.primaryVehicleId = vehicleId
        saveSettings()
    }
    
    func resetToDefaults() {
        settings = AppSettings()
        saveSettings()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let temperatureUnitDidChange = Notification.Name("temperatureUnitDidChange")
}
