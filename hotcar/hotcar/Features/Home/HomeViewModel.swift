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
    @Published var locationName: String = "Loading..."
    @Published var isLoading: Bool = false
    @Published var primaryVehicle: Vehicle?
    @Published var isTimerActive: Bool = false
    @Published var fuelSaved: Double = 0.0
    @Published var fuelUsed: Double = 0.0
    
    @Published var timeRemaining: Int = 0
    @Published var timerProgress: Double = 0.0
    @Published var isTimerPaused: Bool = false
    
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
    private let locationService = LocationService.shared
    private let countdownTimer = CountdownTimer.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadVehicle()
        setupTimerBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        vehicleService.$vehicles
            .receive(on: RunLoop.main)
            .sink { [weak self] vehicles in
                self?.primaryVehicle = vehicles.first { $0.isPrimary } ?? vehicles.first
            }
            .store(in: &cancellables)
    }
    
    private func setupTimerBindings() {
        countdownTimer.$timeRemaining
            .receive(on: RunLoop.main)
            .sink { [weak self] time in
                self?.timeRemaining = time
                self?.timerProgress = self?.countdownTimer.progress ?? 0
            }
            .store(in: &cancellables)
        
        countdownTimer.$isPaused
            .receive(on: RunLoop.main)
            .sink { [weak self] isPaused in
                self?.isTimerPaused = isPaused
            }
            .store(in: &cancellables)
        
        countdownTimer.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] isRunning in
                self?.isTimerActive = isRunning
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadWeather() {
        isLoading = true
        
        Task {
            await weatherService.fetchCurrentTemperature()
            await weatherService.fetchTomorrowMorningTemperature()
            
            // Update UI with weather data
            self.currentTemperature = weatherService.currentTemperature
            self.tomorrowTemperature = weatherService.tomorrowMorningTemp
            
            // Update location name from LocationService
            self.locationName = locationService.locationName
            
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
        if isTimerActive {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        guard let vehicle = primaryVehicle,
              let temperature = currentTemperature else {
            return
        }
        
        let minutes = calculatedWarmUpTime
        
        countdownTimer.start(
            minutes: minutes,
            vehicleName: vehicle.name,
            vehicleId: vehicle.id,
            temperature: temperature
        )
        
        updateFuelStats()
    }
    
    private func stopTimer() {
        countdownTimer.stop()
    }
    
    func pauseTimer() {
        countdownTimer.pause()
    }
    
    func resumeTimer() {
        countdownTimer.resume()
    }
    
    func adjustTimerTime(by minutes: Int) {
        let newMinutes = max(1, calculatedWarmUpTime + minutes)
        countdownTimer.reset(minutes: newMinutes)
    }
    
    private func updateFuelStats() {
        let stats = StatisticsService.shared.statistics
        fuelSaved = stats.totalFuelSaved
        fuelUsed = stats.totalFuelUsed
    }
}
