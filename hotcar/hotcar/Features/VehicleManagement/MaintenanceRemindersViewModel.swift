//
//  MaintenanceRemindersViewModel.swift
//  hotcar
//
//  HotCar Vehicle Management - Maintenance Reminders ViewModel
//

import Foundation
import Combine

// MARK: - Notification Names

@available(*, deprecated, message: "Use Combine subscription to MaintenanceService.shared.$reminders instead")
extension Notification.Name {
    static let maintenanceReminderAdded = Notification.Name("maintenanceReminderAdded")
}

@MainActor
final class MaintenanceRemindersViewModel: ObservableObject {   
    // MARK: - Published Properties
    
    @Published var reminders: [MaintenanceReminder] = []
    
    // MARK: - Properties
    
    private let vehicleId: String
    private let maintenanceService = MaintenanceService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(vehicleId: String) {
        self.vehicleId = vehicleId
        setupBindings()
        loadInitialData()
    }
    
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
    
    // MARK: - Combine Bindings
    
    private func setupBindings() {
        maintenanceService.$reminders
            .receive(on: RunLoop.main)
            .sink { [weak self] allReminders in
                guard let self = self else { return }
                // Filter reminders for current vehicle and sort by due date
                self.reminders = allReminders
                    .filter { $0.vehicleId == self.vehicleId }
                    .sorted { reminder1, reminder2 in
                        guard let date1 = reminder1.dueDate, let date2 = reminder2.dueDate else {
                            return reminder1.createdAt < reminder2.createdAt
                        }
                        return date1 < date2
                    }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Initial Data Load
    
    private func loadInitialData() {
        reminders = maintenanceService.getScheduledReminders(for: vehicleId)
    }
    
    // MARK: - Public Methods
    
    @available(*, deprecated, message: "Use Combine binding instead, data refreshes automatically")
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
