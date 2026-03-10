//
//  VehicleModel.swift
//  hotcar
//
//  HotCar Data Model - Vehicle
//  Represents a user's vehicle with all relevant properties
//

import Foundation

// MARK: - Vehicle Model

struct Vehicle: Identifiable, Codable, Hashable {
    
    // MARK: - Properties
    
    let id: String
    var name: String
    var year: Int
    var type: VehicleType
    var engineType: EngineType
    var hasBlockHeater: Bool
    var isPluggedIn: Bool
    var isPrimary: Bool
    
    // MARK: - Remote Start Configuration
    
    var brand: String?
    var vin: String?
    var apiToken: String?
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString,
        name: String,
        year: Int,
        type: VehicleType,
        engineType: EngineType,
        hasBlockHeater: Bool = false,
        isPluggedIn: Bool = false,
        isPrimary: Bool = false,
        brand: String? = nil,
        vin: String? = nil,
        apiToken: String? = nil
    ) {
        self.id = id
        self.name = name
        self.year = year
        self.type = type
        self.engineType = engineType
        self.hasBlockHeater = hasBlockHeater
        self.isPluggedIn = isPluggedIn
        self.isPrimary = isPrimary
        self.brand = brand
        self.vin = vin
        self.apiToken = apiToken
    }
    
    // MARK: - Display Properties
    
    var displayName: String {
        name
    }
    
    var fullDescription: String {
        "\(year) \(name) (\(type.displayName), \(engineType.displayName))"
    }
}

// MARK: - Vehicle Type

enum VehicleType: String, Codable, CaseIterable {
    case compact = "compact"
    case sedan = "sedan"
    case suv = "suv"
    case truck = "truck"
    
    var displayName: String {
        switch self {
        case .compact:
            return "Compact Car"
        case .sedan:
            return "Sedan"
        case .suv:
            return "SUV/Crossover"
        case .truck:
            return "Truck/Pickup"
        }
    }
    
    var icon: String {
        switch self {
        case .compact, .sedan:
            return "car.fill"
        case .suv:
            return "wagon.fill"
        case .truck:
            return "truck.fill"
        }
    }
    
    var warmUpMultiplier: Double {
        switch self {
        case .compact:
            return 0.8
        case .sedan:
            return 1.0
        case .suv:
            return 1.2
        case .truck:
            return 1.5
        }
    }
}

// MARK: - Engine Type

enum EngineType: String, Codable, CaseIterable {
    case gasoline = "gasoline"
    case diesel = "diesel"
    case hybrid = "hybrid"
    case electric = "electric"
    
    var displayName: String {
        switch self {
        case .gasoline:
            return "Gasoline"
        case .diesel:
            return "Diesel"
        case .hybrid:
            return "Hybrid"
        case .electric:
            return "Electric"
        }
    }
    
    var icon: String {
        switch self {
        case .gasoline, .diesel:
            return "fuel.fill"
        case .hybrid:
            return "leaf.fill"
        case .electric:
            return "bolt.fill"
        }
    }
    
    var warmUpMultiplier: Double {
        switch self {
        case .gasoline:
            return 1.0
        case .diesel:
            return 1.5
        case .hybrid:
            return 0.9
        case .electric:
            return 0.3
        }
    }
}

// MARK: - Sample Data

extension Vehicle {
    
    static let sampleVehicles: [Vehicle] = [
        Vehicle(
            name: "2023 Ford F-150",
            year: 2023,
            type: .truck,
            engineType: .gasoline,
            hasBlockHeater: true,
            isPrimary: true
        ),
        Vehicle(
            name: "2022 Toyota Camry",
            year: 2022,
            type: .sedan,
            engineType: .gasoline,
            hasBlockHeater: false
        ),
        Vehicle(
            name: "2024 Tesla Model Y",
            year: 2024,
            type: .suv,
            engineType: .electric,
            isPrimary: false
        )
    ]
}
