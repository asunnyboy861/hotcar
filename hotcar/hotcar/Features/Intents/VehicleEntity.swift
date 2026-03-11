//
//  VehicleEntity.swift
//  hotcar
//
//  HotCar Siri Intent - Vehicle Entity
//  Represents a vehicle for Siri shortcuts
//

import AppIntents
import Foundation

@available(iOS 16.0, *)
struct VehicleEntity: AppEntity {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Vehicle")
    static var defaultQuery = VehicleQuery()
    
    var id: String
    var displayString: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
}

// MARK: - Vehicle Query

@available(iOS 16.0, *)
struct VehicleQuery: EntityQuery {
    
    func entities(for identifiers: [String]) async throws -> [VehicleEntity] {
        let vehicles = await VehicleService.shared.vehicles
        return vehicles
            .filter { identifiers.contains($0.id) }
            .map { VehicleEntity(id: $0.id, displayString: $0.name) }
    }
    
    func suggestedEntities() async throws -> [VehicleEntity] {
        let vehicles = await VehicleService.shared.vehicles
        return vehicles.map { VehicleEntity(id: $0.id, displayString: $0.name) }
    }
    
    func defaultResult() async -> VehicleEntity? {
        let vehicles = await VehicleService.shared.vehicles
        guard let primary = vehicles.first(where: { $0.isPrimary }) ?? vehicles.first else {
            return nil
        }
        return VehicleEntity(id: primary.id, displayString: primary.name)
    }
}
