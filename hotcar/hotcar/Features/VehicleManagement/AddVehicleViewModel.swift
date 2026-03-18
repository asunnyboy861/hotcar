//
//  AddVehicleViewModel.swift
//  hotcar
//
//  HotCar Vehicle Management - Add Vehicle ViewModel
//

import Foundation

@MainActor
final class AddVehicleViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var vehicleName: String = ""
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedType: String = VehicleType.sedan.rawValue
    @Published var selectedEngineType: String = EngineType.gasoline.rawValue
    @Published var hasBlockHeater: Bool = false
    @Published var isPluggedIn: Bool = false
    @Published var isPrimary: Bool = false
    @Published var brand: String = ""
    @Published var vin: String = ""
    @Published var apiToken: String = ""
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !vehicleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 20)...currentYear).reversed()
    }
    
    var selectedVehicleType: VehicleType {
        VehicleType(rawValue: selectedType) ?? .sedan
    }
    
    var selectedEngineTypeValue: EngineType {
        EngineType(rawValue: selectedEngineType) ?? .gasoline
    }
    
    // MARK: - Dependencies
    
    private let vehicleService = VehicleService.shared
    
    // MARK: - Public Methods
    
    func saveVehicle() async {
        let newVehicle = Vehicle(
            name: vehicleName,
            year: selectedYear,
            type: selectedVehicleType,
            engineType: selectedEngineTypeValue,
            hasBlockHeater: hasBlockHeater,
            isPluggedIn: isPluggedIn,
            isPrimary: isPrimary,
            brand: brand.isEmpty ? nil : brand,
            vin: vin.isEmpty ? nil : vin,
            apiToken: apiToken.isEmpty ? nil : apiToken
        )
        
        await vehicleService.addVehicle(newVehicle)
        
        if vehicleService.getPrimaryVehicle() == nil {
            await vehicleService.setPrimaryVehicle(newVehicle)
        }
    }
}
