//
//  AddMaintenanceReminderViewModel.swift
//  hotcar
//
//  HotCar Vehicle Management - Add Maintenance Reminder ViewModel
//

import Foundation

@MainActor
final class AddMaintenanceReminderViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var vehicleId: String
    @Published var selectedType: String = MaintenanceType.oilChange.rawValue
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var hasDueDate: Bool = true
    @Published var dueDate: Date = Date().addingTimeInterval(90 * 24 * 60 * 60)
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var selectedMaintenanceType: MaintenanceType {
        MaintenanceType(rawValue: selectedType) ?? .oilChange
    }
    
    // MARK: - Dependencies
    
    private let maintenanceService = MaintenanceService.shared
    
    // MARK: - Initialization
    
    init(vehicleId: String) {
        self.vehicleId = vehicleId
    }
    
    // MARK: - Public Methods
    
    func saveReminder() async {
        let reminder = MaintenanceReminder(
            vehicleId: vehicleId,
            type: selectedMaintenanceType,
            title: title.isEmpty ? selectedMaintenanceType.displayName : title,
            description: description.isEmpty ? nil : description,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        await maintenanceService.addReminder(reminder)
    }
    
    func setInterval(_ days: Int) {
        dueDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
        hasDueDate = true
    }
}
