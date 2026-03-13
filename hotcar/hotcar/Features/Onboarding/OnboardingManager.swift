//
//  OnboardingManager.swift
//  hotcar
//
//  HotCar Manager - Onboarding State
//  Tracks first-time user experience completion
//

import Foundation
import Combine

@MainActor
final class OnboardingManager: ObservableObject {
    
    static let shared = OnboardingManager()
    
    @Published var hasCompletedOnboarding: Bool
    @Published var hasAddedVehicle: Bool
    @Published var hasGrantedLocationPermission: Bool
    
    // MARK: - Vehicle Setup Guide State
    
    @Published var hasDismissedVehicleGuide: Bool
    
    private let onboardingKey = "com.hotcar.onboarding.completed"
    private let vehicleAddedKey = "com.hotcar.vehicle.added"
    private let vehicleGuideDismissedKey = "com.hotcar.vehicleGuide.dismissed"
    
    // MARK: - Dependencies
    
    private let vehicleService = VehicleService.shared
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        self.hasAddedVehicle = UserDefaults.standard.bool(forKey: vehicleAddedKey)
        self.hasGrantedLocationPermission = false
        self.hasDismissedVehicleGuide = UserDefaults.standard.bool(forKey: vehicleGuideDismissedKey)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func markVehicleAdded() {
        hasAddedVehicle = true
        UserDefaults.standard.set(true, forKey: vehicleAddedKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        hasAddedVehicle = false
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: vehicleAddedKey)
    }
    
    var needsOnboarding: Bool {
        !hasCompletedOnboarding
    }
    
    var needsVehicleSetup: Bool {
        hasCompletedOnboarding && !hasAddedVehicle
    }
    
    // MARK: - Vehicle Setup Guide
    
    /// Whether to show the vehicle setup guide card
    var shouldShowVehicleGuide: Bool {
        hasCompletedOnboarding &&
        vehicleService.vehicles.isEmpty &&
        !hasDismissedVehicleGuide
    }
    
    func dismissVehicleGuide() {
        hasDismissedVehicleGuide = true
        UserDefaults.standard.set(true, forKey: vehicleGuideDismissedKey)
    }
    
    func resetVehicleGuide() {
        hasDismissedVehicleGuide = false
        UserDefaults.standard.removeObject(forKey: vehicleGuideDismissedKey)
    }
    
    /// Check vehicle status and mark as added if vehicles exist
    func checkAndMarkVehicleAdded() {
        if !vehicleService.vehicles.isEmpty && !hasAddedVehicle {
            markVehicleAdded()
        }
    }
}
