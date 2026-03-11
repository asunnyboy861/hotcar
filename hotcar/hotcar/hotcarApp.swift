//
//  HotCarApp.swift
//  hotcar
//
//  HotCar Application Entry Point
//

import SwiftUI

@main
struct HotCarApp: App {
    
    @StateObject private var locationService = LocationService.shared
    
    init() {
        // Clear old location cache on app launch to ensure fresh location
        LocationService.shared.clearCache()
        
        // Request location permission on app launch
        requestLocationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationService)
        }
    }
    
    private func requestLocationPermission() {
        // Delay slightly to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LocationService.shared.requestPermission()
        }
    }
}
