//
//  ShareService.swift
//  hotcar
//
//  HotCar Service - Social Sharing
//  Generates shareable content from statistics
//

import Foundation
import UIKit

@MainActor
final class ShareService {
    
    // MARK: - Singleton
    
    static let shared = ShareService()
    
    // MARK: - Dependencies
    
    private let statisticsService = StatisticsService.shared
    
    // MARK: - Constants
    
    private let fuelPricePerGallon: Double = 3.50
    private let co2PerGallon: Double = 19.6
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func generateShareData(for period: ShareData.SharePeriod) -> ShareData {
        let sessions = getSessions(for: period)
        
        let fuelSaved = calculateFuelSaved(sessions: sessions)
        let moneySaved = calculateMoneySaved(fuelSaved: fuelSaved)
        let co2Reduced = calculateCO2Reduced(fuelSaved: fuelSaved)
        
        return ShareData(
            fuelSaved: fuelSaved,
            moneySaved: moneySaved,
            co2Reduced: co2Reduced,
            sessions: sessions.count,
            period: period
        )
    }
    
    func generateShareImage(from data: ShareData) -> UIImage? {
        let generator = ShareImageGenerator(data: data)
        return generator.generateImage()
    }
    
    /// Share data using system share sheet
    func share(data: ShareData, from viewController: UIViewController) {
        let items: [Any] = [
            data.shareText,
            generateShareImage(from: data) as Any
        ].compactMap { $0 }
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Exclude some activities
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo
        ]
        
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func getSessions(for period: ShareData.SharePeriod) -> [WarmUpSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .weekly:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
            return statisticsService.getSessions(for: DateRange(startDate: weekAgo, endDate: now))
            
        case .monthly:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return statisticsService.getSessions(for: DateRange(startDate: monthAgo, endDate: now))
            
        case .allTime:
            return statisticsService.sessions
        }
    }
    
    private func calculateFuelSaved(sessions: [WarmUpSession]) -> Double {
        let optimalMinutes = 10.0
        
        return sessions.reduce(0.0) { total, session in
            let actualMinutes = Double(session.durationMinutes)
            let wastedMinutes = max(0, actualMinutes - optimalMinutes)
            let fuelWasted = wastedMinutes * 0.5 / 60.0
            return total + fuelWasted
        }
    }
    
    private func calculateMoneySaved(fuelSaved: Double) -> Double {
        return fuelSaved * fuelPricePerGallon
    }
    
    private func calculateCO2Reduced(fuelSaved: Double) -> Double {
        return fuelSaved * co2PerGallon
    }
}
