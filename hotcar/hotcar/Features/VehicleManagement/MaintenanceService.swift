//
//  MaintenanceService.swift
//  hotcar
//
//  HotCar Service - Maintenance Reminder Management
//

import Foundation

@MainActor
final class MaintenanceService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = MaintenanceService()
    
    // MARK: - Published Properties
    
    @Published var reminders: [MaintenanceReminder] = []
    
    // MARK: - Constants
    
    private let storageKey = "com.hotcar.maintenance"
    
    // MARK: - Initialization
    
    private init() {
        loadRemindersSync()
    }
    
    // MARK: - Public Methods
    
    func loadReminders() async {
        loadRemindersSync()
    }
    
    private func loadRemindersSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([MaintenanceReminder].self, from: data) else {
            reminders = []
            return
        }
        reminders = decoded
    }
    
    func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addReminder(_ reminder: MaintenanceReminder) async {
        reminders.append(reminder)
        saveReminders()
    }
    
    func updateReminder(_ reminder: MaintenanceReminder) async {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
        }
    }
    
    func deleteReminder(_ reminder: MaintenanceReminder) async {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func markReminderAsCompleted(_ reminderId: String) async {
        if let index = reminders.firstIndex(where: { $0.id == reminderId }) {
            reminders[index].isCompleted = true
            reminders[index].completedDate = Date()
            saveReminders()
        }
    }
    
    func getScheduledReminders(for vehicleId: String) -> [MaintenanceReminder] {
        return reminders.filter {
            $0.vehicleId == vehicleId && !$0.isCompleted
        }.sorted {
            guard let date1 = $0.dueDate, let date2 = $1.dueDate else { return false }
            return date1 < date2
        }
    }
    
    func getOverdueReminders(for vehicleId: String) -> [MaintenanceReminder] {
        return reminders.filter {
            $0.vehicleId == vehicleId && !$0.isCompleted && $0.isOverdue
        }
    }
    
    // MARK: - Auto-Generate Reminders
    
    func generateStandardReminders(for vehicleId: String) async {
        let standardTypes: [MaintenanceType] = [
            .oilChange,
            .tireRotation,
            .brakeInspection,
            .batteryCheck,
            .winterPreparation
        ]
        
        for type in standardTypes {
            let reminder = MaintenanceReminder(
                vehicleId: vehicleId,
                type: type,
                title: type.displayName,
                dueDate: Date().addingTimeInterval(type.defaultInterval)
            )
            await addReminder(reminder)
        }
    }
}
