//
//  AppSettings.swift
//  hotcar
//
//  HotCar Settings - App Settings Model
//

import Foundation

struct AppSettings: Codable {
    // Temperature
    var temperatureUnit: TemperatureUnit = .celsius
    var defaultTargetTemp: Double = 20.0
    
    // Timer
    var defaultTimerDuration: Int = 15
    var autoStartTimer: Bool = false
    var showNotifications: Bool = true
    var hapticFeedback: Bool = true
    
    // Vehicle
    var primaryVehicleId: String?
    var autoDetectLocation: Bool = true
    
    // Appearance
    var darkMode: DarkModeSetting = .system
    
    // Privacy
    var analyticsEnabled: Bool = true
    var crashReportingEnabled: Bool = true
    
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
        
        func convert(from celsius: Double) -> Double {
            switch self {
            case .celsius:
                return celsius
            case .fahrenheit:
                return (celsius * 9/5) + 32
            }
        }
        
        func convertToCelsius(_ value: Double) -> Double {
            switch self {
            case .celsius:
                return value
            case .fahrenheit:
                return (value - 32) * 5/9
            }
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
}

// MARK: - Settings Service

@MainActor
final class SettingsService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SettingsService()
    
    // MARK: - Published Properties
    
    @Published var settings: AppSettings = AppSettings()
    
    // MARK: - Dependencies
    
    private let storageKey = "com.hotcar.settings"
    
    // MARK: - Initialization
    
    private init() {
        loadSettingsSync()
    }
    
    // MARK: - Public Methods
    
    func loadSettings() async {
        loadSettingsSync()
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
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
    
    // MARK: - Private Methods
    
    private func loadSettingsSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            settings = AppSettings()
            return
        }
        settings = decoded
    }
}
