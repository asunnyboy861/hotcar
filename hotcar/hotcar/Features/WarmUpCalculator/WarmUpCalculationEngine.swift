//
//  WarmUpCalculationEngine.swift
//  hotcar
//
//  HotCar Core - Warm-Up Calculation Engine
//  Scientific algorithm for optimal warm-up time calculation
//

import Foundation

// MARK: - Warm-Up Calculation Engine

final class WarmUpCalculationEngine {
    
    // MARK: - Temperature Categories
    
    enum TemperatureRange {
        case mild          // 0°C to -10°C
        case cold          // -10°C to -20°C
        case veryCold      // -20°C to -30°C
        case extreme       // Below -30°C
        
        // MARK: - Categorization
        
        static func categorize(temperature: Double) -> TemperatureRange {
            switch temperature {
            case -10...0:
                return .mild
            case -20..<(-10):
                return .cold
            case -30..<(-20):
                return .veryCold
            default:
                return .extreme
            }
        }
        
        // MARK: - Base Warm-Up Time
        
        var baseWarmUpMinutes: Int {
            switch self {
            case .mild:
                return 3
            case .cold:
                return 7
            case .veryCold:
                return 12
            case .extreme:
                return 18
            }
        }
        
        // MARK: - Display Properties
        
        var displayName: String {
            switch self {
            case .mild:
                return "Mild"
            case .cold:
                return "Cold"
            case .veryCold:
                return "Very Cold"
            case .extreme:
                return "Extreme"
            }
        }
        
        var icon: String {
            switch self {
            case .mild:
                return "thermometer.medium"
            case .cold:
                return "thermometer.low"
            case .veryCold:
                return "snowflake"
            case .extreme:
                return "wind.snow"
            }
        }
    }
    
    // MARK: - Main Calculation Function
    
    /// Calculate optimal warm-up time in minutes
    /// - Parameters:
    ///   - temperature: Current outside temperature in Celsius
    ///   - vehicleType: Type of vehicle
    ///   - engineType: Type of engine
    ///   - hasBlockHeater: Whether vehicle uses engine block heater
    ///   - isPluggedIn: Whether block heater is currently plugged in
    /// - Returns: Recommended warm-up time in minutes (rounded)
    static func calculateWarmUpTime(
        temperature: Double,
        vehicleType: VehicleType,
        engineType: EngineType,
        hasBlockHeater: Bool = false,
        isPluggedIn: Bool = false
    ) -> Int {
        // Step 1: Get base time from temperature
        let tempRange = TemperatureRange.categorize(temperature: temperature)
        let baseTime = Double(tempRange.baseWarmUpMinutes)
        
        // Step 2: Apply vehicle type multiplier
        let vehicleMultiplier = vehicleType.warmUpMultiplier
        
        // Step 3: Apply engine type multiplier
        let engineMultiplier = engineType.warmUpMultiplier
        
        // Step 4: Apply block heater correction (reduces time by 50%)
        let blockHeaterMultiplier: Double = hasBlockHeater && isPluggedIn ? 0.5 : 1.0
        
        // Step 5: Calculate total time
        let totalTime = baseTime * vehicleMultiplier * engineMultiplier * blockHeaterMultiplier
        
        // Step 6: Round to nearest minute
        return Int(round(totalTime))
    }
    
    // MARK: - Helper Functions
    
    /// Determine if warm-up is needed at all
    static func needsWarmUp(temperature: Double) -> Bool {
        return temperature < 0
    }
    
    /// Get contextual advice based on conditions
    static func getWarmUpAdvice(
        temperature: Double,
        warmUpTime: Int,
        engineType: EngineType
    ) -> String {
        var advice: [String] = []
        
        // Temperature warnings
        if temperature < -30 {
            advice.append("⚠️ EXTREME COLD: Use block heater and extend warm-up time.")
        } else if temperature < -20 {
            advice.append("🥶 VERY COLD: Full warm-up recommended.")
        } else if temperature < -10 {
            advice.append("❄️ COLD: Warm-up advised for engine longevity.")
        }
        
        // Engine-specific advice
        switch engineType {
        case .diesel:
            advice.append("💡 Diesel engines require longer warm-up periods.")
        case .electric:
            advice.append("🔋 Pre-heating battery improves range and charging speed.")
        case .hybrid:
            advice.append("🌿 Hybrid system warms faster than conventional engines.")
        default:
            break
        }
        
        // Fuel consumption note
        if warmUpTime > 10 {
            let estimatedFuel = Double(warmUpTime) * 0.05
            advice.append(String(format: "⛽ Estimated fuel consumption: %.2f L", estimatedFuel))
        }
        
        return advice.joined(separator: "\n")
    }
    
    // MARK: - Fuel Savings Estimation
    
    /// Estimate fuel saved by using optimal vs excessive warm-up
    static func estimateFuelSavings(
        optimalTime: Int,
        actualTime: Int,
        frequency: Int // times per week
    ) -> Double {
        guard actualTime > optimalTime else { return 0 }
        
        let excessMinutes = actualTime - optimalTime
        let fuelPerMinute = 0.05 // liters
        let weeklySavings = Double(excessMinutes) * fuelPerMinute * Double(frequency)
        
        return weeklySavings
    }
    
    // MARK: - CO2 Emissions Estimation
    
    /// Estimate CO2 emissions from warm-up
    static func estimateCO2Emissions(warmUpTime: Int, frequency: Int) -> Double {
        let co2PerMinute = 0.02 // kg CO2 per minute of idling
        let weeklyEmissions = Double(warmUpTime) * co2PerMinute * Double(frequency)
        return weeklyEmissions
    }
}

// MARK: - Warm-Up Result Model

struct WarmUpResult {
    let temperature: Double
    let warmUpTime: Int
    let tempRange: WarmUpCalculationEngine.TemperatureRange
    let advice: String
    let fuelSavings: Double
    let co2Emissions: Double
}

// MARK: - Preview/Testing

#if DEBUG
extension WarmUpCalculationEngine {
    
    static func preview() -> WarmUpResult {
        let temperature = -25.0
        let vehicleType = VehicleType.truck
        let engineType = EngineType.gasoline
        
        let warmUpTime = calculateWarmUpTime(
            temperature: temperature,
            vehicleType: vehicleType,
            engineType: engineType,
            hasBlockHeater: true,
            isPluggedIn: true
        )
        
        let advice = getWarmUpAdvice(
            temperature: temperature,
            warmUpTime: warmUpTime,
            engineType: engineType
        )
        
        return WarmUpResult(
            temperature: temperature,
            warmUpTime: warmUpTime,
            tempRange: .veryCold,
            advice: advice,
            fuelSavings: 2.5,
            co2Emissions: 1.8
        )
    }
}
#endif
