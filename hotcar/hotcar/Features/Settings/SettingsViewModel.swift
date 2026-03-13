//
//  SettingsViewModel.swift
//  hotcar
//
//  HotCar Settings - ViewModel
//

import Foundation
import UIKit
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var temperatureUnit: AppSettings.TemperatureUnit = .celsius
    @Published var defaultTargetTemp: Double = 20.0
    @Published var defaultTimerDuration: Int = 15
    @Published var autoStartTimer: Bool = false
    @Published var showNotifications: Bool = true
    @Published var hapticFeedback: Bool = true
    @Published var notificationSound: AppSettings.NotificationSound = .default
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
    private var cancellables = Set<AnyCancellable>()
    private let saveSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
        setupDebounce()
    }
    
    deinit {
        // Note: We cannot call actor-isolated methods in deinit
        // The debounced save will trigger on next app cycle if needed
        // For critical saves, use saveImmediately() explicitly before dismissal
    }
    
    // MARK: - Setup
    
    private func setupDebounce() {
        saveSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.performSave()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadSettings() {
        temperatureUnit = settingsService.settings.temperatureUnit
        defaultTargetTemp = settingsService.settings.defaultTargetTemp
        defaultTimerDuration = settingsService.settings.defaultTimerDuration
        autoStartTimer = settingsService.settings.autoStartTimer
        showNotifications = settingsService.settings.showNotifications
        hapticFeedback = settingsService.settings.hapticFeedback
        notificationSound = settingsService.settings.notificationSound
        darkMode = settingsService.settings.darkMode
        analyticsEnabled = settingsService.settings.analyticsEnabled
        crashReportingEnabled = settingsService.settings.crashReportingEnabled
    }
    
    /// Trigger save with debounce
    /// Call this when settings change (e.g., in onChange modifiers)
    func triggerSave() {
        saveSubject.send()
    }
    
    /// Save immediately without debounce
    /// Use this when app is about to exit or when immediate save is required
    func saveImmediately() {
        // Cancel any pending debounced save
        cancellables.removeAll()
        performSave()
        // Re-setup debounce for future changes
        setupDebounce()
    }
    
    /// Legacy save method - now uses debounce
    /// Deprecated: Use triggerSave() for normal saves or saveImmediately() for immediate saves
    func saveSettings() {
        triggerSave()
    }
    
    private func performSave() {
        settingsService.updateTemperatureUnit(temperatureUnit)
        settingsService.updateDefaultTimerDuration(defaultTimerDuration)
        settingsService.updateAutoStartTimer(autoStartTimer)
        settingsService.updateNotifications(showNotifications)
        settingsService.updateHapticFeedback(hapticFeedback)
        settingsService.updateNotificationSound(notificationSound)
        settingsService.updateDarkMode(darkMode)
    }
    
    /// Export user data to JSON string
    /// - Returns: JSON string containing all user data
    func exportData() -> String {
        // Export user data to JSON
        return StatisticsService.shared.exportData()
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
        if let url = URL(string: "https://hotcar-privacy.zzoutuo.com") {
            openURL(url)
        }
    }
    
    func showTermsOfService() {
        if let url = URL(string: "https://hotcar-privacy.zzoutuo.com") {
            openURL(url)
        }
    }
    
    func contactSupport() {
        if let url = URL(string: "https://hotcar-support.zzoutuo.com") {
            openURL(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
