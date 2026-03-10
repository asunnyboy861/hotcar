//
//  CountdownTimer.swift
//  hotcar
//
//  HotCar Timer - Countdown Timer with Progress
//

import Foundation
import Combine

final class CountdownTimer: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var timeRemaining: Int // in seconds
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var totalTime: Int = 0
    
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
    
    // MARK: - Dependencies
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let hapticService = HapticFeedbackService.shared
    private let notificationService = NotificationService.shared
    private var vehicleName: String = "Vehicle"
    
    // MARK: - Initialization
    
    init(totalMinutes: Int = 0) {
        self.totalTime = totalMinutes * 60
        self.timeRemaining = totalMinutes * 60
    }
    
    // MARK: - Public Methods
    
    func start(minutes: Int, vehicleName: String = "Vehicle") {
        stop()
        
        self.vehicleName = vehicleName
        totalTime = minutes * 60
        timeRemaining = totalTime
        isRunning = true
        isPaused = false
        
        // Haptic feedback on start
        hapticService.timerStart()
        
        // Schedule notification
        Task {
            await notificationService.scheduleTimerCompleteNotification(
                minutes: minutes,
                vehicleName: vehicleName
            )
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        timer?.invalidate()
    }
    
    func resume() {
        guard isPaused else { return }
        
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset(minutes: Int) {
        stop()
        totalTime = minutes * 60
        timeRemaining = totalTime
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        guard timeRemaining > 0 else {
            complete()
            return
        }
        
        timeRemaining -= 1
        
        // Haptic feedback every minute
        if timeRemaining > 0 && timeRemaining % 60 == 0 {
            hapticService.timerTick()
        }
    }
    
    private func complete() {
        stop()
        
        // Strong haptic feedback
        hapticService.timerComplete()
        
        // Notification already scheduled, but trigger immediate feedback
        hapticService.notification(.success)
    }
}

// MARK: - Haptic Feedback

extension CountdownTimer {
    
    func triggerHapticFeedback() {
        // TODO: Implement with CoreHaptics
        print("Haptic feedback triggered")
    }
}
