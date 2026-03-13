//
//  EditVehicleViewModel.swift
//  hotcar
//
//  HotCar Vehicle Management - Edit Vehicle ViewModel
//

import Foundation

@MainActor
final class EditVehicleViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var vehicleId: String
    @Published var vehicleName: String
    @Published var selectedYear: Int
    @Published var selectedType: String
    @Published var selectedEngineType: String
    @Published var hasBlockHeater: Bool
    @Published var isPluggedIn: Bool
    @Published var isPrimary: Bool
    @Published var brand: String
    @Published var vin: String
    @Published var apiToken: String
    
    // VIN Decoding
    @Published var isDecoding: Bool = false
    @Published var vinDecodingResult: String?
    
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
    private let vinDecoder = VINDecoder()
    
    // MARK: - Initialization
    
    init(vehicle: Vehicle) {
        self.vehicleId = vehicle.id
        self.vehicleName = vehicle.name
        self.selectedYear = vehicle.year
        self.selectedType = vehicle.type.rawValue
        self.selectedEngineType = vehicle.engineType.rawValue
        self.hasBlockHeater = vehicle.hasBlockHeater
        self.isPluggedIn = vehicle.isPluggedIn
        self.isPrimary = vehicle.isPrimary
        self.brand = vehicle.brand ?? ""
        self.vin = vehicle.vin ?? ""
        self.apiToken = vehicle.apiToken ?? ""
    }
    
    // MARK: - Public Methods
    
    func saveVehicle() async {
        let updatedVehicle = Vehicle(
            id: vehicleId,
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
        
        await vehicleService.updateVehicle(updatedVehicle)
        
        if isPrimary {
            await vehicleService.setPrimaryVehicle(updatedVehicle)
        }
    }
    
    func deleteVehicle() async {
        if let vehicle = await vehicleService.vehicles.first(where: { $0.id == vehicleId }) {
            await vehicleService.deleteVehicle(vehicle)
        }
    }
    
    func decodeVIN() async {
        guard !vin.isEmpty else { return }
        
        isDecoding = true
        vinDecodingResult = nil
        
        do {
            let result = try await vinDecoder.decode(vin: vin)
            vinDecodingResult = formatVINResult(result)
        } catch {
            vinDecodingResult = "Error decoding VIN: \(error.localizedDescription)"
        }
        
        isDecoding = false
    }
    
    // MARK: - Private Methods
    
    private func formatVINResult(_ result: VINDecoder.VINResult) -> String {
        var components: [String] = []
        
        if let make = result.make {
            components.append("Make: \(make)")
        }
        
        if let model = result.model {
            components.append("Model: \(model)")
        }
        
        if let year = result.year {
            components.append("Year: \(year)")
        }
        
        if let plant = result.plantCountry {
            components.append("Plant: \(plant)")
        }
        
        return components.joined(separator: "\n")
    }
}
