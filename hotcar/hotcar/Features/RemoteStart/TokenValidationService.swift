//
//  TokenValidationService.swift
//  hotcar
//
//  HotCar Service - Token Validation Service
//  Periodically validates API tokens and alerts users before expiration
//

import Foundation
import Combine
import UserNotifications

final class TokenValidationService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = TokenValidationService()
    
    // MARK: - Published Properties
    
    @Published var tokenStatus: [VehicleBrand: TokenStatus] = [:]
    @Published var isValidating: Bool = false
    
    // MARK: - Constants
    
    private let validationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private let warningDays: Int = 7
    
    // MARK: - Timer
    
    private var validationTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupPeriodicValidation()
    }
    
    deinit {
        validationTimer?.invalidate()
    }
    
    // MARK: - Periodic Validation Setup
    
    private func setupPeriodicValidation() {
        validationTimer = Timer.scheduledTimer(withTimeInterval: validationInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.validateAllTokens()
            }
        }
    }
    
    // MARK: - Token Status
    
    struct TokenStatus: Equatable {
        let brand: VehicleBrand
        let isValid: Bool
        let expiresAt: Date?
        let daysUntilExpiry: Int?
        
        var statusDescription: String {
            if !isValid {
                return "Invalid"
            }
            if let days = daysUntilExpiry {
                if days <= 0 {
                    return "Expired"
                } else if days <= 7 {
                    return "Expiring in \(days) day(s)"
                } else {
                    return "Valid"
                }
            }
            return "Valid"
        }
    }
    
    // MARK: - Validation
    
    @MainActor
    func validateAllTokens() async {
        isValidating = true
        
        var statuses: [VehicleBrand: TokenStatus] = [:]
        
        let brands: [VehicleBrand] = [.tesla, .ford, .gm, .toyota]
        
        for brand in brands {
            let status = await validateToken(for: brand)
            statuses[brand] = status
        }
        
        tokenStatus = statuses
        
        await alertForExpiringTokens(statuses)
        
        isValidating = false
    }
    
    private func validateToken(for brand: VehicleBrand) async -> TokenStatus {
        var hasToken: Bool = false
        
        switch brand {
        case .tesla:
            hasToken = TeslaAPIService.shared.isAuthenticated
        case .ford:
            hasToken = FordAPIService.shared.isAuthenticated
        case .gm:
            hasToken = GMAPIService.shared.isAuthenticated
        case .toyota:
            hasToken = ToyotaAPIService.shared.isAuthenticated
        }
        
        guard hasToken else {
            return TokenStatus(
                brand: brand,
                isValid: false,
                expiresAt: nil,
                daysUntilExpiry: nil
            )
        }
        
        let expirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        
        return TokenStatus(
            brand: brand,
            isValid: daysUntilExpiry > 0,
            expiresAt: expirationDate,
            daysUntilExpiry: daysUntilExpiry
        )
    }
    
    // MARK: - Alert for Expiring Tokens
    
    @MainActor
    private func alertForExpiringTokens(_ statuses: [VehicleBrand: TokenStatus]) async {
        for (brand, status) in statuses {
            if let days = status.daysUntilExpiry, days <= warningDays, days > 0 {
                await sendExpiryNotification(brand: brand, daysRemaining: days)
            }
        }
    }
    
    private func sendExpiryNotification(brand: VehicleBrand, daysRemaining: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "API Token Expiring Soon"
        content.body = "Your \(brand.displayName) API token will expire in \(daysRemaining) day(s). Please re-login to avoid service interruption."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "token_expiry_\(brand.rawValue)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send notification: \(error)")
        }
    }
    
    // MARK: - Check Token Validity
    
    func isTokenValid(for brand: VehicleBrand) -> Bool {
        return tokenStatus[brand]?.isValid ?? false
    }
    
    func getStatus(for brand: VehicleBrand) -> TokenStatus? {
        return tokenStatus[brand]
    }
    
    // MARK: - Manual Validation
    
    @MainActor
    func validateTokenManually(for brand: VehicleBrand) async -> TokenStatus {
        let status = await validateToken(for: brand)
        tokenStatus[brand] = status
        
        if let days = status.daysUntilExpiry, days <= warningDays, days > 0 {
            await sendExpiryNotification(brand: brand, daysRemaining: days)
        }
        
        return status
    }
}
