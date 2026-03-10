//
//  SettingsViewModel.swift
//  hotcar
//
//  HotCar Settings - ViewModel
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var temperatureUnit: AppSettings.TemperatureUnit = .celsius
    @Published var defaultTargetTemp: Double = 20.0
    @Published var defaultTimerDuration: Int = 15
    @Published var autoStartTimer: Bool = false
    @Published var showNotifications: Bool = true
    @Published var hapticFeedback: Bool = true
    @Published var darkMode: AppSettings.DarkModeSetting = .system
    @Published var analyticsEnabled: Bool = true
    @Published var crashReportingEnabled: Bool = true
    
    // MARK: - Computed Properties
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    // MARK: - Dependencies
    
    private let settingsService = SettingsService.shared
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    func loadSettings() {
        temperatureUnit = settingsService.settings.temperatureUnit
        defaultTargetTemp = settingsService.settings.defaultTargetTemp
        defaultTimerDuration = settingsService.settings.defaultTimerDuration
        autoStartTimer = settingsService.settings.autoStartTimer
        showNotifications = settingsService.settings.showNotifications
        hapticFeedback = settingsService.settings.hapticFeedback
        darkMode = settingsService.settings.darkMode
        analyticsEnabled = settingsService.settings.analyticsEnabled
        crashReportingEnabled = settingsService.settings.crashReportingEnabled
    }
    
    func saveSettings() {
        settingsService.updateTemperatureUnit(temperatureUnit)
        settingsService.updateDefaultTimerDuration(defaultTimerDuration)
        settingsService.updateAutoStartTimer(autoStartTimer)
        settingsService.updateNotifications(showNotifications)
        settingsService.updateHapticFeedback(hapticFeedback)
        settingsService.updateDarkMode(darkMode)
    }
    
    func exportData() {
        // Export user data to JSON
        let data = StatisticsService.shared.exportData()
        
        // Share via UIActivityViewController
        shareData(data)
    }
    
    func clearAllData() {
        // Clear all user data
        UserDefaults.standard.removeObject(forKey: "com.hotcar.sessions")
        UserDefaults.standard.removeObject(forKey: "com.hotcar.vehicles")
        UserDefaults.standard.removeObject(forKey: "com.hotcar.maintenance")
        
        // Reload settings
        loadSettings()
    }
    
    func resetToDefaults() {
        settingsService.resetToDefaults()
        loadSettings()
    }
    
    func showPrivacyPolicy() {
        openURL("https://hotcar.app/privacy")
    }
    
    func showTermsOfService() {
        openURL("https://hotcar.app/terms")
    }
    
    func contactSupport() {
        openURL("mailto:support@hotcar.app")
    }
    
    // MARK: - Private Methods
    
    private func shareData(_ data: String) {
        guard let url = URL(string: "data:text/plain,\(data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return
        }
        
        openURL(url)
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
