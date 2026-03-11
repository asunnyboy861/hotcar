//
//  TimerState.swift
//  hotcar
//
//  HotCar Timer - Timer State Model
//  Represents the state of a warm-up timer
//

import Foundation

enum TimerState: Equatable {
    case idle
    case running(startTime: Date, duration: TimeInterval)
    case paused(remaining: TimeInterval)
    case completed
    
    var isActive: Bool {
        switch self {
        case .running, .paused:
            return true
        default:
            return false
        }
    }
    
    var isRunning: Bool {
        if case .running = self { return true }
        return false
    }
    
    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }
}

struct TimerDisplayData {
    let minutes: Int
    let seconds: Int
    let progress: Double
    let state: TimerState
    
    var formattedTime: String {
        String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
}

struct TimerPersistedState: Codable {
    let state: TimerState
    let timeRemaining: Int
    let totalTime: Int
    let vehicleId: String?
    let vehicleName: String?
    let temperature: Double?
    let startTime: Date?
}

// MARK: - TimerState Codable

extension TimerState: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case startTime
        case duration
        case remaining
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "idle":
            self = .idle
        case "running":
            let startTime = try container.decode(Date.self, forKey: .startTime)
            let duration = try container.decode(TimeInterval.self, forKey: .duration)
            self = .running(startTime: startTime, duration: duration)
        case "paused":
            let remaining = try container.decode(TimeInterval.self, forKey: .remaining)
            self = .paused(remaining: remaining)
        case "completed":
            self = .completed
        default:
            self = .idle
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .idle:
            try container.encode("idle", forKey: .type)
        case .running(let startTime, let duration):
            try container.encode("running", forKey: .type)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(duration, forKey: .duration)
        case .paused(let remaining):
            try container.encode("paused", forKey: .type)
            try container.encode(remaining, forKey: .remaining)
        case .completed:
            try container.encode("completed", forKey: .type)
        }
    }
}
