//
//  OnboardingManager.swift
//  hotcar
//
//  HotCar Manager - Onboarding State
//  Tracks first-time user experience completion
//

import Foundation
import Combine

final class OnboardingManager: ObservableObject {
    
    static let shared = OnboardingManager()
    
    @Published var hasCompletedOnboarding: Bool
    @Published var hasAddedVehicle: Bool
    @Published var hasGrantedLocationPermission: Bool
    
    private let onboardingKey = "com.hotcar.onboarding.completed"
    private let vehicleAddedKey = "com.hotcar.vehicle.added"
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        self.hasAddedVehicle = UserDefaults.standard.bool(forKey: vehicleAddedKey)
        self.hasGrantedLocationPermission = false
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
}
