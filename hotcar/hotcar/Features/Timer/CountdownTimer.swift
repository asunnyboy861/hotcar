//
//  CountdownTimer.swift
//  hotcar
//
//  HotCar Timer - Countdown Timer with Progress
//  Enhanced with state management, persistence, and Live Activity
//

import Foundation
import Combine

@MainActor
final class CountdownTimer: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = CountdownTimer()
    
    // MARK: - Published Properties
    
    @Published var timeRemaining: Int
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var totalTime: Int = 0
    @Published var state: TimerState = .idle
    
    // MARK: - Computed Properties
    
    var minutes: Int {
        timeRemaining / 60
    }
    
    var seconds: Int {
        timeRemaining % 60
    }
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    var isComplete: Bool {
        timeRemaining <= 0 && !isRunning
    }
    
    var displayData: TimerDisplayData {
        TimerDisplayData(
            minutes: minutes,
            seconds: seconds,
            progress: progress,
            state: state
        )
    }
    
    // MARK: - Dependencies
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let hapticService = HapticFeedbackService.shared
    private let notificationService = NotificationService.shared
    private let widgetService = WidgetDataService.shared
    private let statisticsService = StatisticsService.shared
    
    // Session tracking
    private var currentSessionStartTime: Date?
    private var currentVehicleId: String?
    private var vehicleName: String = "Vehicle"
    private var currentTemperature: Double = 0
    
    // MARK: - Initialization
    
    private init(totalMinutes: Int = 0) {
        self.totalTime = totalMinutes * 60
        self.timeRemaining = totalMinutes * 60
        loadPersistedState()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func start(minutes: Int, vehicleName: String = "Vehicle", vehicleId: String = "", temperature: Double = 0) {
        stop()
        
        self.vehicleName = vehicleName
        self.currentVehicleId = vehicleId.isEmpty ? nil : vehicleId
        self.currentTemperature = temperature
        totalTime = minutes * 60
        timeRemaining = totalTime
        isRunning = true
        isPaused = false
        state = .running(startTime: Date(), duration: TimeInterval(totalTime))
        
        currentSessionStartTime = Date()
        
        hapticService.timerStart()
        
        Task {
            await notificationService.scheduleTimerCompleteNotification(
                minutes: minutes,
                vehicleName: vehicleName
            )
        }
        
        widgetService.updateTimerState(
            isRunning: true,
            remaining: timeRemaining,
            vehicleName: vehicleName
        )
        
        if #available(iOS 16.1, *) {
            startLiveActivity(
                vehicleId: vehicleId.isEmpty ? UUID().uuidString : vehicleId,
                vehicleName: vehicleName,
                temperature: temperature
            )
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        persistState()
    }
    
    func pause() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        state = .paused(remaining: TimeInterval(timeRemaining))
        timer?.invalidate()
        
        hapticService.timerTick()
        
        // Update widget
        widgetService.updateTimerState(
            isRunning: false,
            remaining: timeRemaining,
            vehicleName: vehicleName
        )
        
        persistState()
    }
    
    func resume() {
        guard isPaused else { return }
        
        isPaused = false
        state = .running(startTime: Date(), duration: TimeInterval(timeRemaining))
        
        hapticService.timerStart()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        // Update widget
        widgetService.updateTimerState(
            isRunning: true,
            remaining: timeRemaining,
            vehicleName: vehicleName
        )
        
        persistState()
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        state = .idle
        timer?.invalidate()
        timer = nil
        
        Task {
            await notificationService.cancelAllTimerNotifications()
        }
        
        widgetService.updateTimerState(
            isRunning: false,
            remaining: 0,
            vehicleName: ""
        )
        
        if #available(iOS 16.1, *) {
            endLiveActivity()
        }
        
        currentSessionStartTime = nil
        currentVehicleId = nil
        
        clearPersistedState()
    }
    
    func reset(minutes: Int) {
        stop()
        totalTime = minutes * 60
        timeRemaining = totalTime
        state = .idle
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        guard timeRemaining > 0 else {
            complete()
            return
        }
        
        timeRemaining -= 1
        
        if timeRemaining % 10 == 0 {
            widgetService.updateTimerState(
                isRunning: true,
                remaining: timeRemaining,
                vehicleName: vehicleName
            )
        }
        
        if timeRemaining > 0 && timeRemaining % 60 == 0 {
            hapticService.timerTick()
        }
        
        if timeRemaining % 30 == 0 {
            persistState()
        }
        
        if #available(iOS 16.1, *) {
            updateLiveActivity()
        }
    }
    
    private func complete() {
        stop()
        state = .completed
        
        // Create and save session
        if let startTime = currentSessionStartTime,
           let vehicleId = currentVehicleId {
            
            let session = WarmUpSession(
                id: UUID().uuidString,
                vehicleId: vehicleId,
                vehicleName: vehicleName,
                startTime: startTime,
                endTime: Date(),
                durationMinutes: totalTime / 60,
                outsideTemperature: currentTemperature,
                targetTemperature: nil,
                vehicleType: "sedan",
                engineType: "gas",
                completed: true,
                notes: nil
            )
            
            Task {
                await statisticsService.addSession(session)
            }
        }
        
        // Strong haptic feedback
        hapticService.timerComplete()
        
        // Sound feedback
        SoundFeedbackService.shared.onTimerComplete()
    }
    
    // MARK: - State Persistence
    
    private let stateKey = "com.hotcar.timer.state"
    
    private func persistState() {
        let stateData = TimerPersistedState(
            state: state,
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            vehicleId: currentVehicleId,
            vehicleName: vehicleName,
            temperature: currentTemperature,
            startTime: currentSessionStartTime
        )
        
        if let data = try? JSONEncoder().encode(stateData) {
            UserDefaults.standard.set(data, forKey: stateKey)
        }
    }
    
    private func loadPersistedState() {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let stateData = try? JSONDecoder().decode(TimerPersistedState.self, from: data) else {
            return
        }
        
        // Only restore if timer was running and hasn't expired
        if case .running(let startTime, _) = stateData.state {
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = stateData.totalTime - Int(elapsed)
            
            if remaining > 0 {
                // Restore timer
                timeRemaining = remaining
                totalTime = stateData.totalTime
                state = .running(startTime: startTime, duration: TimeInterval(stateData.totalTime))
                currentVehicleId = stateData.vehicleId
                vehicleName = stateData.vehicleName ?? "Vehicle"
                currentTemperature = stateData.temperature ?? 0
                currentSessionStartTime = stateData.startTime
                
                // Resume timer
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    self?.tick()
                }
            } else {
                // Timer expired while app was closed
                complete()
            }
        }
    }
    
    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: stateKey)
    }
}

// MARK: - Haptic Feedback

extension CountdownTimer {
    
    func triggerHapticFeedback() {
        hapticService.timerTick()
    }
}

// MARK: - Live Activity Support

extension CountdownTimer {
    
    @available(iOS 16.1, *)
    private var liveActivityManager: LiveActivityManager {
        LiveActivityManager.shared
    }
    
    func startLiveActivity(vehicleId: String, vehicleName: String, temperature: Double) {
        if #available(iOS 16.1, *) {
            liveActivityManager.startActivity(
                vehicleId: vehicleId,
                vehicleName: vehicleName,
                duration: totalTime,
                temperature: temperature
            )
        }
    }
    
    func updateLiveActivity() {
        if #available(iOS 16.1, *) {
            liveActivityManager.updateActivity(
                remainingTime: timeRemaining,
                isPaused: state.isPaused
            )
        }
    }
    
    func endLiveActivity() {
        if #available(iOS 16.1, *) {
            liveActivityManager.endActivity()
        }
    }
    
    func endLiveActivityWithCompletion() {
        if #available(iOS 16.1, *) {
            liveActivityManager.endActivityWithCompletion()
        }
    }
}
