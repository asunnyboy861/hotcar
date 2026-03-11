//
//  LiveActivityManager.swift
//  hotcar
//
//  HotCar Service - Live Activity Manager
//  Manages Live Activities for Dynamic Island and Lock Screen
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
final class LiveActivityManager {
    
    // MARK: - Singleton
    
    static let shared = LiveActivityManager()
    
    // MARK: - Properties
    
    private var currentActivity: Activity<WarmUpActivityAttributes>?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Start a new Live Activity
    func startActivity(
        vehicleId: String,
        vehicleName: String,
        duration: Int,
        temperature: Double
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        endActivity()
        
        let attributes = WarmUpActivityAttributes(
            vehicleId: vehicleId,
            startTime: Date()
        )
        
        let initialState = WarmUpActivityAttributes.ContentState(
            remainingTime: duration,
            totalTime: duration,
            vehicleName: vehicleName,
            temperature: temperature,
            isPaused: false
        )
        
        do {
            currentActivity = try Activity<WarmUpActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("Live Activity started: \(currentActivity?.id ?? "unknown")")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    /// Update the Live Activity state
    func updateActivity(
        remainingTime: Int,
        isPaused: Bool
    ) {
        guard let activity = currentActivity else { return }
        
        let updatedState = WarmUpActivityAttributes.ContentState(
            remainingTime: remainingTime,
            totalTime: activity.content.state.totalTime,
            vehicleName: activity.content.state.vehicleName,
            temperature: activity.content.state.temperature,
            isPaused: isPaused
        )
        
        Task {
            await activity.update(
                ActivityContent(state: updatedState, staleDate: nil)
            )
        }
    }
    
    /// End the Live Activity
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(
                ActivityContent(
                    state: WarmUpActivityAttributes.ContentState(
                        remainingTime: 0,
                        totalTime: activity.content.state.totalTime,
                        vehicleName: activity.content.state.vehicleName,
                        temperature: activity.content.state.temperature,
                        isPaused: false
                    ),
                    staleDate: nil
                ),
                dismissalPolicy: .default
            )
            currentActivity = nil
        }
    }
    
    /// End the Live Activity with completion message
    func endActivityWithCompletion() {
        guard let activity = currentActivity else { return }
        
        let finalState = WarmUpActivityAttributes.ContentState(
            remainingTime: 0,
            totalTime: activity.content.state.totalTime,
            vehicleName: activity.content.state.vehicleName,
            temperature: activity.content.state.temperature,
            isPaused: false
        )
        
        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .default
            )
            currentActivity = nil
        }
    }
    
    /// Check if Live Activity is active
    var isActivityActive: Bool {
        return currentActivity != nil
    }
}
