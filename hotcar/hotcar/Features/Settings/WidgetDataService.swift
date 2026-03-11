//
//  WidgetDataService.swift
//  hotcar
//
//  HotCar Service - Widget Data Sharing
//  Shares data between main app and widgets via App Groups
//

import Foundation
import WidgetKit

final class WidgetDataService {
    
    // MARK: - Singleton
    
    static let shared = WidgetDataService()
    
    // MARK: - Properties
    
    private let sharedDefaults: UserDefaults?
    
    // MARK: - Initialization
    
    private init() {
        // Initialize with App Group suite name
        self.sharedDefaults = UserDefaults(suiteName: "group.com.zzoutuo.hotcar")
    }
    
    // MARK: - Public Methods
    
    /// Update widget data from main app
    func updateWidgetData(
        timerRunning: Bool? = nil,
        timerRemaining: Int? = nil,
        vehicleName: String? = nil,
        outsideTemp: Double? = nil,
        feelsLike: Double? = nil,
        condition: String? = nil,
        location: String? = nil,
        recommendedTime: Int? = nil
    ) {
        // Timer data
        if let timerRunning = timerRunning {
            sharedDefaults?.set(timerRunning, forKey: "widget_timer_running")
        }
        
        if let timerRemaining = timerRemaining {
            sharedDefaults?.set(timerRemaining, forKey: "widget_timer_remaining")
        }
        
        if let vehicleName = vehicleName {
            sharedDefaults?.set(vehicleName, forKey: "widget_vehicle_name")
        }
        
        if let recommendedTime = recommendedTime {
            sharedDefaults?.set(recommendedTime, forKey: "widget_recommended_time")
        }
        
        // Weather data
        if let outsideTemp = outsideTemp {
            sharedDefaults?.set(outsideTemp, forKey: "widget_outside_temp")
        }
        
        if let feelsLike = feelsLike {
            sharedDefaults?.set(feelsLike, forKey: "widget_feels_like")
        }
        
        if let condition = condition {
            sharedDefaults?.set(condition, forKey: "widget_condition")
        }
        
        if let location = location {
            sharedDefaults?.set(location, forKey: "widget_location")
        }
        
        // Force sync
        sharedDefaults?.synchronize()
    }
    
    /// Clear all widget data
    func clearWidgetData() {
        let keys = [
            "widget_timer_running",
            "widget_timer_remaining",
            "widget_vehicle_name",
            "widget_outside_temp",
            "widget_feels_like",
            "widget_condition",
            "widget_location",
            "widget_recommended_time"
        ]
        
        for key in keys {
            sharedDefaults?.removeObject(forKey: key)
        }
        
        sharedDefaults?.synchronize()
    }
    
    /// Reload widgets
    func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "WarmUpTimerWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "TemperatureWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "QuickStartWidget")
        #endif
    }
}

// MARK: - Widget Data Update Helpers

extension WidgetDataService {
    
    /// Update timer state
    func updateTimerState(isRunning: Bool, remaining: Int, vehicleName: String) {
        updateWidgetData(
            timerRunning: isRunning,
            timerRemaining: remaining,
            vehicleName: vehicleName
        )
        reloadWidgets()
    }
    
    /// Update weather data
    func updateWeatherData(
        outsideTemp: Double,
        feelsLike: Double,
        condition: String,
        location: String
    ) {
        updateWidgetData(
            outsideTemp: outsideTemp,
            feelsLike: feelsLike,
            condition: condition,
            location: location
        )
        reloadWidgets()
    }
    
    /// Update recommended warm-up time
    func updateRecommendedTime(_ minutes: Int) {
        updateWidgetData(recommendedTime: minutes)
        reloadWidgets()
    }
}
