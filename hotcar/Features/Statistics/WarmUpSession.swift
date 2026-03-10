//
//  WarmUpSession.swift
//  hotcar
//
//  HotCar Statistics - Warm-up Session Model
//  Tracks individual warm-up sessions for statistics
//

import Foundation

struct WarmUpSession: Identifiable, Codable {
    let id: String
    let vehicleId: String
    let vehicleName: String
    let startTime: Date
    let endTime: Date?
    let durationMinutes: Int
    let outsideTemperature: Double
    let targetTemperature: Double?
    let vehicleType: String
    let engineType: String
    let completed: Bool
    let notes: String?
    
    var actualDuration: Int {
        if let endTime = endTime {
            return Int(endTime.timeIntervalSince(startTime) / 60)
        }
        return durationMinutes
    }
    
    var fuelEstimate: Double {
        // Estimate fuel consumption based on engine type and duration
        let baseRate: Double
        switch engineType {
        case "gas":
            baseRate = 0.5 // 0.5 L per hour at idle
        case "diesel":
            baseRate = 0.7 // 0.7 L per hour at idle
        case "hybrid":
            baseRate = 0.3 // 0.3 L per hour at idle
        default:
            baseRate = 0 // Electric - no fuel
        }
        
        return baseRate * (Double(durationMinutes) / 60.0)
    }
    
    var costEstimate: Double {
        // Estimate cost based on fuel type (CAD)
        let fuelPrice: Double = 1.60 // Average gas price per liter
        return fuelEstimate * fuelPrice
    }
}

// MARK: - Statistics Models

struct WarmUpStatistics {
    var totalSessions: Int = 0
    var totalMinutes: Int = 0
    var totalFuelUsed: Double = 0
    var totalCost: Double = 0
    var averageDuration: Double = 0
    var averageTemperature: Double = 0
    var sessionsByVehicle: [String: Int] = [:]
    var sessionsByType: [String: Int] = [:]
    var dailySessions: [String: Int] = [:]
    var weeklySessions: [String: Int] = [:]
    var monthlySessions: [String: Int] = [:]
    
    // Computed statistics
    var averageFuelPerSession: Double {
        guard totalSessions > 0 else { return 0 }
        return totalFuelUsed / Double(totalSessions)
    }
    
    var averageCostPerSession: Double {
        guard totalSessions > 0 else { return 0 }
        return totalCost / Double(totalSessions)
    }
    
    var estimatedMonthlySavings: Double {
        // Compare actual usage vs optimal usage
        let optimalMinutes = totalSessions * 10 // Assume 10 min is optimal
        let wastedMinutes = max(0, totalMinutes - optimalMinutes)
        let wastedFuel = wastedMinutes * 0.008 // ~0.5L/hour
        return wastedFuel * 1.60
    }
}

// MARK: - Chart Data

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}

struct TimeRangeData {
    var daily: [ChartDataPoint] = []
    var weekly: [ChartDataPoint] = []
    var monthly: [ChartDataPoint] = []
}
