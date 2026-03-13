//
//  MaintenanceReminderModel.swift
//  hotcar
//
//  HotCar Vehicle Management - Maintenance Reminder Model
//

import Foundation

// MARK: - Maintenance Reminder

struct MaintenanceReminder: Identifiable, Codable {
    
    let id: String
    var vehicleId: String
    var type: MaintenanceType
    var title: String
    var description: String?
    var dueDate: Date?
    var dueMileage: Double?
    var isCompleted: Bool
    var completedDate: Date?
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        vehicleId: String,
        type: MaintenanceType,
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        dueMileage: Double? = nil,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.type = type
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.dueMileage = dueMileage
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.createdAt = createdAt
    }
    
    // MARK: - Display Properties
    
    var isOverdue: Bool {
        guard !isCompleted, let dueDate = dueDate else { return false }
        return Date() > dueDate
    }
    
    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }
    
    var statusText: String {
        if isCompleted {
            return "Completed"
        } else if isOverdue {
            return "Overdue"
        } else if let days = daysUntilDue {
            if days <= 7 {
                return "Due in \(days) days"
            } else {
                return "Scheduled"
            }
        }
        return "No Due Date"
    }
}

// MARK: - Maintenance Type

enum MaintenanceType: String, Codable, CaseIterable {
    case oilChange = "oilChange"
    case tireRotation = "tireRotation"
    case brakeInspection = "brakeInspection"
    case batteryCheck = "batteryCheck"
    case coolantFlush = "coolantFlush"
    case transmissionService = "transmissionService"
    case airFilterReplacement = "airFilterReplacement"
    case sparkPlugReplacement = "sparkPlugReplacement"
    case winterPreparation = "winterPreparation"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .oilChange:
            return "Oil Change"
        case .tireRotation:
            return "Tire Rotation"
        case .brakeInspection:
            return "Brake Inspection"
        case .batteryCheck:
            return "Battery Check"
        case .coolantFlush:
            return "Coolant Flush"
        case .transmissionService:
            return "Transmission Service"
        case .airFilterReplacement:
            return "Air Filter Replacement"
        case .sparkPlugReplacement:
            return "Spark Plug Replacement"
        case .winterPreparation:
            return "Winter Preparation"
        case .other:
            return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .oilChange:
            return "drop.fill"
        case .tireRotation:
            return "circle.circle"
        case .brakeInspection:
            return "exclamationmark.circle.fill"  // Changed from "disc.fill" for iOS 15/16 compatibility
        case .batteryCheck:
            return "battery.100"
        case .coolantFlush:
            return "thermometer"  // Changed from "thermometer.liquid.fill" for iOS 15/16 compatibility
        case .transmissionService:
            return "gearshape.fill"
        case .airFilterReplacement:
            return "wind"
        case .sparkPlugReplacement:
            return "bolt.fill"
        case .winterPreparation:
            return "snowflake"
        case .other:
            return "wrench"
        }
    }
    
    var defaultInterval: TimeInterval {
        switch self {
        case .oilChange:
            return 90 * 24 * 60 * 60 // 90 days
        case .tireRotation:
            return 180 * 24 * 60 * 60 // 180 days
        case .brakeInspection:
            return 365 * 24 * 60 * 60 // 1 year
        case .batteryCheck:
            return 180 * 24 * 60 * 60 // 180 days
        case .coolantFlush:
            return 730 * 24 * 60 * 60 // 2 years
        case .transmissionService:
            return 730 * 24 * 60 * 60 // 2 years
        case .airFilterReplacement:
            return 365 * 24 * 60 * 60 // 1 year
        case .sparkPlugReplacement:
            return 1825 * 24 * 60 * 60 // 5 years
        case .winterPreparation:
            return 365 * 24 * 60 * 60 // 1 year (seasonal)
        case .other:
            return 0
        }
    }
}

// MARK: - Sample Data

extension MaintenanceReminder {
    
    static let sampleReminders: [MaintenanceReminder] = [
        MaintenanceReminder(
            vehicleId: "1",
            type: .oilChange,
            title: "Regular Oil Change",
            dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            isCompleted: false
        ),
        MaintenanceReminder(
            vehicleId: "1",
            type: .winterPreparation,
            title: "Winter Tire Installation",
            dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
            isCompleted: false
        ),
        MaintenanceReminder(
            vehicleId: "1",
            type: .batteryCheck,
            title: "Battery Health Check",
            dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            isCompleted: false
        )
    ]
}
