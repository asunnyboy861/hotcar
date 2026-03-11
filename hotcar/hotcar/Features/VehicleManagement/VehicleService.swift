//
//  VehicleService.swift
//  hotcar
//
//  HotCar Service - Vehicle Management
//  Handles vehicle CRUD operations and persistence
//

import Foundation

@MainActor
final class VehicleService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = VehicleService()
    
    // MARK: - Published Properties
    
    @Published var vehicles: [Vehicle] = []
    
    // MARK: - Constants
    
    private let storageKey = "com.hotcar.vehicles"
    
    // MARK: - Initialization
    
    private init() {
        loadVehiclesSync()
    }
    
    // MARK: - Public Methods
    
    func loadVehicles() async {
        loadVehiclesSync()
    }
    
    private func loadVehiclesSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Vehicle].self, from: data) else {
            vehicles = []
            return
        }
        vehicles = decoded
    }
    
    func saveVehicles() {
        if let encoded = try? JSONEncoder().encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addVehicle(_ vehicle: Vehicle) async {
        vehicles.append(vehicle)
        saveVehicles()
    }
    
    func updateVehicle(_ vehicle: Vehicle) async {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
            saveVehicles()
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) async {
        vehicles.removeAll { $0.id == vehicle.id }
        saveVehicles()
    }
    
    func setPrimaryVehicle(_ vehicle: Vehicle) async {
        // Remove primary from all vehicles
        for index in vehicles.indices {
            vehicles[index].isPrimary = false
        }
        
        // Set new primary
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index].isPrimary = true
            saveVehicles()
        }
    }
    
    func getPrimaryVehicle() -> Vehicle? {
        return vehicles.first { $0.isPrimary }
    }
}
