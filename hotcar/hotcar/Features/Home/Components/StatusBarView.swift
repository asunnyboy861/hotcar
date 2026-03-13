//
//  StatusBarView.swift
//  hotcar
//
//  HotCar Home - Status Bar Component
//  Top status bar showing location and temperature
//  Optimized for US/Canada/Nordic markets with English localization
//

import SwiftUI

// MARK: - Status Bar View

/// Top status bar component
/// Responsibility: Display location and temperature status
struct StatusBarView: View {
    
    // MARK: - Properties
    
    let locationName: String
    let temperature: Double              // Internal use Celsius
    let unit: AppSettings.TemperatureUnit  // Reuse existing type
    let isLoading: Bool
    
    // MARK: - Computed Properties
    
    private var displayTemperature: String {
        unit.format(temperature)
    }
    
    private var temperatureStatus: TemperatureStatus {
        TemperatureStatus.from(celsius: temperature)
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: HotCarSpacing.medium) {
            // Location
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                Text(locationName)
                    .font(.hotCarCaption)
            }
            .foregroundColor(.textMuted)
            
            Spacer()
            
            // Temperature
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .textSecondary))
                    .scaleEffect(0.8)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: temperatureStatus.icon)
                        .font(.system(size: 14))
                        .foregroundColor(temperatureStatus.color)
                    
                    Text(displayTemperature)
                        .font(.hotCarHeadline)
                        .foregroundColor(temperatureStatus.color)
                }
            }
        }
        .padding(.horizontal, HotCarSpacing.medium)
        .padding(.vertical, HotCarSpacing.small)
        .background(Color.backgroundSecondary.opacity(0.5))
        .cornerRadius(HotCarRadius.medium)
    }
}

// MARK: - Preview

#Preview("Toronto Cold") {
    StatusBarView(
        locationName: "Toronto, ON",
        temperature: -25,
        unit: .celsius,
        isLoading: false
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Minneapolis Very Cold") {
    StatusBarView(
        locationName: "Minneapolis, MN",
        temperature: -28,
        unit: .fahrenheit,
        isLoading: false
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Loading") {
    StatusBarView(
        locationName: "Locating...",
        temperature: 0,
        unit: .celsius,
        isLoading: true
    )
    .padding()
    .background(Color.backgroundPrimary)
}
