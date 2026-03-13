//
//  TimerButton.swift
//  hotcar
//
//  HotCar UI Component - Timer Button (Refactored)
//  Large, glove-friendly button for cold weather use
//  Updated with new design system and improved visual hierarchy
//

import SwiftUI

struct TimerButton: View {
    
    // MARK: - Properties
    
    let minutes: Int
    let isActive: Bool
    let isPaused: Bool
    let progress: Double
    let remainingSeconds: Int
    let action: () -> Void
    
    init(
        minutes: Int,
        isActive: Bool = false,
        isPaused: Bool = false,
        progress: Double = 0.0,
        remainingSeconds: Int = 0,
        action: @escaping () -> Void
    ) {
        self.minutes = minutes
        self.isActive = isActive
        self.isPaused = isPaused
        self.progress = progress
        self.remainingSeconds = remainingSeconds
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: HotCarSpacing.mediumLarge) {
                progressRingOverlay
                
                timeText
                
                statusText
            }
            .frame(maxWidth: .infinity)
            .frame(height: HotCarLayout.buttonHeight * 3.2)
            .background(buttonBackground)
            .foregroundColor(.textPrimary)
            .cornerRadius(HotCarRadius.maximum)
            .shadow(color: shadowColor, radius: 16, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: HotCarRadius.maximum)
                    .stroke(
                        Color.white.opacity(isActive ? 0.2 : 0.1),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isActive ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Time Display
    
    private var timeText: some View {
        Text(displayTime)
            .font(.hotCarTimer)
            .fontWeight(.semibold)
    }
    
    private var displayTime: String {
        if isActive && remainingSeconds > 0 {
            let mins = remainingSeconds / 60
            let secs = remainingSeconds % 60
            return String(format: "%02d:%02d", mins, secs)
        } else {
            return "\(minutes) min"
        }
    }
    
    // MARK: - Status Text
    
    private var statusText: some View {
        Text(statusLabel)
            .font(.hotCarHeadline)
            .fontWeight(.semibold)
            .foregroundColor(.textSecondary)
    }
    
    private var statusLabel: String {
        if isActive {
            return isPaused ? "Paused" : "Warming Up..."
        } else {
            return "Start Engine"
        }
    }
    
    // MARK: - Progress Ring Overlay
    
    private var progressRingOverlay: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.textSecondary.opacity(0.15), lineWidth: 6)
                .frame(width: 120, height: 120)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: isActive ? progress : 0)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
            
            // Center icon
            if isActive {
                VStack(spacing: 6) {
                    Image(systemName: isPaused ? "pause.fill" : "flame.fill")
                        .font(.system(size: 28, weight: .semibold))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
            } else {
                Image(systemName: "power")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(height: 80)
    }
    
    // MARK: - Button Background
    
    private var buttonBackground: some View {
        Group {
            if isActive {
                LinearGradient(
                    gradient: .warmUpActive,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    gradient: .hotCarPrimary,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    // MARK: - Shadow Color
    
    private var shadowColor: Color {
        isActive ? 
            Color.warmUpActive.opacity(0.4) : 
            Color.hotCarPrimary.opacity(0.35)
    }
}

// MARK: - Preview

#Preview("Inactive") {
    TimerButton(minutes: 12, isActive: false) {}
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Active") {
    TimerButton(
        minutes: 12,
        isActive: true,
        progress: 0.35,
        remainingSeconds: 420
    ) {}
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Paused") {
    TimerButton(
        minutes: 12,
        isActive: true,
        isPaused: true,
        progress: 0.5,
        remainingSeconds: 360
    ) {}
        .padding()
        .background(Color.backgroundPrimary)
}