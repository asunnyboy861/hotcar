//
//  StartWarmUpIntent.swift
//  hotcar
//
//  HotCar Siri Intent - Start Warm-Up Timer
//  Allows users to start warm-up timer via Siri
//

import AppIntents
import Foundation

@available(iOS 16.0, *)
struct StartWarmUpIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Start Warm-Up Timer"
    static var description = IntentDescription(
        "Start the vehicle warm-up timer based on current temperature"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Vehicle", description: "The vehicle to warm up")
    var vehicle: VehicleEntity?
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Get vehicle
        guard let vehicleEntity = vehicle else {
            // Use primary vehicle if no vehicle specified
            let vehicles = VehicleService.shared.vehicles
            guard let primaryVehicle = vehicles.first(where: { $0.isPrimary }) ?? vehicles.first else {
                throw IntentError.noVehicle
            }
            
            return try await startWarmUp(for: primaryVehicle)
        }
        
        // Load vehicle from entity
        let vehicles = VehicleService.shared.vehicles
        guard let vehicle = vehicles.first(where: { $0.id == vehicleEntity.id }) else {
            throw IntentError.vehicleNotFound
        }
        
        return try await startWarmUp(for: vehicle)
    }
    
    @MainActor
    private func startWarmUp(for vehicle: Vehicle) async throws -> some IntentResult {
        // Get current temperature
        let weatherService = WeatherService.shared
        await weatherService.fetchCurrentTemperature()
        
        guard let temperature = weatherService.currentTemperature else {
            throw IntentError.temperatureUnavailable
        }
        
        // Convert temperature to Celsius for calculation
        let settings = SettingsService.shared.settings
        let tempCelsius = settings.temperatureUnit.convertToCelsius(temperature)
        
        // Calculate warm-up time
        let warmUpTime = WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: tempCelsius,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
        
        // Start timer
        let timer = CountdownTimer()
        timer.start(
            minutes: warmUpTime,
            vehicleName: vehicle.name,
            vehicleId: vehicle.id,
            temperature: tempCelsius
        )
        
        // Start Live Activity
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.startActivity(
                vehicleId: vehicle.id,
                vehicleName: vehicle.name,
                duration: warmUpTime * 60,
                temperature: tempCelsius
            )
        }
        
        // Format response
        let tempDisplay = settings.temperatureUnit.format(tempCelsius)
        
        return .result(
            dialog: IntentDialog("Started warm-up timer for \(vehicle.name). Current temperature is \(tempDisplay). Recommended warm-up time is \(warmUpTime) minutes.")
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start warm-up for \(\.$vehicle)") {
            \.$vehicle
        }
    }
}

// MARK: - Intent Errors

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case noVehicle
    case vehicleNotFound
    case temperatureUnavailable
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noVehicle:
            return "No vehicles found. Please add a vehicle in the HotCar app first."
        case .vehicleNotFound:
            return "Vehicle not found."
        case .temperatureUnavailable:
            return "Unable to get current temperature. Please check your internet connection."
        }
    }
}
