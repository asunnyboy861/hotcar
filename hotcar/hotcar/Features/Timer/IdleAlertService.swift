//
//  IdleAlertService.swift
//  hotcar
//
//  HotCar Service - Idle Alert Management
//  Manages idle warnings and statistics
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class IdleAlertService: ObservableObject {
    
    static let shared = IdleAlertService()
    
    @Published var totalIdleWarnings: Int = 0
    @Published var totalIdleSeconds: Int = 0
    @Published var fuelWasted: Double = 0.0
    @Published var co2Wasted: Double = 0.0
    
    private let storageKey = "com.hotcar.idlealerts"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadStatsSync()
    }
    
    func loadStats() async {
        loadStatsSync()
    }
    
    private func loadStatsSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(IdleStats.self, from: data) else {
            return
        }
        
        totalIdleWarnings = decoded.totalWarnings
        totalIdleSeconds = decoded.totalSeconds
        fuelWasted = decoded.fuelWasted
        co2Wasted = decoded.co2Wasted
    }
    
    func recordIdleSession(seconds: Int, warningLevel: Int) async {
        totalIdleSeconds += seconds
        totalIdleWarnings += warningLevel
        
        let fuelRate = 0.5 / 3600.0
        let wastedFuel = Double(seconds) * fuelRate
        fuelWasted += wastedFuel
        
        let co2PerLiter = 2.3
        co2Wasted += wastedFuel * co2PerLiter
        
        saveStatsSync()
    }
    
    func resetStats() async {
        totalIdleWarnings = 0
        totalIdleSeconds = 0
        fuelWasted = 0.0
        co2Wasted = 0.0
        saveStatsSync()
    }
    
    private func saveStatsSync() {
        let stats = IdleStats(
            totalWarnings: totalIdleWarnings,
            totalSeconds: totalIdleSeconds,
            fuelWasted: fuelWasted,
            co2Wasted: co2Wasted
        )
        
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

struct IdleStats: Codable {
    let totalWarnings: Int
    let totalSeconds: Int
    let fuelWasted: Double
    let co2Wasted: Double
}
