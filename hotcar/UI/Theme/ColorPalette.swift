//
//  ColorPalette.swift
//  hotcar
//
//  HotCar Theme - Color System
//  Following Apple HIG and 2026 mobile design trends
//

import SwiftUI

// MARK: - Extension for HotCar Colors

extension Color {
    
    // MARK: - Primary Brand Colors
    
    /// Vibrant blue - primary action color
    static let hotCarPrimary = Color(red: 0.0, green: 0.48, blue: 1.0)
    
    /// Warm orange - secondary/highlight color
    static let hotCarSecondary = Color(red: 1.0, green: 0.59, blue: 0.0)
    
    // MARK: - Semantic Colors (Warm-Up States)
    
    /// Red - active/warning state
    static let warmUpActive = Color(red: 1.0, green: 0.28, blue: 0.28)
    
    /// Green - ready/success state
    static let warmUpReady = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    /// Yellow - waiting/pending state
    static let warmUpWaiting = Color(red: 1.0, green: 0.8, blue: 0.0)
    
    // MARK: - Background Colors (Dark Mode First)
    
    /// Primary background - deepest level
    static let backgroundPrimary = Color(red: 0.05, green: 0.05, blue: 0.1)
    
    /// Secondary background - cards, sections
    static let backgroundSecondary = Color(red: 0.1, green: 0.1, blue: 0.15)
    
    /// Card background - elevated surfaces
    static let backgroundCard = Color(red: 0.15, green: 0.15, blue: 0.2)
    
    // MARK: - Text Colors
    
    /// Primary text - high emphasis
    static let textPrimary = Color.white
    
    /// Secondary text - medium emphasis
    static let textSecondary = Color(red: 0.8, green: 0.8, blue: 0.8)
    
    /// Muted text - low emphasis, captions
    static let textMuted = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    // MARK: - Temperature-Based Colors
    
    /// Extreme cold indicator (< -30°C)
    static let tempExtreme = Color(red: 0.6, green: 0.2, blue: 0.8)
    
    /// Very cold indicator (-20°C to -30°C)
    static let tempVeryCold = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    /// Cold indicator (-10°C to -20°C)
    static let tempCold = Color(red: 0.4, green: 0.7, blue: 1.0)
    
    /// Mild indicator (0°C to -10°C)
    static let tempMild = Color(red: 0.6, green: 0.8, blue: 1.0)
}

// MARK: - Gradient Presets

extension Gradient {
    
    /// Primary brand gradient (blue to lighter blue)
    static let hotCarPrimary = Gradient(colors: [
        Color.hotCarPrimary,
        Color(red: 0.2, green: 0.6, blue: 1.0)
    ])
    
    /// Warm-up active gradient (red to orange)
    static let warmUpActive = Gradient(colors: [
        Color.warmUpActive,
        Color(red: 1.0, green: 0.5, blue: 0.0)
    ])
    
    /// Temperature cold gradient
    static let tempCold = Gradient(colors: [
        Color.tempVeryCold,
        Color.tempCold
    ])
}

// MARK: - Shadow Presets

extension Shadow {
    
    /// Standard card shadow for dark mode
    static let cardDark = Shadow(
        color: Color.black.opacity(0.3),
        radius: 10,
        x: 0,
        y: 4
    )
    
    /// Elevated button shadow
    static let buttonElevated = Shadow(
        color: Color.hotCarPrimary.opacity(0.4),
        radius: 8,
        x: 0,
        y: 4
    )
}
