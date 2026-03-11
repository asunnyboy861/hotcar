//
//  WarmUpCalculatorViewModel.swift
//  hotcar
//
//  HotCar Feature - Warm-Up Calculator ViewModel
//

import Foundation
import Combine

@MainActor
final class WarmUpCalculatorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTemperature: Double?
    @Published var locationName: String = "Current Location"
    @Published var selectedVehicle: Vehicle?
    @Published var isTimerRunning: Bool = false
    @Published var timeRemainingMinutes: Int = 0
    @Published var timeRemainingSeconds: Int = 0
    @Published var warmUpAdvice: String?
    
    // MARK: - Computed Properties
    
    var calculatedMinutes: Int {
        guard let temperature = currentTemperature,
              let vehicle = selectedVehicle else {
            return 5
        }
        
        return WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: temperature,
            vehicleType: vehicle.type,
            engineType: vehicle.engineType,
            hasBlockHeater: vehicle.hasBlockHeater,
            isPluggedIn: vehicle.isPluggedIn
        )
    }
    
    var calculatedSeconds: Int {
        return 0
    }
    
    var progress: Double {
        guard let vehicle = selectedVehicle else { return 0 }
        
        let totalSeconds = calculatedMinutes * 60
        let remainingSeconds = timeRemainingMinutes * 60 + timeRemainingSeconds
        
        if totalSeconds == 0 { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
    
    // MARK: - Dependencies
    
    private let weatherService = WeatherService.shared
    private let vehicleService = VehicleService.shared
    private let locationService = LocationService.shared
    private let countdownTimer = CountdownTimer()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Listen to countdown timer
        countdownTimer.$timeRemaining
            .receive(on: RunLoop.main)
            .sink { [weak self] time in
                self?.timeRemainingMinutes = time / 60
                self?.timeRemainingSeconds = time % 60
            }
            .store(in: &cancellables)
        
        countdownTimer.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] isRunning in
                self?.isTimerRunning = isRunning
            }
            .store(in: &cancellables)
        
        // Listen for vehicle changes
        vehicleService.$vehicles
            .receive(on: RunLoop.main)
            .sink { [weak self] vehicles in
                self?.selectedVehicle = vehicles.first { $0.isPrimary } ?? vehicles.first
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        Task {
            await weatherService.fetchCurrentTemperature()
            await vehicleService.loadVehicles()
            
            self.currentTemperature = weatherService.currentTemperature
            self.locationName = locationService.locationName
        }
    }
    
    func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        countdownTimer.start(minutes: calculatedMinutes)
        generateAdvice()
    }
    
    func stopTimer() {
        countdownTimer.stop()
    }
    
    func pauseTimer() {
        countdownTimer.pause()
    }
    
    func resumeTimer() {
        countdownTimer.resume()
    }
    
    func adjustTime(by minutes: Int) {
        // TODO: Implement manual time adjustment
    }
    
    // MARK: - Private Methods
    
    private func generateAdvice() {
        guard let temperature = currentTemperature,
              let vehicle = selectedVehicle else {
            warmUpAdvice = nil
            return
        }
        
        warmUpAdvice = WarmUpCalculationEngine.getWarmUpAdvice(
            temperature: temperature,
            warmUpTime: calculatedMinutes,
            engineType: vehicle.engineType
        )
    }
}
