//
//  WeatherAlertService.swift
//  hotcar
//
//  HotCar Service - Weather Alert Management
//  Monitors weather conditions and generates alerts
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class WeatherAlertService: ObservableObject {
    
    static let shared = WeatherAlertService()
    
    @Published var activeAlerts: [WeatherAlert] = []
    @Published var isMonitoring: Bool = false
    
    private let weatherService = WeatherService.shared
    private let notificationService = NotificationService.shared
    private let settingsService = SettingsService.shared
    private let storageKey = "com.hotcar.weatheralerts"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadAlertsSync()
        setupAutoMonitoring()
    }
    
    func loadAlerts() async {
        loadAlertsSync()
    }
    
    private func loadAlertsSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WeatherAlert].self, from: data) else {
            activeAlerts = []
            return
        }
        activeAlerts = decoded.filter { $0.expiresAt == nil || $0.expiresAt! > Date() }
    }
    
    func checkAndGenerateAlerts() async {
        guard let currentTemp = weatherService.currentTemperature else { return }
        
        var newAlerts: [WeatherAlert] = []
        
        if let alert = checkExtremeCold(temperature: currentTemp) {
            newAlerts.append(alert)
        }
        
        if let alert = checkTemperatureDrop() {
            newAlerts.append(alert)
        }
        
        for alert in newAlerts {
            await saveAlert(alert)
            await sendAlertNotification(alert)
        }
    }
    
    func markAlertAsRead(_ alertId: String) async {
        if let index = activeAlerts.firstIndex(where: { $0.id == alertId }) {
            activeAlerts[index].isRead = true
            saveAlertsSync()
        }
    }
    
    func clearAllAlerts() async {
        activeAlerts.removeAll()
        saveAlertsSync()
    }
    
    private func checkExtremeCold(temperature: Double) -> WeatherAlert? {
        let threshold = settingsService.settings.extremeColdThreshold
        guard temperature < threshold else { return nil }
        
        return WeatherAlert(
            id: UUID().uuidString,
            type: .extremeCold,
            title: "⚠️ Extreme Cold Warning",
            message: String(format: "Current temperature is %.1f°F. Use block heater and extend warm-up time.", temperature),
            createdAt: Date(),
            expiresAt: nil,
            isRead: false,
            metadata: nil
        )
    }
    
    private func checkTemperatureDrop() -> WeatherAlert? {
        guard let currentTemp = weatherService.currentTemperature,
              let yesterdayTemp = weatherService.tomorrowMorningTemp else {
            return nil
        }
        
        let threshold = settingsService.settings.temperatureDropThreshold
        let temperatureChange = yesterdayTemp - currentTemp
        
        guard temperatureChange > threshold else { return nil }
        
        return WeatherAlert(
            id: UUID().uuidString,
            type: .temperatureDrop,
            title: "🌡️ Temperature Drop Alert",
            message: String(format: "Temperature will drop by %.1f°F tomorrow. Plan accordingly.", temperatureChange),
            createdAt: Date(),
            expiresAt: nil,
            isRead: false,
            metadata: nil
        )
    }
    
    private func saveAlert(_ alert: WeatherAlert) async {
        activeAlerts.append(alert)
        saveAlertsSync()
    }
    
    private func saveAlertsSync() {
        if let encoded = try? JSONEncoder().encode(activeAlerts) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func sendAlertNotification(_ alert: WeatherAlert) async {
        guard settingsService.settings.enableWeatherAlerts else { return }
        
        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        content.sound = UNNotificationSound.default
        content.userInfo = ["alertId": alert.id, "alertType": alert.type.rawValue]
        
        let request = UNNotificationRequest(
            identifier: "weather_alert_\(alert.id)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending weather alert: \(error)")
        }
    }
    
    private func setupAutoMonitoring() {
        weatherService.$currentTemperature
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.checkAndGenerateAlerts()
                }
            }
            .store(in: &cancellables)
    }
}
