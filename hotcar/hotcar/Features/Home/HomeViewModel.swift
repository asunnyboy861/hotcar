//
//  HomeViewModel.swift
//  hotcar
//
//  HotCar Home Screen ViewModel (Refactored)
//  Manages state and business logic for home screen
//  Optimized for US/Canada/Nordic markets
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTemperature: Double?
    @Published var tomorrowTemperature: Double?
    @Published var locationName: String = NSLocalizedString("loading", tableName: "Localizable", comment: "Loading state text shown while fetching location")
    @Published var isLoading: Bool = false
    
    @Published var isTimerActive: Bool = false
    @Published var isTimerPaused: Bool = false
    @Published var timeRemaining: Int = 0
    @Published var timerProgress: Double = 0.0
    
    // MARK: - Dependencies (Using @Published for reactive updates)
    
    @Published var settingsService = SettingsService.shared
    @Published var vehicleService = VehicleService.shared
    @Published var statisticsService = StatisticsService.shared
    
    private let weatherService = WeatherService.shared
    private let countdownTimer = CountdownTimer.shared
    private let widgetService = WidgetDataService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// Temperature unit from settings
    var temperatureUnit: AppSettings.TemperatureUnit {
        settingsService.settings.temperatureUnit
    }
    
    /// Primary vehicle from vehicle service
    var primaryVehicle: Vehicle? {
        vehicleService.getPrimaryVehicle()
    }
    
    /// All vehicles from vehicle service
    var vehicles: [Vehicle] {
        vehicleService.vehicles
    }
    
    /// Temperature status based on current temperature
    var temperatureStatus: TemperatureStatus? {
        guard let temp = currentTemperature else { return nil }
        return TemperatureStatus.from(celsius: temp)
    }
    
    /// Calculated warm-up time for current conditions
    var calculatedWarmUpTime: Int {
        guard let temperature = currentTemperature,
              let vehicle = primaryVehicle else {
            return settingsService.settings.defaultTimerDuration
        }
        
        return WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: temperature,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
    }
    
    /// Calculated warm-up time for tomorrow's forecast
    var calculatedWarmUpTimeForTomorrow: Int {
        guard let temperature = tomorrowTemperature,
              let vehicle = primaryVehicle else {
            return settingsService.settings.defaultTimerDuration
        }
        
        return WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: temperature,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
    }
    
    /// Current statistics
    var statistics: WarmUpStatistics {
        statisticsService.statistics
    }
    
    /// Check if user is new (no sessions)
    var isNewUser: Bool {
        statistics.totalSessions == 0
    }
    
    /// Warm-up advice based on current conditions
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
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Timer bindings
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
    
    // MARK: - Data Loading
    
    func loadInitialData() {
        Task {
            await vehicleService.loadVehicles()
            await loadWeather()
        }
    }
    
    func loadWeather() async {
        isLoading = true
        
        await weatherService.fetchCurrentTemperature()
        await weatherService.fetchTomorrowMorningTemperature()
        
        self.currentTemperature = weatherService.currentTemperature
        self.tomorrowTemperature = weatherService.tomorrowMorningTemp
        self.locationName = locationService.locationName
        
        isLoading = false
        
        updateWidgetWeatherData()
    }
    
    private func updateWidgetWeatherData() {
        guard let temp = currentTemperature else { return }
        
        widgetService.updateWeatherData(
            outsideTemp: temp,
            feelsLike: weatherService.currentTemperature ?? temp,
            condition: "Clear",
            location: locationName
        )
        
        widgetService.updateRecommendedTime(calculatedWarmUpTime)
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
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
    }
    
    func stopTimer() {
        countdownTimer.stop()
    }
    
    func toggleTimer() {
        if isTimerActive {
            stopTimer()
        } else {
            startTimer()
        }
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
    
    // MARK: - Vehicle Control
    
    func setPrimaryVehicle(_ vehicle: Vehicle) {
        Task {
            await vehicleService.setPrimaryVehicle(vehicle)
        }
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        await loadWeather()
    }
}
