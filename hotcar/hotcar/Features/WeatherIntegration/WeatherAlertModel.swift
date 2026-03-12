//
//  WeatherAlertModel.swift
//  hotcar
//
//  HotCar Model - Weather Alert Data Models
//  Defines weather alert types and data structures
//

import Foundation

enum WeatherAlertType: String, Codable, CaseIterable {
    case extremeCold
    case temperatureDrop
    case snowstorm
    case freezingRain
    
    var displayName: String {
        switch self {
        case .extremeCold: return "Extreme Cold Warning"
        case .temperatureDrop: return "Temperature Drop Alert"
        case .snowstorm: return "Snowstorm Warning"
        case .freezingRain: return "Freezing Rain Alert"
        }
    }
    
    var icon: String {
        switch self {
        case .extremeCold: return "snowflake"
        case .temperatureDrop: return "thermometer.low"
        case .snowstorm: return "wind.snow"
        case .freezingRain: return "cloud.rain"
        }
    }
    
    var priority: AlertPriority {
        switch self {
        case .extremeCold: return .critical
        case .temperatureDrop: return .high
        case .snowstorm: return .critical
        case .freezingRain: return .high
        }
    }
}

enum AlertPriority: Int, Codable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
}

struct WeatherAlert: Identifiable, Codable {
    let id: String
    let type: WeatherAlertType
    let title: String
    let message: String
    let createdAt: Date
    let expiresAt: Date?
    var isRead: Bool
    let metadata: AlertMetadata?
}

struct AlertMetadata: Codable {
    let currentTemperature: Double?
    let forecastTemperature: Double?
    let temperatureChange: Double?
    let windSpeed: Double?
    let condition: String?
}
