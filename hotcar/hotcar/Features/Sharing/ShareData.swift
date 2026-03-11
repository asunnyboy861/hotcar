//
//  ShareData.swift
//  hotcar
//
//  HotCar Sharing - Share Data Model
//  Represents shareable statistics data
//

import Foundation

struct ShareData {
    let fuelSaved: Double
    let moneySaved: Double
    let co2Reduced: Double
    let sessions: Int
    let period: SharePeriod
    
    enum SharePeriod {
        case weekly
        case monthly
        case allTime
        
        var displayName: String {
            switch self {
            case .weekly: return "This Week"
            case .monthly: return "This Month"
            case .allTime: return "All Time"
            }
        }
    }
    
    var formattedFuelSaved: String {
        String(format: "%.1f gal", fuelSaved)
    }
    
    var formattedMoneySaved: String {
        String(format: "$%.2f", moneySaved)
    }
    
    var formattedCO2Reduced: String {
        String(format: "%.1f lbs", co2Reduced)
    }
    
    var shareText: String {
        """
        🚗 My HotCar Stats (\(period.displayName)):
        
        💰 Money Saved: \(formattedMoneySaved)
        ⛽ Fuel Saved: \(formattedFuelSaved)
        🌱 CO₂ Reduced: \(formattedCO2Reduced)
        🔥 Warm-Up Sessions: \(sessions)
        
        Download HotCar to optimize your winter warm-ups!
        #HotCar #WinterWarmUp #FuelEfficiency
        """
    }
}
