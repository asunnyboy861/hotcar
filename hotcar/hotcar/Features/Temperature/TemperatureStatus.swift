//
//  TemperatureStatus.swift
//  hotcar
//
//  HotCar Temperature - Temperature Status Enumeration
//  Unified temperature status judgment (internal use Celsius)
//  Optimized for US/Canada/Nordic markets with English localization
//

import SwiftUI

// MARK: - Temperature Status Enumeration

/// Temperature status enumeration
/// Responsibility: Unified temperature status judgment (internal use Celsius)
enum TemperatureStatus: CaseIterable {
    case extreme      // < -30°C
    case veryCold     // -30°C to -20°C
    case cold         // -20°C to -10°C
    case mild         // -10°C to 0°C
    case aboveFreezing // > 0°C
    
    // MARK: - Status Judgment
    
    /// Judge status from Celsius temperature
    static func from(celsius: Double) -> TemperatureStatus {
        switch celsius {
        case ..<(-30): return .extreme
        case -30..<(-20): return .veryCold
        case -20..<(-10): return .cold
        case -10..<0: return .mild
        default: return .aboveFreezing
        }
    }
    
    // MARK: - Display Properties
    
    /// Display text (English for US/Canada/Nordic markets)
    var displayText: String {
        switch self {
        case .extreme:
            return NSLocalizedString("temp_status_extreme", tableName: "Localizable", comment: "Extreme cold alert - used when temp < -30°C")
        case .veryCold:
            return NSLocalizedString("temp_status_very_cold", tableName: "Localizable", comment: "Very cold - used when temp -30°C to -20°C")
        case .cold:
            return NSLocalizedString("temp_status_cold", tableName: "Localizable", comment: "Cold - used when temp -20°C to -10°C")
        case .mild:
            return NSLocalizedString("temp_status_mild", tableName: "Localizable", comment: "Chilly - used when temp -10°C to 0°C, 'mild' changed to 'chilly' for North American usage")
        case .aboveFreezing:
            return NSLocalizedString("temp_status_above_freezing", tableName: "Localizable", comment: "Above freezing - used when temp > 0°C")
        }
    }
    
    /// Corresponding color
    var color: Color {
        switch self {
        case .extreme: return .tempExtreme
        case .veryCold: return .tempVeryCold
        case .cold: return .tempCold
        case .mild: return .tempMild
        case .aboveFreezing: return .hotCarPrimary
        }
    }
    
    /// System icon name
    var icon: String {
        switch self {
        case .extreme: return "exclamationmark.triangle.fill"
        case .veryCold: return "snowflake"
        case .cold: return "thermometer.snowflake"
        case .mild: return "thermometer.low"
        case .aboveFreezing: return "thermometer.medium"
        }
    }
    
    /// Warm-up advice based on temperature status
    var warmUpAdvice: String {
        switch self {
        case .extreme:
            return NSLocalizedString("advice_extreme_cold", tableName: "Localizable", comment: "Advice for extreme cold: use block heater and extend warm-up time")
        case .veryCold:
            return NSLocalizedString("advice_very_cold", tableName: "Localizable", comment: "Advice for very cold: full warm-up recommended for engine protection")
        case .cold:
            return NSLocalizedString("advice_cold", tableName: "Localizable", comment: "Advice for cold: warm-up advised for optimal performance")
        case .mild:
            return NSLocalizedString("advice_mild", tableName: "Localizable", comment: "Advice for chilly weather: short warm-up recommended")
        case .aboveFreezing:
            return NSLocalizedString("advice_above_freezing", tableName: "Localizable", comment: "Advice for above freezing: warm-up optional")
        }
    }
}

// MARK: - AppSettings.TemperatureUnit Extension

extension AppSettings.TemperatureUnit {
    /// Get temperature status (helper method)
    func status(for celsius: Double) -> TemperatureStatus {
        TemperatureStatus.from(celsius: celsius)
    }
}

// MARK: - Preview

#Preview("Temperature Status") {
    VStack(spacing: 20) {
        ForEach(TemperatureStatus.allCases, id: \.self) { status in
            HStack {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                Text(status.displayText)
                    .foregroundColor(status.color)
                Spacer()
            }
            .padding()
            .background(Color.backgroundCard)
            .cornerRadius(8)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
