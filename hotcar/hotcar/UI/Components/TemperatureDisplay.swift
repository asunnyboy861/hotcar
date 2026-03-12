//
//  TemperatureDisplay.swift
//  hotcar
//
//  HotCar UI Component - Temperature Display
//  Large, visible temperature display optimized for cold weather
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
        unit: AppSettings.TemperatureUnit = .celsius
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
                .fontWeight(size.fontWeight)
            
            if showUnit {
                Text(unit.symbol)
                    .font(size.unitFont)
                    .foregroundColor(.textMuted)
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
        switch temperature {
        case ..<(-30):
            return "Extreme Cold"
        case -30..<(-20):
            return "Very Cold"
        case -20..<(-10):
            return "Cold"
        case -10..<0:
            return "Below Freezing"
        default:
            return "Above Freezing"
        }
    }
    
    private var temperatureColor: Color {
        switch temperature {
        case ..<(-30):
            return .tempExtreme
        case -30..<(-20):
            return .tempVeryCold
        case -20..<(-10):
            return .tempCold
        case -10..<0:
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
            return .hotCarTitle
        case .medium:
            return .hotCarTimer
        case .large:
            return .hotCarDisplay
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .small:
            return .semibold
        case .medium, .large:
            return .ultraLight
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
            return 4
        case .medium:
            return 8
        case .large:
            return 12
        }
    }
    
    var unitSpacing: CGFloat {
        switch self {
        case .small:
            return 2
        case .medium:
            return 4
        case .large:
            return 8
        }
    }
}

// MARK: - Preview

#Preview("Large") {
    TemperatureDisplay(temperature: -25, showUnit: true, size: .large)
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Medium") {
    TemperatureDisplay(temperature: -15, showUnit: true, size: .medium)
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Small") {
    TemperatureDisplay(temperature: -5, showUnit: true, size: .small)
        .padding()
        .background(Color.backgroundPrimary)
}
