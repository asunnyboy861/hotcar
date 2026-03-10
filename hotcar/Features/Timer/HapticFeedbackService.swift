//
//  HapticFeedbackService.swift
//  hotcar
//
//  HotCar Service - Haptic Feedback
//  Provides tactile feedback for user interactions
//

import Foundation
import CoreHaptics

final class HapticFeedbackService {
    
    // MARK: - Singleton
    
    static let shared = HapticFeedbackService()
    
    // MARK: - Properties
    
    private var engine: CHHapticEngine?
    private var isPrepared: Bool = false
    
    // MARK: - Initialization
    
    private init() {
        prepareHapticEngine()
    }
    
    // MARK: - Public Methods
    
    func prepareHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            engine?.isAutoShutdown = false
            
            try engine?.start()
            isPrepared = true
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    // MARK: - Timer Feedback
    
    /// Strong success feedback when timer completes
    func timerComplete() {
        guard isPrepared else { return }
        
        let pattern = createTimerCompletePattern()
        playPattern(pattern)
    }
    
    /// Subtle feedback when timer starts
    func timerStart() {
        guard isPrepared else { return }
        
        let pattern = createTimerStartPattern()
        playPattern(pattern)
    }
    
    /// Light feedback when timer stops
    func timerStop() {
        guard isPrepared else { return }
        
        let pattern = createTimerStopPattern()
        playPattern(pattern)
    }
    
    /// Feedback for timer tick (every minute)
    func timerTick() {
        guard isPrepared else { return }
        
        let pattern = createTimerTickPattern()
        playPattern(pattern)
    }
    
    // MARK: - Button Feedback
    
    /// Success feedback for button press
    func buttonSuccess() {
        guard isPrepared else { return }
        
        let pattern = createButtonSuccessPattern()
        playPattern(pattern)
    }
    
    /// Error feedback for invalid action
    func buttonError() {
        guard isPrepared else { return }
        
        let pattern = createButtonErrorPattern()
        playPattern(pattern)
    }
    
    // MARK: - Vehicle Feedback
    
    /// Feedback when vehicle is added
    func vehicleAdded() {
        guard isPrepared else { return }
        
        let pattern = createVehicleAddedPattern()
        playPattern(pattern)
    }
    
    /// Feedback when vehicle is deleted
    func vehicleDeleted() {
        guard isPrepared else { return }
        
        let pattern = createVehicleDeletedPattern()
        playPattern(pattern)
    }
    
    // MARK: - Maintenance Feedback
    
    /// Feedback for maintenance reminder
    func maintenanceReminder() {
        guard isPrepared else { return }
        
        let pattern = createMaintenanceReminderPattern()
        playPattern(pattern)
    }
    
    /// Feedback when maintenance is completed
    func maintenanceComplete() {
        guard isPrepared else { return }
        
        let pattern = createMaintenanceCompletePattern()
        playPattern(pattern)
    }
    
    // MARK: - Pattern Creation
    
    private func createTimerCompletePattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            // Strong impact
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 1.0),
                    .init(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            ),
            // Second impact
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.9),
                    .init(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.15
            ),
            // Third impact
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.8),
                    .init(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.3
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createTimerStartPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.7),
                    .init(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createTimerStopPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.5),
                    .init(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createTimerTickPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.3),
                    .init(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createButtonSuccessPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.6),
                    .init(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createButtonErrorPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.4),
                    .init(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0
            ),
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.4),
                    .init(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.1
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createVehicleAddedPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.7),
                    .init(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            ),
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.6),
                    .init(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.1
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createVehicleDeletedPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.3),
                    .init(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createMaintenanceReminderPattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.5),
                    .init(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0
            ),
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.5),
                    .init(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.15
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    private func createMaintenanceCompletePattern() -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.8),
                    .init(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0
            ),
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.7),
                    .init(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.1
            ),
            .init(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.6),
                    .init(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.2
            )
        ]
        
        return try! CHHapticPattern(events: events, parameters: [])
    }
    
    // MARK: - Pattern Playback
    
    private func playPattern(_ pattern: CHHapticPattern) {
        do {
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Error playing haptic pattern: \(error)")
        }
    }
    
    // MARK: - Cleanup
    
    func stopEngine() {
        engine?.stop()
        isPrepared = false
    }
}

// MARK: - UIImpactFeedbackGenerator Wrapper

extension HapticFeedbackService {
    
    /// Simple impact feedback using UIImpactFeedbackGenerator
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Notification feedback using UINotificationFeedbackGenerator
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
