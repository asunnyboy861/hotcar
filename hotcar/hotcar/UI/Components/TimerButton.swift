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
    let action: () -> Void
    
    // MARK: - Initialization
    
    init(
        minutes: Int,
        isActive: Bool = false,
        isPaused: Bool = false,
        action: @escaping () -> Void
    ) {
        self.minutes = minutes
        self.isActive = isActive
        self.isPaused = isPaused
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Time Display
                timeText
                
                // Status Text
                statusText
                
                // Optional: Progress Ring (for active state)
                if isActive {
                    progressRing
                }
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
        Text("\(minutes) min")
            .font(.hotCarTimer)
            .fontWeight(.medium)
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
    
    // MARK: - Progress Ring (Placeholder for now)
    
    private var progressRing: some View {
        Circle()
            .stroke(Color.white.opacity(0.3), lineWidth: 4)
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 4)
                    .rotationEffect(.degrees(-90))
            )
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
    TimerButton(minutes: 12, isActive: true) {}
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Paused") {
    TimerButton(minutes: 12, isActive: true, isPaused: true) {}
        .padding()
        .background(Color.backgroundPrimary)
}
