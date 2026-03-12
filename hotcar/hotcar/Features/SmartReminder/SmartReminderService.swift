//
//  SmartReminderService.swift
//  hotcar
//
//  HotCar Service - Smart Reminder Management
//  Manages user departure schedules and triggers reminders
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class SmartReminderService: ObservableObject {
    
    static let shared = SmartReminderService()
    
    @Published var schedules: [ReminderSchedule] = []
    @Published var isMonitoring: Bool = false
    
    private let notificationService = NotificationService.shared
    private let vehicleService = VehicleService.shared
    private let weatherService = WeatherService.shared
    private let warmUpCalculator = WarmUpCalculationEngine.self
    private let storageKey = "com.hotcar.smartreminders"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSchedulesSync()
        setupMonitoring()
    }
    
    func loadSchedules() async {
        loadSchedulesSync()
    }
    
    private func loadSchedulesSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ReminderSchedule].self, from: data) else {
            schedules = []
            return
        }
        schedules = decoded
    }
    
    func saveSchedule(_ schedule: ReminderSchedule) async {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index] = schedule
        } else {
            schedules.append(schedule)
        }
        saveSchedulesSync()
        await scheduleNotification(for: schedule)
    }
    
    func deleteSchedule(_ scheduleId: String) async {
        schedules.removeAll { $0.id == scheduleId }
        saveSchedulesSync()
        await cancelNotification(for: scheduleId)
    }
    
    func toggleSchedule(_ scheduleId: String) async {
        if let index = schedules.firstIndex(where: { $0.id == scheduleId }) {
            schedules[index].isEnabled.toggle()
            saveSchedulesSync()
            
            if schedules[index].isEnabled {
                await scheduleNotification(for: schedules[index])
            } else {
                await cancelNotification(for: scheduleId)
            }
        }
    }
    
    private func saveSchedulesSync() {
        if let encoded = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func scheduleNotification(for schedule: ReminderSchedule) async {
        guard schedule.isEnabled else { return }
        
        let warmUpTime = schedule.customWarmUpTime ?? calculateWarmUpTime()
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Time to Warm Up Your Car"
        content.body = "Departure at \(formatTime(schedule.departureTime)) • Warm-up: \(warmUpTime) min"
        content.sound = .default
        content.categoryIdentifier = "SMART_REMINDER"
        content.userInfo = [
            "scheduleId": schedule.id,
            "warmUpTime": warmUpTime,
            "vehicleId": schedule.vehicleId ?? ""
        ]
        
        let startAction = UNNotificationAction(
            identifier: "START_TIMER",
            title: "Start Timer (\(warmUpTime) min)",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_5",
            title: "Snooze 5 min",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "SMART_REMINDER",
            actions: [startAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let triggerDate = schedule.departureTime
            .addingTimeInterval(-TimeInterval(warmUpTime * 60))
            .addingTimeInterval(-TimeInterval(schedule.advanceNoticeMinutes * 60))
        
        let dateComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: triggerDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "smart_reminder_\(schedule.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling smart reminder: \(error)")
        }
    }
    
    private func cancelNotification(for scheduleId: String) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["smart_reminder_\(scheduleId)"])
    }
    
    private func calculateWarmUpTime() -> Int {
        guard let temp = weatherService.currentTemperature,
              let vehicle = vehicleService.vehicles.first else {
            return 10
        }
        
        return warmUpCalculator.calculateWarmUpTime(
            temperature: temp,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func setupMonitoring() {
        weatherService.$currentTemperature
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.rescheduleAllNotifications()
                }
            }
            .store(in: &cancellables)
    }
    
    private func rescheduleAllNotifications() async {
        for schedule in schedules where schedule.isEnabled {
            await cancelNotification(for: schedule.id)
            await scheduleNotification(for: schedule)
        }
    }
}
