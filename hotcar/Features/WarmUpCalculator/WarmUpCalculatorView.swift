//
//  WarmUpCalculatorView.swift
//  hotcar
//
//  HotCar Feature - Warm-Up Calculator View
//  Main interface for calculating and tracking warm-up time
//

import SwiftUI

struct WarmUpCalculatorView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = WarmUpCalculatorViewModel()
    @State private var showingVehicleSelector = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24) {
            // Current Temperature Display
            temperatureSection
            
            // Warm-Up Time Display
            warmUpTimeSection
            
            // Action Buttons
            actionButtons
            
            // Progress and Advice
            if viewModel.isTimerRunning {
                progressSection
            }
            
            // Advice Card
            adviceSection
        }
        .padding(.horizontal, .hotCarSpacingLg)
        .padding(.vertical, .hotCarSpacingMd)
        .background(Color.backgroundPrimary)
    }
    
    // MARK: - Temperature Section
    
    private var temperatureSection: some View {
        VStack(spacing: 8) {
            if let temperature = viewModel.currentTemperature {
                TemperatureDisplay(
                    temperature: temperature,
                    showUnit: true,
                    size: .large
                )
                
                HStack(spacing: 16) {
                    Label(
                        viewModel.locationName,
                        systemImage: "location.fill"
                    )
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                    
                    if let vehicle = viewModel.selectedVehicle {
                        Label(
                            vehicle.name,
                            systemImage: vehicle.type.icon
                        )
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .hotCarPrimary))
            }
        }
    }
    
    // MARK: - Warm-Up Time Section
    
    private var warmUpTimeSection: some View {
        VStack(spacing: 16) {
            Text("Recommended Warm-Up Time")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            // Large Timer Display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%02d", viewModel.calculatedMinutes))
                    .font(.hotCarMonospaced)
                    .foregroundColor(viewModel.isTimerRunning ? .warmUpActive : .hotCarPrimary)
                
                Text(":")
                    .font(.hotCarMonospaced)
                    .foregroundColor(.textSecondary)
                
                Text(String(format: "%02d", viewModel.calculatedSeconds))
                    .font(.hotCarMonospaced)
                    .foregroundColor(viewModel.isTimerRunning ? .warmUpActive : .hotCarPrimary)
            }
            
            // Start/Stop Button
            Button(action: {
                viewModel.toggleTimer()
            }) {
                Text(viewModel.isTimerRunning ? "Stop Timer" : "Start Warm-Up")
                    .font(.hotCarButton)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        viewModel.isTimerRunning ? Color.warmUpActive : Color.hotCarPrimary
                    )
                    .cornerRadius(.hotCarRadiusLg)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel.selectedVehicle == nil)
        }
        .padding(.card)
        .background(Color.backgroundSecondary)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Select Vehicle Button
            Button(action: { showingVehicleSelector = true }) {
                HStack {
                    Image(systemName: "car.fill")
                    Text("Select Vehicle")
                }
                .font(.hotCarButton)
                .foregroundColor(.hotCarPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.backgroundCard)
                .cornerRadius(.hotCarRadiusMd)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Quick Adjust Button
            Menu {
                Button(action: { viewModel.adjustTime(by: -5) }) {
                    Label("Subtract 5 min", systemImage: "minus.circle")
                }
                
                Button(action: { viewModel.adjustTime(by: 5) }) {
                    Label("Add 5 min", systemImage: "plus.circle")
                }
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Adjust")
                }
                .font(.hotCarButton)
                .foregroundColor(.hotCarSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.backgroundCard)
                .cornerRadius(.hotCarRadiusMd)
            }
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.backgroundCard)
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Gradient.warmUpActive)
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                }
            }
            .frame(height: 8)
            
            // Time Remaining
            HStack {
                Text("Time Remaining")
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text("\(viewModel.timeRemainingMinutes):\(String(format: "%02d", viewModel.timeRemainingSeconds))")
                    .font(.hotCarHeadline)
                    .foregroundColor(.warmUpActive)
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    // MARK: - Advice Section
    
    private var adviceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.hotCarSecondary)
                Text("Warm-Up Tips")
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
            }
            
            if let advice = viewModel.warmUpAdvice {
                Text(advice)
                    .font(.hotCarBody)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
}

// MARK: - Preview

#Preview {
    WarmUpCalculatorView()
}
