//
//  hotcarWidgetLiveActivity.swift
//  hotcarWidget
//
//  HotCar Live Activity - Warm-Up Timer
//  Provides Dynamic Island and Lock Screen live updates
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes (Shared with main app)

struct WarmUpActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: Int
        var totalTime: Int
        var vehicleName: String
        var temperature: Double
        var isPaused: Bool
        var progress: Double {
            guard totalTime > 0 else { return 0 }
            return Double(totalTime - remainingTime) / Double(totalTime)
        }
        
        var formattedTime: String {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var vehicleId: String
    var startTime: Date
}

// MARK: - Live Activity Widget

struct WarmUpLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WarmUpActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.orange)
                        Text(context.state.vehicleName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.formattedTime)
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(.primary)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(value: context.state.progress)
                            .tint(.orange)
                        
                        Text("\(Int(context.state.progress * 100))% complete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text(context.state.formattedTime)
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(.primary)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
            }
            .widgetURL(URL(string: "hotcar://timer"))
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<WarmUpActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.orange)
                
                Text(context.state.vehicleName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(context.state.formattedTime)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * context.state.progress)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text(context.state.isPaused ? "Paused" : "Warming up...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Preview

extension WarmUpActivityAttributes {
    fileprivate static var preview: WarmUpActivityAttributes {
        WarmUpActivityAttributes(
            vehicleId: "preview",
            startTime: Date()
        )
    }
}

extension WarmUpActivityAttributes.ContentState {
    fileprivate static var running: WarmUpActivityAttributes.ContentState {
        WarmUpActivityAttributes.ContentState(
            remainingTime: 300,
            totalTime: 600,
            vehicleName: "My Car",
            temperature: 25.0,
            isPaused: false
        )
    }
    
    fileprivate static var paused: WarmUpActivityAttributes.ContentState {
        WarmUpActivityAttributes.ContentState(
            remainingTime: 180,
            totalTime: 600,
            vehicleName: "My Car",
            temperature: 25.0,
            isPaused: true
        )
    }
}

#Preview("Notification", as: .content, using: WarmUpActivityAttributes.preview) {
    WarmUpLiveActivity()
} contentStates: {
    WarmUpActivityAttributes.ContentState.running
    WarmUpActivityAttributes.ContentState.paused
}
