//
//  TemperatureDisplay.swift
//  hotcar
//
//  HotCar UI Component - Temperature Display (Refactored)
//  Large, visible temperature display optimized for cold weather
//  Updated with new design system and US market preferences (Fahrenheit)
//

import SwiftUI

struct TemperatureDisplay: View {
    
    // MARK: - Properties
    
    let temperature: Double
    let showUnit: Bool
    let size: DisplaySize
    let unit: AppSettings.TemperatureUnit
    
    enum DisplaySize {
        case small
        case medium
        case large
    }
    
    // MARK: - Initialization
    
    init(
        temperature: Double,
        showUnit: Bool = true,
        size: DisplaySize = .large,
        unit: AppSettings.TemperatureUnit = .fahrenheit
    ) {
        self.temperature = temperature
        self.showUnit = showUnit
        self.size = size
        self.unit = unit
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: size.spacing) {
            temperatureText
            
            if size != .small {
                conditionText
            }
        }
    }
    
    // MARK: - Temperature Text
    
    private var temperatureText: some View {
        HStack(alignment: .firstTextBaseline, spacing: size.unitSpacing) {
            Text(String(format: "%.0f", displayTemperature))
                .font(size.font)
            
            if showUnit {
                Text("°\(unit.symbol)")
                    .font(size.unitFont)
                    .foregroundColor(.textSecondary)
            }
        }
        .foregroundColor(temperatureColor)
    }
    
    private var displayTemperature: Double {
        unit.convert(from: temperature)
    }
    
    // MARK: - Condition Text
    
    private var conditionText: some View {
        Text(temperatureDescription)
            .font(.hotCarCaption)
            .foregroundColor(.textSecondary)
    }
    
    // MARK: - Helpers
    
    private var temperatureDescription: String {
        // Use Fahrenheit thresholds for US market
        let fahrenheitTemp = unit == .fahrenheit ? temperature : (temperature * 9/5 + 32)
        
        switch fahrenheitTemp {
        case ..<(-22):
            return "Extreme Cold Alert"
        case ..<(-4):
            return "Very Cold Conditions"
        case ..<(14):
            return "Cold Weather"
        case ..<(32):
            return "Below Freezing"
        case ..<(50):
            return "Chilly Morning"
        default:
            return "Above Freezing"
        }
    }
    
    private var temperatureColor: Color {
        // Use Fahrenheit thresholds for US market
        let fahrenheitTemp = unit == .fahrenheit ? temperature : (temperature * 9/5 + 32)
        
        switch fahrenheitTemp {
        case ..<(-22):
            return .tempExtreme
        case ..<(-4):
            return .tempVeryCold
        case ..<(14):
            return .tempCold
        case ..<(32):
            return .tempMild
        default:
            return .hotCarPrimary
        }
    }
}

// MARK: - Size Configuration

extension TemperatureDisplay.DisplaySize {
    
    var font: Font {
        switch self {
        case .small:
            return .hotCarHeadline
        case .medium:
            return .hotCarTitle
        case .large:
            return .hotCarDisplay
        }
    }
    
    var unitFont: Font {
        switch self {
        case .small:
            return .hotCarCaption
        case .medium:
            return .hotCarHeadline
        case .large:
            return .hotCarTitle
        }
    }
    
    var spacing: CGFloat {
        switch self {
        case .small:
            return HotCarSpacing.small
        case .medium:
            return HotCarSpacing.mediumSmall
        case .large:
            return HotCarSpacing.medium
        }
    }
    
    var unitSpacing: CGFloat {
        switch self {
        case .small:
            return HotCarSpacing.tight
        case .medium:
            return HotCarSpacing.small
        case .large:
            return HotCarSpacing.mediumSmall
        }
    }
}

// MARK: - Preview

#Preview("Large") {
    TemperatureDisplay(temperature: 9, showUnit: true, size: .large, unit: .fahrenheit)
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Medium") {
    TemperatureDisplay(temperature: 14, showUnit: true, size: .medium, unit: .fahrenheit)
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Small") {
    TemperatureDisplay(temperature: 32, showUnit: true, size: .small, unit: .fahrenheit)
        .padding()
        .background(Color.backgroundPrimary)
}