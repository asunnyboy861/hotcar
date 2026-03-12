//
//  VehicleListViewModel.swift
//  hotcar
//
//  HotCar Vehicle Management - List ViewModel
//

import Foundation
import Combine

@MainActor
final class VehicleListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var vehicles: [Vehicle] = []
    
    // MARK: - Dependencies
    
    private let vehicleService = VehicleService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadVehicles()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        vehicleService.$vehicles
            .receive(on: RunLoop.main)
            .sink { [weak self] vehicles in
                self?.vehicles = vehicles
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadVehicles() {
        Task {
            await vehicleService.loadVehicles()
        }
    }
    
    func setPrimaryVehicle(_ vehicle: Vehicle) {
        Task {
            await vehicleService.setPrimaryVehicle(vehicle)
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        Task {
            await vehicleService.deleteVehicle(vehicle)
        }
    }
    
    func getReminderCount(for vehicleId: String) -> Int {
        let reminders = MaintenanceService.shared.getScheduledReminders(for: vehicleId)
        return reminders.filter { !$0.isCompleted }.count
    }
}
