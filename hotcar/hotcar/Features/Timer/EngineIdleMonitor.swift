//
//  EngineIdleMonitor.swift
//  hotcar
//
//  HotCar Monitor - Engine Idle Detection
//  Monitors for forgotten engine shutdown and excessive idling
//

import Foundation
import Combine
import CoreLocation
import UserNotifications

@MainActor
final class EngineIdleMonitor: ObservableObject {
    
    static let shared = EngineIdleMonitor()
    
    @Published var isMonitoring: Bool = false
    @Published var isEngineRunning: Bool = false
    @Published var idleDuration: Int = 0
    @Published var currentIdleSeconds: Int = 0
    @Published var hasSentWarning: Bool = false
    
    private let notificationService = NotificationService.shared
    private let statisticsService = StatisticsService.shared
    private let locationService = LocationService.shared
    private var idleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        isEngineRunning = false
        idleDuration = 0
        currentIdleSeconds = 0
        hasSentWarning = false
        
        startIdleDetection()
    }
    
    func stopMonitoring() {
        isMonitoring = false
        idleTimer?.invalidate()
        idleTimer = nil
        isEngineRunning = false
    }
    
    func markEngineStarted() {
        isEngineRunning = true
        currentIdleSeconds = 0
        hasSentWarning = false
        startIdleTimer()
    }
    
    func markEngineStopped() {
        isEngineRunning = false
        idleTimer?.invalidate()
        idleTimer = nil
        
        if currentIdleSeconds > 60 {
            Task {
                await recordIdleWaste()
            }
        }
    }
    
    private func startIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                await self?.tick()
            }
        }
    }
    
    private func tick() async {
        guard isEngineRunning else { return }
        
        currentIdleSeconds += 1
        
        if currentIdleSeconds == 300 {
            await sendLevel1Warning()
        } else if currentIdleSeconds == 600 {
            await sendLevel2Warning()
        } else if currentIdleSeconds == 900 {
            await sendLevel3Warning()
        }
    }
    
    private func sendLevel1Warning() async {
        guard !hasSentWarning else { return }
        hasSentWarning = true
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Engine Idling"
        content.body = "Your engine has been idling for 5 minutes. Consider turning it off if not needed."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "idle_warning_level1_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending idle warning: \(error)")
        }
    }
    
    private func sendLevel2Warning() async {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Excessive Idling"
        content.body = "Your engine has been idling for 10 minutes. This wastes fuel and increases emissions."
        content.sound = .defaultCritical
        
        let request = UNNotificationRequest(
            identifier: "idle_warning_level2_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending idle warning: \(error)")
        }
    }
    
    private func sendLevel3Warning() async {
        let content = UNMutableNotificationContent()
        content.title = "🛑 Stop Idling Now"
        content.body = "Your engine has been idling for 15 minutes. Please turn off your engine to save fuel and reduce emissions."
        content.sound = .defaultCritical
        
        let request = UNNotificationRequest(
            identifier: "idle_warning_level3_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending idle warning: \(error)")
        }
    }
    
    private func recordIdleWaste() async {
        let sessionId = UUID().uuidString
        await statisticsService.recordIdleWaste(
            sessionId: sessionId,
            idleSeconds: currentIdleSeconds
        )
    }
    
    private func startIdleDetection() {
        locationService.$currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                if let _ = location {
                    self?.detectEngineState()
                }
            }
            .store(in: &cancellables)
    }
    
    private func detectEngineState() {
    }
}
