//
//  NotificationService.swift
//  hotcar
//
//  HotCar Service - Local Notifications
//  Manages timer completion and maintenance reminders
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService: NSObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationService()
    
    // MARK: - Constants
    
    enum NotificationCategory: String {
        case timerComplete = "TIMER_COMPLETE"
        case maintenanceReminder = "MAINTENANCE_REMINDER"
    }
    
    enum NotificationAction: String {
        case stopTimer = "STOP_TIMER"
        case viewMaintenance = "VIEW_MAINTENANCE"
        case snooze = "SNOOZE"
    }
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge, .criticalAlert]
            )
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func checkPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Timer Notifications
    
    func scheduleTimerCompleteNotification(minutes: Int, vehicleName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Warm-Up Complete!"
        content.body = "Your \(vehicleName) has been warming up for \(minutes) minutes. Ready to go!"
        
        let settings = SettingsService.shared.settings
        if let soundName = settings.notificationSound.soundName {
            if soundName.isEmpty {
                content.sound = nil
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
            }
        } else {
            content.sound = .default
        }
        
        if settings.hapticFeedback {
            content.sound = UNNotificationSound.defaultCritical
        }
        
        content.categoryIdentifier = NotificationCategory.timerComplete.rawValue
        
        // Add action buttons
        let stopAction = UNNotificationAction(
            identifier: NotificationAction.stopTimer.rawValue,
            title: "Stop Engine",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: NotificationCategory.timerComplete.rawValue,
            actions: [stopAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Schedule notification to fire after specified minutes
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    func cancelAllTimerNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        let timerRequests = requests.filter { request in
            request.content.categoryIdentifier == NotificationCategory.timerComplete.rawValue
        }
        
        let ids = timerRequests.map { $0.identifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    // MARK: - Maintenance Notifications
    
    func scheduleMaintenanceReminder(
        reminder: MaintenanceReminder,
        daysInAdvance: Int = 1
    ) async {
        guard let dueDate = reminder.dueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Maintenance Due"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        content.body = "\(reminder.title) is due on \(dateFormatter.string(from: dueDate))"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.maintenanceReminder.rawValue
        content.userInfo = ["reminderId": reminder.id]
        
        // Schedule notification
        let triggerDate = dueDate.addingTimeInterval(TimeInterval(-daysInAdvance * 24 * 60 * 60))
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "maintenance_\(reminder.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling maintenance notification: \(error)")
        }
    }
    
    // MARK: - Notification Handling
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case NotificationAction.stopTimer.rawValue:
            // Handle stop timer action
            NotificationCenter.default.post(name: .stopTimerFromNotification, object: nil)
            
        case NotificationAction.viewMaintenance.rawValue:
            // Handle view maintenance action
            if let reminderId = response.notification.request.content.userInfo["reminderId"] as? String {
                NotificationCenter.default.post(
                    name: .viewMaintenanceFromNotification,
                    object: nil,
                    userInfo: ["reminderId": reminderId]
                )
            }
            
        default:
            break
        }
    }
}

// MARK: - Notification Center Names

extension Notification.Name {
    static let stopTimerFromNotification = Notification.Name("stopTimerFromNotification")
    static let viewMaintenanceFromNotification = Notification.Name("viewMaintenanceFromNotification")
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task { @MainActor in
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            handleNotificationResponse(response)
            completionHandler()
        }
    }
}
