//
//  Typography.swift
//  hotcar
//
//  HotCar Theme - Typography System
//  Optimized for cold weather visibility and accessibility
//

import SwiftUI

// MARK: - HotCar Font System

extension Font {
    
    // MARK: - Display Fonts (Large, Visible in Cold Weather)
    
    /// Extra large temperature display (64pt)
    /// Use for: Main temperature, countdown timer
    static let hotCarDisplay = Font.system(size: 64, weight: .ultraLight, design: .rounded)
    
    /// Large timer display (48pt)
    /// Use for: Timer countdown, warm-up time
    static let hotCarTimer = Font.system(size: 48, weight: .medium, design: .rounded)
    
    // MARK: - Heading Fonts
    
    /// Large title (34pt)
    /// Use for: Screen titles, main headers
    static let hotCarLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    /// Title (24pt)
    /// Use for: Section headers, card titles
    static let hotCarTitle = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Headline (18pt)
    /// Use for: Subheaders, important labels
    static let hotCarHeadline = Font.system(size: 18, weight: .medium, design: .rounded)
    
    // MARK: - Body Fonts
    
    /// Body text (16pt)
    /// Use for: Main content, descriptions
    static let hotCarBody = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Callout (15pt)
    /// Use for: Secondary information
    static let hotCarCallout = Font.system(size: 15, weight: .regular, design: .default)
    
    // MARK: - Caption Fonts
    
    /// Caption (14pt)
    /// Use for: Labels, hints, metadata
    static let hotCarCaption = Font.system(size: 14, weight: .regular, design: .default)
    
    /// Footnote (13pt)
    /// Use for: Fine print, disclaimers
    static let hotCarFootnote = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: - Button Fonts
    
    /// Button label (17pt)
    /// Use for: Primary action buttons
    static let hotCarButton = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    // MARK: - Number Fonts (Monospaced for Timers)
    
    /// Monospaced digits for timers and counts
    static let hotCarMonospaced = Font.system(
        size: 48,
        weight: .medium,
        design: .default,
        options: .monospacedDigit
    )
}

// MARK: - Line Height Multipliers

extension Font {
    
    /// Tight line height for display text (0.9x)
    func hotCarDisplayLineHeight() -> some View {
        self.lineSpacing(-4)
    }
    
    /// Standard line height for body text (1.2x)
    func hotCarBodyLineHeight() -> some View {
        self.lineSpacing(4)
    }
}

// MARK: - Text Presets

struct HotCarText {
    
    // MARK: - Temperature Display
    
    static func temperature(_ value: Double) -> Text {
        Text(String(format: "%.0f", value))
            .font(.hotCarDisplay)
    }
    
    // MARK: - Timer Display
    
    static func timer(minutes: Int, seconds: Int) -> Text {
        Text(String(format: "%02d:%02d", minutes, seconds))
            .font(.hotCarMonospaced)
    }
    
    // MARK: - Screen Title
    
    static func screenTitle(_ text: String) -> Text {
        Text(text)
            .font(.hotCarLargeTitle)
    }
    
    // MARK: - Card Title
    
    static func cardTitle(_ text: String) -> Text {
        Text(text)
            .font(.hotCarTitle)
    }
    
    // MARK: - Button Label
    
    static func buttonLabel(_ text: String) -> Text {
        Text(text)
            .font(.hotCarButton)
    }
}
