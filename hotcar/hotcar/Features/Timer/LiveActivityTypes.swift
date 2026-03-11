//
//  LiveActivityTypes.swift
//  hotcar
//
//  HotCar Shared - Live Activity Types
//  Shared types for Live Activity support
//

import Foundation
import ActivityKit

// MARK: - Activity Attributes

struct WarmUpActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: Int
        var totalTime: Int
        var vehicleName: String
        var temperature: Double
        var isPaused: Bool
        var progress: Double {
            guard totalTime > 0 else { return 0 }
            return Double(totalTime - remainingTime) / Double(totalTime)
        }
        
        var formattedTime: String {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var vehicleId: String
    var startTime: Date
}
