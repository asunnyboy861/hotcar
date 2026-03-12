//
//  TimerButton.swift
//  hotcar
//
//  HotCar UI Component - Timer Button
//  Large, glove-friendly button for cold weather use
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
            VStack(spacing: 16) {
                progressRingOverlay
                
                timeText
                
                statusText
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(buttonBackground)
            .foregroundColor(.white)
            .cornerRadius(.hotCarRadiusXl)
            .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
            .scaleEffect(isActive ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Time Display
    
    private var timeText: some View {
        Text(displayTime)
            .font(.hotCarTimer)
            .fontWeight(.medium)
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
            .fontWeight(.medium)
    }
    
    private var statusLabel: String {
        if isActive {
            return isPaused ? "Paused" : "Running..."
        } else {
            return "Start Engine"
        }
    }
    
    // MARK: - Progress Ring Overlay
    
    private var progressRingOverlay: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                .frame(width: 140, height: 140)
            
            Circle()
                .trim(from: 0, to: isActive ? progress : 0)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)
            
            if isActive {
                VStack(spacing: 4) {
                    Image(systemName: isPaused ? "pause.fill" : "flame.fill")
                        .font(.system(size: 24))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
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
        isActive ? Color.warmUpActive.opacity(0.5) : Color.hotCarPrimary.opacity(0.4)
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
