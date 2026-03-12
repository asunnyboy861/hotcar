//
//  GeoFenceModel.swift
//  hotcar
//
//  HotCar Model - GeoFence Data Models
//  Defines geo-fence zones and tracking
//

import Foundation
import CoreLocation

struct CLLocationCoordinate2DCodable: Codable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

struct GeoFenceZone: Identifiable, Codable {
    let id: String
    let name: String
    let center: CLLocationCoordinate2DCodable
    let radius: Double
    var isEnabled: Bool
    let triggerOnEntry: Bool
    let triggerOnExit: Bool
    let vehicleId: String?
    let createdAt: Date
    var updatedAt: Date
    
    func contains(location: CLLocationCoordinate2D) -> Bool {
        let distance = calculateDistance(from: center.coordinate, to: location)
        return distance <= radius
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371000.0
        let lat1 = from.latitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let deltaLat = (to.latitude - from.latitude).degreesToRadians
        let deltaLon = (to.longitude - from.longitude).degreesToRadians
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
}

extension Double {
    var degreesToRadians: Double {
        self * .pi / 180.0
    }
}

enum GeoFenceEventType: String, Codable {
    case entry = "ENTRY"
    case exit = "EXIT"
}

struct GeoFenceEvent: Codable {
    let zoneId: String
    let zoneName: String
    let eventType: GeoFenceEventType
    let timestamp: Date
    let location: CLLocationCoordinate2DCodable
}
