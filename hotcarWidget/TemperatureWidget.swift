//
//  TemperatureWidget.swift
//  hotcarWidget
//
//  HotCar Widget - Current Temperature
//  Shows current outside temperature
//

import WidgetKit
import SwiftUI

struct TemperatureWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let location: String
}

struct TemperatureWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TemperatureWidgetEntry {
        TemperatureWidgetEntry(
            date: Date(),
            temperature: -15.0,
            feelsLike: -22.0,
            condition: "Clear",
            location: "Toronto"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TemperatureWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TemperatureWidgetEntry>) -> Void) {
        // Fetch data from App Group shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.zzoutuo.hotcar")
        
        let temperature = sharedDefaults?.double(forKey: "widget_outside_temp") ?? -15.0
        let feelsLike = sharedDefaults?.double(forKey: "widget_feels_like") ?? -22.0
        let condition = sharedDefaults?.string(forKey: "widget_condition") ?? "Clear"
        let location = sharedDefaults?.string(forKey: "widget_location") ?? "Location"
        
        let entry = TemperatureWidgetEntry(
            date: Date(),
            temperature: temperature != 0 ? temperature : -15.0,
            feelsLike: feelsLike != 0 ? feelsLike : -22.0,
            condition: condition,
            location: location
        )
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TemperatureWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TemperatureWidgetProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallTemperatureWidget(entry: entry)
        case .systemMedium:
            MediumTemperatureWidget(entry: entry)
        default:
            SmallTemperatureWidget(entry: entry)
        }
    }
}

struct SmallTemperatureWidget: View {
    var entry: TemperatureWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Location
            Text(entry.location)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
            
            // Temperature
            VStack(spacing: 2) {
                Text(String(format: "%.0f°", entry.temperature))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Feels like \(String(format: "%.0f°", entry.feelsLike))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Condition
            HStack {
                Image(systemName: conditionIcon(for: entry.condition))
                    .foregroundColor(.white.opacity(0.9))
                Text(entry.condition)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: gradientColors(for: entry.temperature),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func gradientColors(for temperature: Double) -> [Color] {
        if temperature < -20 {
            return [Color(red: 0.1, green: 0.2, blue: 0.4), Color(red: 0.2, green: 0.3, blue: 0.5)]
        } else if temperature < -10 {
            return [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.3, green: 0.4, blue: 0.6)]
        } else if temperature < 0 {
            return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.5, blue: 0.7)]
        } else {
            return [Color.blue, Color.purple]
        }
    }
    
    private func conditionIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear", "sunny":
            return "sun.max.fill"
        case "cloudy":
            return "cloud.fill"
        case "snow", "snowing":
            return "snowflake"
        case "rain", "raining":
            return "cloud.rain.fill"
        default:
            return "thermometer"
        }
    }
}

struct MediumTemperatureWidget: View {
    var entry: TemperatureWidgetProvider.Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Large temperature
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.0f°", entry.temperature))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Feels like \(String(format: "%.0f°", entry.feelsLike))")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Right side - Details
            VStack(alignment: .trailing, spacing: 12) {
                // Condition
                VStack(spacing: 4) {
                    Image(systemName: conditionIcon(for: entry.condition))
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Text(entry.condition)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Location
                VStack(spacing: 2) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(entry.location)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: gradientColors(for: entry.temperature),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func gradientColors(for temperature: Double) -> [Color] {
        if temperature < -20 {
            return [Color(red: 0.1, green: 0.2, blue: 0.4), Color(red: 0.2, green: 0.3, blue: 0.5)]
        } else if temperature < -10 {
            return [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.3, green: 0.4, blue: 0.6)]
        } else if temperature < 0 {
            return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.5, blue: 0.7)]
        } else {
            return [Color.blue, Color.purple]
        }
    }
    
    private func conditionIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear", "sunny":
            return "sun.max.fill"
        case "cloudy":
            return "cloud.fill"
        case "snow", "snowing":
            return "snowflake"
        case "rain", "raining":
            return "cloud.rain.fill"
        default:
            return "thermometer"
        }
    }
}

struct TemperatureWidget: Widget {
    let kind: String = "TemperatureWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TemperatureWidgetProvider()
        ) { entry in
            TemperatureWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Temperature")
        .description("View current outside temperature")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    TemperatureWidget()
} timeline: {
    TemperatureWidgetEntry(
        date: .now,
        temperature: -25.0,
        feelsLike: -32.0,
        condition: "Snow",
        location: "Montreal"
    )
}
