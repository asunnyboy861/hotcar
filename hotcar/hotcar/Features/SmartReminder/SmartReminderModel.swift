//
//  SmartReminderModel.swift
//  hotcar
//
//  HotCar Model - Smart Reminder Data Models
//  Defines reminder schedules and configurations
//

import Foundation

struct ReminderSchedule: Identifiable, Codable {
    let id: String
    let departureTime: Date
    var isEnabled: Bool
    let repeatDays: Set<Weekday>
    let vehicleId: String?
    let customWarmUpTime: Int?
    let advanceNoticeMinutes: Int
    let createdAt: Date
    var updatedAt: Date
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var displayName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var isWeekend: Bool {
        self == .sunday || self == .saturday
    }
}

struct ReminderTrigger: Codable {
    let scheduleId: String
    let triggerTime: Date
    let departureTime: Date
    let recommendedWarmUpTime: Int
    let vehicleName: String
}
