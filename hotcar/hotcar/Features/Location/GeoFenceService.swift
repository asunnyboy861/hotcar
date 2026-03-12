//
//  GeoFenceService.swift
//  hotcar
//
//  HotCar Service - GeoFence Management
//  Manages location-based triggers and notifications
//

import Foundation
import Combine
import CoreLocation
import UserNotifications

@MainActor
final class GeoFenceService: ObservableObject {
    
    static let shared = GeoFenceService()
    
    @Published var zones: [GeoFenceZone] = []
    @Published var isMonitoring: Bool = false
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var activeZones: [GeoFenceZone] = []
    
    private let locationService = LocationService.shared
    private let notificationService = NotificationService.shared
    private let storageKey = "com.hotcar.geofences"
    private var cancellables = Set<AnyCancellable>()
    private var lastKnownZones: Set<String> = []
    
    private init() {
        loadZonesSync()
        setupLocationMonitoring()
    }
    
    func loadZones() async {
        loadZonesSync()
    }
    
    private func loadZonesSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([GeoFenceZone].self, from: data) else {
            zones = []
            return
        }
        zones = decoded
    }
    
    func saveZone(_ zone: GeoFenceZone) async {
        if let index = zones.firstIndex(where: { $0.id == zone.id }) {
            zones[index] = zone
        } else {
            zones.append(zone)
        }
        saveZonesSync()
    }
    
    func deleteZone(_ zoneId: String) async {
        zones.removeAll { $0.id == zoneId }
        saveZonesSync()
    }
    
    func toggleZone(_ zoneId: String) async {
        if let index = zones.firstIndex(where: { $0.id == zoneId }) {
            zones[index].isEnabled.toggle()
            saveZonesSync()
        }
    }
    
    private func saveZonesSync() {
        if let encoded = try? JSONEncoder().encode(zones) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func setupLocationMonitoring() {
        locationService.$currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.checkGeoFences(for: location)
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkGeoFences(for location: CLLocationCoordinate2D) {
        let enabledZones = zones.filter { $0.isEnabled }
        var currentZones: Set<String> = []
        
        for zone in enabledZones {
            if zone.contains(location: location) {
                currentZones.insert(zone.id)
                
                if !lastKnownZones.contains(zone.id) {
                    Task {
                        await handleZoneEntry(zone)
                    }
                }
            } else {
                if lastKnownZones.contains(zone.id) {
                    Task {
                        await handleZoneExit(zone)
                    }
                }
            }
        }
        
        lastKnownZones = currentZones
        activeZones = enabledZones.filter { currentZones.contains($0.id) }
    }
    
    private func handleZoneEntry(_ zone: GeoFenceZone) async {
        guard zone.triggerOnEntry else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📍 Arrived at \(zone.name)"
        content.body = "You've entered \(zone.name). Ready to start your warm-up?"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "geofence_entry_\(zone.id)_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending geo-fence entry notification: \(error)")
        }
    }
    
    private func handleZoneExit(_ zone: GeoFenceZone) async {
        guard zone.triggerOnExit else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "👋 Leaving \(zone.name)"
        content.body = "Don't forget to start your remote warm-up!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "geofence_exit_\(zone.id)_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending geo-fence exit notification: \(error)")
        }
    }
    
    func createHomeZone(radius: Double = 100.0) async {
        guard let location = locationService.currentLocation else { return }
        
        let zone = GeoFenceZone(
            id: UUID().uuidString,
            name: "Home",
            center: CLLocationCoordinate2DCodable(from: location),
            radius: radius,
            isEnabled: true,
            triggerOnEntry: false,
            triggerOnExit: true,
            vehicleId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await saveZone(zone)
    }
    
    func createWorkZone(radius: Double = 100.0) async {
        guard let location = locationService.currentLocation else { return }
        
        let zone = GeoFenceZone(
            id: UUID().uuidString,
            name: "Work",
            center: CLLocationCoordinate2DCodable(from: location),
            radius: radius,
            isEnabled: true,
            triggerOnEntry: true,
            triggerOnExit: true,
            vehicleId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await saveZone(zone)
    }
}
