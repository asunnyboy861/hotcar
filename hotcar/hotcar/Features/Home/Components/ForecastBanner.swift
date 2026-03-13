//
//  ForecastBanner.swift
//  hotcar
//
//  HotCar Home - Forecast Banner Component
//  Tomorrow morning forecast and warm-up recommendation
//  Optimized for US/Canada/Nordic markets with English localization
//

import SwiftUI

// MARK: - Forecast Banner

/// Forecast banner component
/// Responsibility: Display tomorrow morning forecast and warm-up recommendation
struct ForecastBanner: View {
    
    // MARK: - Properties
    
    let tomorrowTemperature: Double
    let recommendedMinutes: Int
    let unit: AppSettings.TemperatureUnit
    let onSetReminder: () -> Void
    
    // MARK: - Computed Properties
    
    private var displayTemp: String {
        unit.format(tomorrowTemperature)
    }
    
    private var status: TemperatureStatus {
        TemperatureStatus.from(celsius: tomorrowTemperature)
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onSetReminder) {
            HStack(spacing: HotCarSpacing.medium) {
                // Icon
                Image(systemName: "sunrise.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.hotCarSecondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("forecast_tomorrow_morning", tableName: "Localizable", comment: "Forecast section title for tomorrow morning"))
                        .font(.hotCarCaption)
                        .foregroundColor(.textMuted)
                    
                    HStack(spacing: 8) {
                        Text(displayTemp)
                            .font(.hotCarHeadline)
                            .foregroundColor(status.color)
                        
                        Text("• \(NSLocalizedString("forecast_warmup", tableName: "Localizable", comment: "Forecast warm-up recommendation label")) \(recommendedMinutes) \(NSLocalizedString("time_unit_min", tableName: "Localizable", comment: "Time unit abbreviation for minutes"))")
                            .font(.hotCarCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "bell.badge")
                    .font(.system(size: 18))
                    .foregroundColor(.hotCarPrimary)
            }
            .padding(HotCarSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: HotCarRadius.large)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: HotCarRadius.large)
                            .stroke(Color.hotCarSecondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview("Very Cold Morning") {
    ForecastBanner(
        tomorrowTemperature: -28,
        recommendedMinutes: 18,
        unit: .celsius,
        onSetReminder: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Mild Morning") {
    ForecastBanner(
        tomorrowTemperature: -5,
        recommendedMinutes: 8,
        unit: .fahrenheit,
        onSetReminder: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Above Freezing") {
    ForecastBanner(
        tomorrowTemperature: 5,
        recommendedMinutes: 5,
        unit: .celsius,
        onSetReminder: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}
