//
//  WarmUpCalculationEngineTests.swift
//  hotcarTests
//
//  Unit Tests for Warm-Up Calculation Engine
//

import XCTest
@testable import hotcar

final class WarmUpCalculationEngineTests: XCTestCase {
    
    // MARK: - Temperature Range Tests
    
    func testTemperatureRangeCategorization() {
        // Test mild temperature (0°C to -10°C)
        XCTAssertEqual(
            WarmUpCalculationEngine.TemperatureRange.categorize(temperature: -5),
            .mild
        )
        
        // Test cold temperature (-10°C to -20°C)
        XCTAssertEqual(
            WarmUpCalculationEngine.TemperatureRange.categorize(temperature: -15),
            .cold
        )
        
        // Test very cold temperature (-20°C to -30°C)
        XCTAssertEqual(
            WarmUpCalculationEngine.TemperatureRange.categorize(temperature: -25),
            .veryCold
        )
        
        // Test extreme cold (below -30°C)
        XCTAssertEqual(
            WarmUpCalculationEngine.TemperatureRange.categorize(temperature: -35),
            .extreme
        )
    }
    
    // MARK: - Base Warm-Up Time Tests
    
    func testBaseWarmUpTimes() {
        XCTAssertEqual(WarmUpCalculationEngine.TemperatureRange.mild.baseWarmUpMinutes, 3)
        XCTAssertEqual(WarmUpCalculationEngine.TemperatureRange.cold.baseWarmUpMinutes, 7)
        XCTAssertEqual(WarmUpCalculationEngine.TemperatureRange.veryCold.baseWarmUpMinutes, 12)
        XCTAssertEqual(WarmUpCalculationEngine.TemperatureRange.extreme.baseWarmUpMinutes, 18)
    }
    
    // MARK: - Vehicle Type Multiplier Tests
    
    func testVehicleTypeMultipliers() {
        XCTAssertEqual(VehicleType.compact.warmUpMultiplier, 0.8)
        XCTAssertEqual(VehicleType.sedan.warmUpMultiplier, 1.0)
        XCTAssertEqual(VehicleType.suv.warmUpMultiplier, 1.2)
        XCTAssertEqual(VehicleType.truck.warmUpMultiplier, 1.5)
    }
    
    // MARK: - Engine Type Multiplier Tests
    
    func testEngineTypeMultipliers() {
        XCTAssertEqual(EngineType.gasoline.warmUpMultiplier, 1.0)
        XCTAssertEqual(EngineType.diesel.warmUpMultiplier, 1.5)
        XCTAssertEqual(EngineType.hybrid.warmUpMultiplier, 0.9)
        XCTAssertEqual(EngineType.electric.warmUpMultiplier, 0.3)
    }
    
    // MARK: - Warm-Up Time Calculation Tests
    
    func testWarmUpTimeCalculation_MildConditions() {
        let time = WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: -5,
            vehicleType: .sedan,
            engineType: .gasoline,
            hasBlockHeater: false,
            isPluggedIn: false
        )
        
        // Base: 3 min × Vehicle: 1.0 × Engine: 1.0 = 3 min
        XCTAssertEqual(time, 3)
    }
    
    func testWarmUpTimeCalculation_VeryColdWithBlockHeater() {
        let time = WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: -25,
            vehicleType: .suv,
            engineType: .gasoline,
            hasBlockHeater: true,
            isPluggedIn: true
        )
        
        // Base: 12 min × Vehicle: 1.2 × Engine: 1.0 × BlockHeater: 0.5 = 7.2 min ≈ 7 min
        XCTAssertEqual(time, 7)
    }
    
    func testWarmUpTimeCalculation_ExtremeColdDieselTruck() {
        let time = WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: -35,
            vehicleType: .truck,
            engineType: .diesel,
            hasBlockHeater: false,
            isPluggedIn: false
        )
        
        // Base: 18 min × Vehicle: 1.5 × Engine: 1.5 = 40.5 min ≈ 41 min
        XCTAssertEqual(time, 41)
    }
    
    func testWarmUpTimeCalculation_ElectricVehicle() {
        let time = WarmUpCalculationEngine.calculateWarmUpTime(
            temperature: -20,
            vehicleType: .sedan,
            engineType: .electric,
            hasBlockHeater: false,
            isPluggedIn: false
        )
        
        // Base: 12 min × Vehicle: 1.0 × Engine: 0.3 = 3.6 min ≈ 4 min
        XCTAssertEqual(time, 4)
    }
    
    // MARK: - Needs Warm-Up Test
    
    func testNeedsWarmUp() {
        XCTAssertTrue(WarmUpCalculationEngine.needsWarmUp(temperature: -5))
        XCTAssertTrue(WarmUpCalculationEngine.needsWarmUp(temperature: -20))
        XCTAssertFalse(WarmUpCalculationEngine.needsWarmUp(temperature: 5))
        XCTAssertFalse(WarmUpCalculationEngine.needsWarmUp(temperature: 0))
    }
    
    // MARK: - Fuel Savings Estimation Test
    
    func testFuelSavingsEstimation() {
        let savings = WarmUpCalculationEngine.estimateFuelSavings(
            optimalTime: 10,
            actualTime: 20,
            frequency: 5
        )
        
        // Excess: 10 min × 0.05 L/min × 5 times = 2.5 L
        XCTAssertEqual(savings, 2.5, accuracy: 0.01)
    }
    
    // MARK: - CO2 Emissions Estimation Test
    
    func testCO2EmissionsEstimation() {
        let emissions = WarmUpCalculationEngine.estimateCO2Emissions(
            warmUpTime: 10,
            frequency: 5
        )
        
        // 10 min × 0.02 kg/min × 5 times = 1.0 kg
        XCTAssertEqual(emissions, 1.0, accuracy: 0.01)
    }
}
