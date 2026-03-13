//
//  WarmUpStatistics+Extensions.swift
//  hotcar
//
//  HotCar Statistics - WarmUpStatistics Extensions
//  Additional computed properties for UI display
//  Optimized for US/Canada/Nordic markets with English localization
//

import Foundation

// MARK: - WarmUpStatistics Extensions

extension WarmUpStatistics {
    
    // MARK: - CO2 Calculations
    
    /// CO2 emissions (kg) - calculated from fuel used
    /// Based on: 1 liter of gasoline produces approximately 2.3 kg of CO2
    var totalCO2Emitted: Double {
        totalFuelUsed * 2.3
    }
    
    /// Net CO2 impact (saved - emitted)
    var netCO2Impact: Double {
        totalCO2Saved - totalCO2Emitted
    }
    
    /// CO2 savings per session (kg)
    var averageCO2SavedPerSession: Double {
        guard totalSessions > 0 else { return 0 }
        return totalCO2Saved / Double(totalSessions)
    }
    
    // MARK: - Formatting Helpers
    
    /// Formatted total cost (USD/CAD)
    var formattedCost: String {
        String(format: "%.2f", totalCost)
    }
    
    /// Formatted fuel used in liters
    var formattedFuelUsed: String {
        String(format: "%.1f L", totalFuelUsed)
    }
    
    /// Formatted fuel saved in liters
    var formattedFuelSaved: String {
        String(format: "%.1f L", totalFuelSaved)
    }
    
    /// Formatted CO2 saved in kg
    var formattedCO2Saved: String {
        String(format: "%.1f kg", totalCO2Saved)
    }
    
    /// Formatted CO2 emitted in kg
    var formattedCO2Emitted: String {
        String(format: "%.1f kg", totalCO2Emitted)
    }
    
    /// Formatted average duration in minutes
    var formattedAverageDuration: String {
        String(format: "%.0f min", averageDuration)
    }
    
    /// Formatted average temperature with unit
    func formattedAverageTemperature(unit: AppSettings.TemperatureUnit) -> String {
        unit.format(averageTemperature)
    }
    
    // MARK: - Environmental Impact Descriptions
    
    /// Environmental impact description for UI
    var environmentalImpactDescription: String {
        let treesEquivalent = totalCO2Saved / 21.0 // Approximate CO2 absorbed by one tree per year (kg)
        
        if treesEquivalent >= 1 {
            return String(format: NSLocalizedString("impact_trees_equivalent", tableName: "Localizable", comment: "Environmental impact expressed as equivalent trees planted"), treesEquivalent)
        } else if totalCO2Saved > 0 {
            return NSLocalizedString("impact_positive", tableName: "Localizable", comment: "Message indicating positive environmental impact")
        } else {
            return NSLocalizedString("impact_start_tracking", tableName: "Localizable", comment: "Prompt to start tracking to see environmental impact")
        }
    }
    
    /// Cost savings description
    var costSavingsDescription: String {
        if totalCost > 0 {
            return String(format: NSLocalizedString("cost_saved_amount", tableName: "Localizable", comment: "Message showing amount of money saved on fuel"), formattedCost)
        } else {
            return NSLocalizedString("cost_no_data", tableName: "Localizable", comment: "Message shown when no cost data is available")
        }
    }
    
    // MARK: - Validation
    
    /// Check if statistics has meaningful data
    var hasData: Bool {
        totalSessions > 0
    }
    
    /// Check if user is new (no sessions)
    var isNewUser: Bool {
        totalSessions == 0
    }
}

// MARK: - Time Range Extension

extension TimeRange {
    var displayName: String {
        switch self {
        case .daily:
            return NSLocalizedString("time_range_day", tableName: "Localizable", comment: "Time range option for daily statistics")
        case .weekly:
            return NSLocalizedString("time_range_week", tableName: "Localizable", comment: "Time range option for weekly statistics")
        case .monthly:
            return NSLocalizedString("time_range_month", tableName: "Localizable", comment: "Time range option for monthly statistics")
        }
    }
}

// MARK: - Preview Helpers

extension WarmUpStatistics {
    /// Sample statistics for previews
    static var sample: WarmUpStatistics {
        WarmUpStatistics(
            totalSessions: 24,
            totalMinutes: 180,
            totalFuelUsed: 12.5,
            totalCost: 25.30,
            totalFuelSaved: 3.8,
            totalCO2Saved: 8.7,
            averageDuration: 7.5,
            averageTemperature: -15.0,
            sessionsByVehicle: ["Ford F-150": 15, "Toyota Camry": 9],
            sessionsByType: ["Gasoline": 24],
            dailySessions: [:],
            weeklySessions: [:],
            monthlySessions: [:]
        )
    }
    
    /// Empty statistics for new user previews
    static var empty: WarmUpStatistics {
        WarmUpStatistics()
    }
}
