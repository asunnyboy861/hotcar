//
//  MaintenanceRemindersViewModel.swift
//  hotcar
//
//  HotCar Vehicle Management - Maintenance Reminders ViewModel
//

import Foundation

@MainActor
final class MaintenanceRemindersViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var reminders: [MaintenanceReminder] = []
    
    // MARK: - Computed Properties
    
    var overdueReminders: [MaintenanceReminder] {
        reminders.filter { $0.isOverdue }
    }
    
    var upcomingReminders: [MaintenanceReminder] {
        reminders.filter { !$0.isCompleted && !$0.isOverdue }
    }
    
    var completedReminders: [MaintenanceReminder] {
        reminders.filter { $0.isCompleted }
    }
    
    // MARK: - Dependencies
    
    private let maintenanceService = MaintenanceService.shared
    
    // MARK: - Public Methods
    
    func loadReminders(for vehicleId: String) {
        reminders = maintenanceService.getScheduledReminders(for: vehicleId)
    }
    
    func completeReminder(_ reminder: MaintenanceReminder) async {
        await maintenanceService.markReminderAsCompleted(reminder.id)
        loadReminders(for: reminder.vehicleId)
    }
    
    func deleteReminder(_ reminder: MaintenanceReminder) async {
        await maintenanceService.deleteReminder(reminder)
        loadReminders(for: reminder.vehicleId)
    }
    
    func generateStandardReminders() async {
        // This would need vehicleId passed in
        // For now, using a placeholder
        await maintenanceService.generateStandardReminders(for: "1")
        loadReminders(for: "1")
    }
}
