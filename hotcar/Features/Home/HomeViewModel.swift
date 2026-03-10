//
//  HomeViewModel.swift
//  hotcar
//
//  HotCar Home Screen ViewModel
//  Manages state and business logic for home screen
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTemperature: Double?
    @Published var tomorrowTemperature: Double?
    @Published var locationName: String = "Toronto, ON"
    @Published var isLoading: Bool = false
    @Published var primaryVehicle: Vehicle?
    @Published var isTimerActive: Bool = false
    @Published var fuelSaved: Double = 0.0
    @Published var fuelUsed: Double = 0.0
    
    // MARK: - Computed Properties
    
    var calculatedWarmUpTime: Int {
        guard let temperature = currentTemperature,
              let vehicle = primaryVehicle else {
            return 5 // Default
        }
        
        return WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: temperature,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
    }
    
    var calculatedWarmUpTimeForTomorrow: Int {
        guard let temperature = tomorrowTemperature,
              let vehicle = primaryVehicle else {
            return 5 // Default
        }
        
        return WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: temperature,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
    }
    
    var warmUpAdvice: String? {
        guard let temperature = currentTemperature,
              let vehicle = primaryVehicle else {
            return nil
        }
        
        let warmUpTime = calculatedWarmUpTime
        
        return WarmUpCalculationEngine.getWarmUpAdvice(
            temperature: temperature,
            warmUpTime: warmUpTime,
            engineType: vehicle.engineType
        )
    }
    
    // MARK: - Dependencies
    
    private let weatherService = WeatherService.shared
    private let vehicleService = VehicleService.shared
    private let widgetService = WidgetDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadVehicle()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Listen for vehicle changes
        vehicleService.$vehicles
            .receive(on: RunLoop.main)
            .sink { [weak self] vehicles in
                self?.primaryVehicle = vehicles.first { $0.isPrimary } ?? vehicles.first
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadWeather() {
        isLoading = true
        
        Task {
            await weatherService.fetchCurrentTemperature()
            await weatherService.fetchTomorrowMorningTemperature()
            
            // Update UI
            self.currentTemperature = weatherService.currentTemperature
            self.tomorrowTemperature = weatherService.tomorrowMorningTemp
            self.isLoading = false
            
            // Update widget weather data
            updateWidgetWeatherData()
        }
    }
    
    private func updateWidgetWeatherData() {
        guard let temp = currentTemperature else { return }
        
        widgetService.updateWeatherData(
            outsideTemp: temp,
            feelsLike: weatherService.currentTemperature ?? temp,
            condition: "Clear", // TODO: Get from weather service
            location: locationName
        )
        
        // Update recommended time
        widgetService.updateRecommendedTime(calculatedWarmUpTime)
    }
    
    func loadVehicle() {
        Task {
            await vehicleService.loadVehicles()
        }
    }
    
    func toggleTimer() {
        isTimerActive.toggle()
        
        if isTimerActive {
            // Start timer logic
            startTimer()
        } else {
            // Stop timer logic
            stopTimer()
        }
    }
    
    // MARK: - Timer Logic
    
    private func startTimer() {
        // TODO: Implement actual timer with countdown
        print("Starting timer for \(calculatedWarmUpTime) minutes")
    }
    
    private func stopTimer() {
        // TODO: Implement timer stop
        print("Stopping timer")
    }
}
