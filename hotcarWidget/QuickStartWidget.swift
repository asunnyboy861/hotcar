//
//  QuickStartWidget.swift
//  hotcarWidget
//
//  HotCar Widget - Quick Start
//  Quick access to start warm-up timer
//

import WidgetKit
import SwiftUI

struct QuickStartWidgetEntry: TimelineEntry {
    let date: Date
    let vehicleName: String
    let isTimerRunning: Bool
    let recommendedTime: Int
}

struct QuickStartWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickStartWidgetEntry {
        QuickStartWidgetEntry(
            date: Date(),
            vehicleName: "My Car",
            isTimerRunning: false,
            recommendedTime: 15
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickStartWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickStartWidgetEntry>) -> Void) {
        // Fetch data from App Group shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.zzoutuo.hotcar")
        
        let vehicleName = sharedDefaults?.string(forKey: "widget_vehicle_name") ?? "Vehicle"
        let isTimerRunning = sharedDefaults?.bool(forKey: "widget_timer_running") ?? false
        let recommendedTime = sharedDefaults?.integer(forKey: "widget_recommended_time") ?? 15
        
        let entry = QuickStartWidgetEntry(
            date: Date(),
            vehicleName: vehicleName,
            isTimerRunning: isTimerRunning,
            recommendedTime: recommendedTime != 0 ? recommendedTime : 15
        )
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct QuickStartWidgetEntryView: View {
    var entry: QuickStartWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.white)
                Text("HotCar")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                if entry.isTimerRunning {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            
            // Vehicle name
            Text(entry.vehicleName)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Quick action button
            if entry.isTimerRunning {
                VStack(spacing: 4) {
                    Text("Timer Running")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("Tap to open app")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                VStack(spacing: 8) {
                    Text("Recommended:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.white.opacity(0.9))
                        Text("\(entry.recommendedTime) min")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Tap to start")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.hotCarPrimary, .hotCarSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct QuickStartWidget: Widget {
    let kind: String = "QuickStartWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: QuickStartWidgetProvider()
        ) { entry in
            QuickStartWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Start")
        .description("Quick access to warm-up timer")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    QuickStartWidget()
} timeline: {
    QuickStartWidgetEntry(
        date: .now,
        vehicleName: "Tesla Model 3",
        isTimerRunning: false,
        recommendedTime: 20
    )
    
    QuickStartWidgetEntry(
        date: .now,
        vehicleName: "Ford F-150",
        isTimerRunning: true,
        recommendedTime: 15
    )
}
