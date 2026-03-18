//
//  HotCarApp.swift
//  hotcar
//
//  HotCar Application Entry Point
//

import SwiftUI
import UserNotifications

@main
struct HotCarApp: App {
    
    @StateObject private var locationService = LocationService.shared
    
    init() {
        // Clear old location cache on app launch to ensure fresh location
        LocationService.shared.clearCache()
        
        // Setup notification delegate
        setupNotificationDelegate()
        
        // Request location permission on app launch
        requestLocationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationService)
        }
    }
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    private func requestLocationPermission() {
        // Delay slightly to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LocationService.shared.requestPermission()
        }
    }
}

// MARK: - Notification Delegate

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        let actionIdentifier = response.actionIdentifier
        handleNotificationAction(actionIdentifier, userInfo: userInfo)
        
        completionHandler()
    }
    
    private func handleNotificationAction(_ action: String, userInfo: [AnyHashable: Any]) {
        switch action {
        case "START_TIMER":
            if let warmUpTime = userInfo["warmUpTime"] as? Int {
                Task { @MainActor in
                    CountdownTimer.shared.start(minutes: warmUpTime)
                }
            }
            
        case "SNOOZE_5":
            break
            
        case "STOP_TIMER":
            Task { @MainActor in
                CountdownTimer.shared.stop()
            }
            
        default:
            break
        }
    }
}
