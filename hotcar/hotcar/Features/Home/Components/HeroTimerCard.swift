//
//  HeroTimerCard.swift
//  hotcar
//
//  HotCar Home - Hero Timer Card Component
//  Core warm-up timer display and control
//  Optimized for US/Canada/Nordic markets with English localization
//

import SwiftUI

// MARK: - Hero Timer Card

/// Core timer card component
/// Responsibility: Display recommended warm-up time and provide start/stop control
struct HeroTimerCard: View {
    
    // MARK: - Properties
    
    let recommendedMinutes: Int
    let isRunning: Bool
    let progress: Double
    let remainingSeconds: Int
    let vehicleName: String
    let temperatureStatus: TemperatureStatus
    
    let onStart: () -> Void
    let onStop: () -> Void
    let onAdjustTime: (Int) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: HotCarSpacing.large) {
            // Top: Status indicator
            statusHeader
            
            // Middle: Time display (core)
            timeDisplay
            
            // Bottom: Control section
            controlSection
        }
        .padding(HotCarSpacing.large)
        .background(cardBackground)
        .cornerRadius(HotCarRadius.maximum)
        .shadow(color: shadowColor, radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Status Header
    
    private var statusHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: temperatureStatus.icon)
                    .font(.system(size: 14))
                    .foregroundColor(temperatureStatus.color)
                
                Text(temperatureStatus.displayText)
                    .font(.hotCarCaption)
                    .foregroundColor(temperatureStatus.color)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "car.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
                
                Text(vehicleName)
                    .font(.hotCarCaption)
                    .foregroundColor(.textMuted)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Time Display
    
    private var timeDisplay: some View {
        VStack(spacing: HotCarSpacing.small) {
            if isRunning {
                // Countdown mode
                Text(formattedRemainingTime)
                    .font(.hotCarTimer)
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.textMuted.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)
                
                Text(NSLocalizedString("timer_warming_up", tableName: "Localizable", comment: "Status text shown when timer is running"))
                    .font(.hotCarCaption)
                    .foregroundColor(.warmUpActive)
            } else {
                // Recommended time mode
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(recommendedMinutes)")
                        .font(.hotCarDisplay)
                        .foregroundColor(.textPrimary)
                    
                    Text(NSLocalizedString("time_unit_min", tableName: "Localizable", comment: "Time unit abbreviation for minutes"))
                        .font(.hotCarTitle)
                        .foregroundColor(.textSecondary)
                }
                
                Text(NSLocalizedString("recommended_warmup", tableName: "Localizable", comment: "Label for recommended warm-up time display"))
                    .font(.hotCarCaption)
                    .foregroundColor(.textMuted)
            }
        }
    }
    
    private var formattedRemainingTime: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private var progressColor: Color {
        if progress < 0.3 {
            return .warmUpReady
        } else if progress < 0.7 {
            return .warmUpActive
        } else {
            return .warmUpComplete
        }
    }
    
    // MARK: - Control Section
    
    private var controlSection: some View {
        VStack(spacing: HotCarSpacing.medium) {
            // Main button
            Button(action: isRunning ? onStop : onStart) {
                HStack(spacing: 8) {
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    Text(isRunning 
                        ? NSLocalizedString("button_stop", tableName: "Localizable", comment: "Button label to stop the timer")
                        : NSLocalizedString("button_start_warmup", tableName: "Localizable", comment: "Button label to start engine warm-up")
                    )
                }
                .font(.hotCarButton)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HotCarSpacing.medium)
                .background(isRunning ? Color.warmUpActive : Color.hotCarPrimary)
                .cornerRadius(HotCarRadius.large)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Time adjustment (always visible)
            HStack(spacing: HotCarSpacing.large) {
                Button(action: { onAdjustTime(-1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.textSecondary)
                }
                .disabled(isRunning)
                .opacity(isRunning ? 0.5 : 1)
                
                Text("\(recommendedMinutes) \(NSLocalizedString("time_unit_min_short", tableName: "Localizable", comment: "Short time unit for minutes in time adjuster"))")
                    .font(.hotCarHeadline)
                    .foregroundColor(.textSecondary)
                    .frame(minWidth: 80)
                
                Button(action: { onAdjustTime(1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.textSecondary)
                }
                .disabled(isRunning)
                .opacity(isRunning ? 0.5 : 1)
            }
        }
    }
    
    // MARK: - Styling
    
    private var cardBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.backgroundSecondary,
                Color.backgroundCard
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var shadowColor: Color {
        isRunning ? Color.warmUpActive.opacity(0.3) : Color.black.opacity(0.3)
    }
}

// MARK: - Preview

#Preview("Idle State") {
    HeroTimerCard(
        recommendedMinutes: 12,
        isRunning: false,
        progress: 0,
        remainingSeconds: 0,
        vehicleName: "Ford F-150",
        temperatureStatus: .veryCold,
        onStart: {},
        onStop: {},
        onAdjustTime: { _ in }
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Running State") {
    HeroTimerCard(
        recommendedMinutes: 12,
        isRunning: true,
        progress: 0.45,
        remainingSeconds: 420,
        vehicleName: "Ford F-150",
        temperatureStatus: .veryCold,
        onStart: {},
        onStop: {},
        onAdjustTime: { _ in }
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Extreme Cold") {
    HeroTimerCard(
        recommendedMinutes: 20,
        isRunning: false,
        progress: 0,
        remainingSeconds: 0,
        vehicleName: "Chevrolet Silverado",
        temperatureStatus: .extreme,
        onStart: {},
        onStop: {},
        onAdjustTime: { _ in }
    )
    .padding()
    .background(Color.backgroundPrimary)
}
