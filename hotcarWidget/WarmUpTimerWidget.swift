//
//  WarmUpTimerWidget.swift
//  hotcarWidget
//
//  HotCar Widget - Warm-up Timer
//  Shows current warm-up timer status
//

import WidgetKit
import SwiftUI

struct WarmUpTimerWidgetEntry: TimelineEntry {
    let date: Date
    let isRunning: Bool
    let timeRemaining: Int
    let vehicleName: String
    let outsideTemperature: Double
}

struct WarmUpTimerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WarmUpTimerWidgetEntry {
        WarmUpTimerWidgetEntry(
            date: Date(),
            isRunning: true,
            timeRemaining: 600,
            vehicleName: "My Car",
            outsideTemperature: -15.0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WarmUpTimerWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WarmUpTimerWidgetEntry>) -> Void) {
        // Fetch data from App Group shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.zzoutuo.hotcar")
        
        let isRunning = sharedDefaults?.bool(forKey: "widget_timer_running") ?? false
        let timeRemaining = sharedDefaults?.integer(forKey: "widget_timer_remaining") ?? 0
        let vehicleName = sharedDefaults?.string(forKey: "widget_vehicle_name") ?? "Vehicle"
        let outsideTemperature = sharedDefaults?.double(forKey: "widget_outside_temp") ?? -15.0
        
        let entry = WarmUpTimerWidgetEntry(
            date: Date(),
            isRunning: isRunning,
            timeRemaining: timeRemaining,
            vehicleName: vehicleName,
            outsideTemperature: outsideTemperature
        )
        
        // Update every minute if running
        let updateInterval: TimeInterval = isRunning ? 60 : 3600
        let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(updateInterval), to: Date())!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct WarmUpTimerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WarmUpTimerWidgetProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWarmUpWidget(entry: entry)
        case .systemMedium:
            MediumWarmUpWidget(entry: entry)
        default:
            SmallWarmUpWidget(entry: entry)
        }
    }
}

struct SmallWarmUpWidget: View {
    var entry: WarmUpTimerWidgetProvider.Entry
    
    var minutes: Int {
        entry.timeRemaining / 60
    }
    
    var seconds: Int {
        entry.timeRemaining % 60
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.white)
                Text("HotCar")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            // Timer
            if entry.isRunning {
                VStack(spacing: 4) {
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Remaining")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                VStack(spacing: 4) {
                    Text(String(format: "%.0f°", entry.outsideTemperature))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Outside")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Vehicle name
            Text(entry.vehicleName)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
        }
        .padding()
        .background(
            LinearGradient(
                colors: entry.isRunning ? [.red, .orange] : [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct MediumWarmUpWidget: View {
    var entry: WarmUpTimerWidgetProvider.Entry
    
    var minutes: Int {
        entry.timeRemaining / 60
    }
    
    var seconds: Int {
        entry.timeRemaining % 60
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Icon and status
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "car.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.vehicleName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(entry.isRunning ? "Warming Up" : "Ready")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("HotCar")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Right side - Timer or Temperature
            VStack(alignment: .trailing, spacing: 4) {
                if entry.isRunning {
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Time Remaining")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text(String(format: "%.0f°C", entry.outsideTemperature))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Outside Temp")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: entry.isRunning ? [.red, .orange] : [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct WarmUpTimerWidget: Widget {
    let kind: String = "WarmUpTimerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WarmUpTimerWidgetProvider()
        ) { entry in
            WarmUpTimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Warm-Up Timer")
        .description("View your vehicle's warm-up timer status")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WarmUpTimerWidget()
} timeline: {
    WarmUpTimerWidgetEntry(
        date: .now,
        isRunning: true,
        timeRemaining: 600,
        vehicleName: "Tesla Model 3",
        outsideTemperature: -20.0
    )
}
