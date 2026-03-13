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
    
    // MARK: - User Adjustment State
    
    /// User manual time adjustment in minutes (can be negative)
    @Published var userTimeAdjustment: Int = 0
    
    // MARK: - Error Handling
    
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    // MARK: - Tesla API Integration (Hybrid Timer Mode)
    
    /// Vehicle connection state for Tesla API
    @Published var vehicleConnectionState: VehicleConnectionState = .disconnected
    
    /// Timer mode: local countdown or remote climate control
    @Published var timerMode: TimerMode = .local
    
    /// Whether climate control is currently active (remote mode)
    @Published var isClimateOn: Bool = false
    
    /// Inside temperature from vehicle (remote mode)
    @Published var insideTemperature: Double?
    
    /// Outside temperature from vehicle (remote mode)
    @Published var outsideTemperature: Double?
    
    /// Whether climate monitoring is active
    private var isMonitoringClimate = false
    
    /// Tesla API service (reuse existing singleton)
    private let teslaService = TeslaAPIService.shared
    
    /// Ford API service
    private let fordService = FordAPIService.shared
    
    /// GM API service
    private let gmService = GMAPIService.shared
    
    /// Toyota API service
    private let toyotaService = ToyotaAPIService.shared
    
    /// Vehicle API Factory for multi-brand support
    private let apiFactory = VehicleAPIFactory.shared
    
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
    
    /// Final recommended time including user adjustment
    var finalRecommendedTime: Int {
        let baseTime = calculatedWarmUpTime
        return max(1, baseTime + userTimeAdjustment)
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
        
        // Reset adjustment when vehicle list changes (including primary change)
        vehicleService.$vehicles
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.resetTimeAdjustment()
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
        
        widgetService.updateRecommendedTime(finalRecommendedTime)
    }
    
    // MARK: - Timer Control
    // Note: startTimer, stopTimer, and adjustTimerTime moved to Tesla API Integration extension
    
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
    
    /// Reset user time adjustment to 0
    /// Also updates widget to reflect the reset
    func resetTimeAdjustment() {
        userTimeAdjustment = 0
        widgetService.updateRecommendedTime(finalRecommendedTime)
    }
    
    // MARK: - Vehicle Control
    
    /// Set primary vehicle and reset time adjustment
    /// Note: Adjustment is reset because different vehicles have different warm-up requirements
    func setPrimaryVehicle(_ vehicle: Vehicle) {
        Task {
            await vehicleService.setPrimaryVehicle(vehicle)
            // Reset adjustment when vehicle changes (different vehicles need different times)
            resetTimeAdjustment()
        }
    }
    
    // MARK: - Error Handling
    
    func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    func clearError() {
        errorMessage = nil
        showErrorAlert = false
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        await loadWeather()
    }
}

// MARK: - Tesla API Integration (Hybrid Timer Mode)

extension HomeViewModel {
    
    // MARK: - Vehicle Connection State
    
    enum VehicleConnectionState: Equatable {
        case disconnected      // No API connection
        case connecting        // Connecting to vehicle
        case connected         // Connected and controlling
        case error(String)     // Connection error
        
        var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }
    }
    
    // MARK: - Timer Mode
    
    enum TimerMode {
        case local           // Pure countdown timer (no API)
        case remote          // Remote climate control via API
    }
    
    // MARK: - Enhanced Timer Control
    
    /// Start timer with automatic mode detection
    @MainActor
    func startTimer() {
        guard let vehicle = primaryVehicle else {
            showError("Please select a vehicle first")
            return
        }
        
        // Check if vehicle has API connection
        if vehicleService.hasAPIConnection(vehicle) {
            // Remote mode: Start climate control via appropriate API
            Task {
                await startRemoteClimate()
            }
        } else {
            // Local mode: Pure countdown timer
            startLocalTimer()
        }
    }
    
    /// Start remote climate control with multi-brand support
    @MainActor
    private func startRemoteClimate() async {
        guard let vehicle = primaryVehicle else {
            showError("No vehicle selected")
            return
        }
        
        vehicleConnectionState = .connecting
        
        let connectionType = vehicleService.getAPIConnectionType(vehicle)
        
        do {
            // 1. Start climate control based on vehicle brand
            try await startClimateForBrand(connectionType, maxRetries: 3)
            
            // 2. Update UI state
            isClimateOn = true
            isTimerActive = true
            timerMode = .remote
            vehicleConnectionState = .connected
            
            // 3. Start countdown timer
            countdownTimer.start(minutes: finalRecommendedTime)
            
            // 4. Start climate monitoring
            startClimateMonitoring()
            
            // 5. Update widget
            widgetService.updateClimateState(isOn: true, insideTemp: nil)
            
            // 6. Play sound feedback
            SoundFeedbackService.shared.onTimerStart()
            
        } catch {
            // Handle error based on brand
            let errorMessage = getErrorMessage(for: connectionType, error: error)
            vehicleConnectionState = .error(errorMessage)
            showError("\(errorMessage). Starting local timer instead.")
            startLocalTimer()
        }
    }
    
    /// Start climate control for specific brand
    private func startClimateForBrand(_ brand: APIConnectionType, maxRetries: Int) async throws {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                switch brand {
                case .tesla:
                    try await teslaService.startClimate()
                case .ford:
                    try await fordService.startClimate()
                case .gm:
                    try await gmService.startClimate()
                case .toyota:
                    try await toyotaService.startClimate()
                case .unknown:
                    throw VehicleAPIError.unsupportedBrand
                }
                return // Success
            } catch {
                lastError = error
                // Exponential backoff: wait 1s, 2s, 4s...
                let delay = UInt64(pow(2.0, Double(attempt - 1))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
        }
        
        throw lastError ?? VehicleAPIError.networkError
    }
    
    /// Get error message for specific brand
    private func getErrorMessage(for brand: APIConnectionType, error: Error) -> String {
        let brandName = getBrandDisplayName(for: brand)
        
        if let apiError = error as? VehicleAPIError {
            switch apiError {
            case .networkError:
                return "Network error"
            case .notAuthenticated, .tokenExpired:
                return "\(brandName) authentication expired"
            case .commandFailed:
                return "Failed to start \(brandName) climate control"
            case .unsupportedBrand:
                return "This vehicle brand is not supported"
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
    
    /// Get display name for API connection type
    private func getBrandDisplayName(for brand: APIConnectionType) -> String {
        switch brand {
        case .tesla: return "Tesla"
        case .ford: return "Ford"
        case .gm: return "GM"
        case .toyota: return "Toyota"
        case .unknown: return "Unknown"
        }
    }
    
    /// Start local countdown timer (no API connection)
    /// Reuses existing timer logic as fallback
    @MainActor
    private func startLocalTimer() {
        timerMode = .local
        isTimerActive = true
        
        // Use current temperature or default (0°C) - don't block on weather failure
        let temperature = currentTemperature ?? 0
        let minutes = finalRecommendedTime
        
        countdownTimer.start(
            minutes: minutes,
            vehicleName: primaryVehicle?.name ?? "Vehicle",
            vehicleId: primaryVehicle?.id ?? "unknown",
            temperature: temperature
        )
        
        // Show notification for manual start
        showNotification(
            title: "Start Your Vehicle",
            body: "Please manually start your vehicle's engine or block heater"
        )
    }
    
    /// Start monitoring climate state with periodic polling
    @MainActor
    private func startClimateMonitoring() {
        guard !isMonitoringClimate else { return }
        isMonitoringClimate = true
        
        Task {
            while isClimateOn && timerMode == .remote {
                // Poll every 30 seconds
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                await refreshClimateState()
            }
            isMonitoringClimate = false
        }
    }
    
    /// Refresh climate state from vehicle API
    /// - Note: Converts temperature to user's preferred unit (°C/°F)
    @MainActor
    private func refreshClimateState() async {
        guard let vehicle = primaryVehicle else { return }
        
        let connectionType = vehicleService.getAPIConnectionType(vehicle)
        
        do {
            let climateState = try await getClimateStateForBrand(connectionType)
            
            await MainActor.run {
                isClimateOn = climateState.isClimateOn
                
                // Convert temperature to user's preferred unit
                let tempUnit = settingsService.settings.temperatureUnit
                insideTemperature = tempUnit.convert(from: climateState.insideTemp ?? 0)
                outsideTemperature = tempUnit.convert(from: climateState.outsideTemp ?? 0)
                
                // Auto-stop timer if climate is off
                if !climateState.isClimateOn && isTimerActive {
                    stopTimer()
                }
            }
        } catch {
            // Keep last known state on network error
            print("Failed to refresh climate state: \(error)")
        }
    }
    
    /// Get climate state for specific brand
    private func getClimateStateForBrand(_ brand: APIConnectionType) async throws -> ClimateState {
        switch brand {
        case .tesla:
            let teslaState = try await teslaService.getClimateState()
            return ClimateState(
                isClimateOn: teslaState.isClimateOn,
                insideTemp: teslaState.insideTemp,
                outsideTemp: teslaState.outsideTemp
            )
        case .ford:
            let fordState = try await fordService.getClimateState()
            return ClimateState(
                isClimateOn: fordState.isClimateOn,
                insideTemp: fordState.insideTemp,
                outsideTemp: fordState.outsideTemp
            )
        case .gm:
            let gmState = try await gmService.getClimateState()
            return ClimateState(
                isClimateOn: gmState.isClimateOn,
                insideTemp: gmState.insideTemp,
                outsideTemp: gmState.outsideTemp
            )
        case .toyota:
            let toyotaState = try await toyotaService.getClimateState()
            return ClimateState(
                isClimateOn: toyotaState.isClimateOn,
                insideTemp: toyotaState.insideTemp,
                outsideTemp: toyotaState.outsideTemp
            )
        case .unknown:
            throw VehicleAPIError.unsupportedBrand
        }
    }
    
    /// Stop timer and climate control
    @MainActor
    func stopTimer() {
        // Stop climate control if in remote mode
        if timerMode == .remote && isClimateOn {
            Task {
                guard let vehicle = primaryVehicle else { return }
                let connectionType = vehicleService.getAPIConnectionType(vehicle)
                
                do {
                    switch connectionType {
                    case .tesla:
                        try await teslaService.stopClimate()
                    case .ford:
                        try await fordService.stopClimate()
                    case .gm:
                        try await gmService.stopClimate()
                    case .toyota:
                        try await toyotaService.stopClimate()
                    case .unknown:
                        break
                    }
                } catch {
                    print("Failed to stop climate: \(error)")
                }
            }
        }
        
        // Play sound feedback
        SoundFeedbackService.shared.onTimerStop()
        
        // Stop countdown timer
        countdownTimer.stop()
        
        // Reset state
        isTimerActive = false
        isClimateOn = false
        isMonitoringClimate = false
        
        // Update widget
        widgetService.updateClimateState(isOn: false, insideTemp: nil)
    }
    
    /// Adjust timer time by adding/subtracting minutes
    /// Note: In remote mode, this only adjusts the local countdown, not the actual climate control
    func adjustTimerTime(by minutes: Int) {
        userTimeAdjustment += minutes
        
        // Ensure final time is at least 1 minute
        if finalRecommendedTime < 1 {
            userTimeAdjustment = 1 - calculatedWarmUpTime
        }
        
        // Update countdown timer if active
        if isTimerActive {
            let newMinutes = max(1, timeRemaining / 60 + minutes)
            countdownTimer.reset(minutes: newMinutes)
        }
        
        // Update widget with new recommended time
        widgetService.updateRecommendedTime(finalRecommendedTime)
    }
    
    /// Helper: Show notification
    private func showNotification(title: String, body: String) {
        // TODO: Implement notification system
        print("Notification: \(title) - \(body)")
    }
}
