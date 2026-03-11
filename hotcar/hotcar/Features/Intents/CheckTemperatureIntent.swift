//
//  CheckTemperatureIntent.swift
//  hotcar
//
//  HotCar Siri Intent - Check Temperature
//  Allows users to check temperature and get warm-up recommendation via Siri
//

import AppIntents
import Foundation

@available(iOS 16.0, *)
struct CheckTemperatureIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Check Temperature"
    static var description = IntentDescription(
        "Check current temperature and get warm-up recommendation"
    )
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Get current temperature
        let weatherService = WeatherService.shared
        await weatherService.fetchCurrentTemperature()
        
        guard let temperature = weatherService.currentTemperature else {
            throw IntentError.temperatureUnavailable
        }
        
        // Get primary vehicle
        let vehicles = VehicleService.shared.vehicles
        guard let vehicle = vehicles.first(where: { $0.isPrimary }) ?? vehicles.first else {
            throw IntentError.noVehicle
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
        
        // Format response
        let tempDisplay = settings.temperatureUnit.format(tempCelsius)
        let locationName = LocationService.shared.locationName
        
        return .result(
            dialog: IntentDialog("Current temperature in \(locationName) is \(tempDisplay). Recommended warm-up time for your \(vehicle.name) is \(warmUpTime) minutes.")
        )
    }
}

// MARK: - App Shortcuts Provider

@available(iOS 16.0, *)
struct HotCarShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWarmUpIntent(),
            phrases: [
                "Start warm-up with \(.applicationName)",
                "Warm up my car with \(.applicationName)",
                "Start engine warm-up with \(.applicationName)"
            ],
            shortTitle: "Start Warm-Up",
            systemImageName: "flame.fill"
        )
        
        AppShortcut(
            intent: CheckTemperatureIntent(),
            phrases: [
                "Check temperature with \(.applicationName)",
                "What's the temperature with \(.applicationName)",
                "Check weather with \(.applicationName)"
            ],
            shortTitle: "Check Temperature",
            systemImageName: "thermometer"
        )
    }
}
