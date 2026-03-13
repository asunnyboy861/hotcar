//
//  ColorPalette.swift
//  hotcar
//
//  HotCar Theme - Color System (Refactored)
//  Following Apple HIG and 2026 mobile design trends
//  Optimized for US market with improved contrast and brand identity
//

import SwiftUI

// MARK: - Extension for HotCar Colors

extension Color {
    
    // MARK: - Primary Brand Colors
    
    /// Refreshed: Warmer blue - primary brand color
    /// Rationale: Original blue (#007AFF) matched system blue, lacking brand identity
    static let hotCarPrimary = Color(red: 0.0, green: 0.58, blue: 1.0)  // #0094FF
    
    /// Warm orange - secondary/accent color
    static let hotCarSecondary = Color(red: 1.0, green: 0.65, blue: 0.0)  // #FFA600
    
    // MARK: - Semantic Colors (Warm-Up States)
    
    /// Red - active/warning state
    static let warmUpActive = Color(red: 1.0, green: 0.35, blue: 0.35)
    
    /// Green - ready/success state
    static let warmUpReady = Color(red: 0.25, green: 0.85, blue: 0.25)
    
    /// Yellow - waiting/pending state
    static let warmUpWaiting = Color(red: 1.0, green: 0.85, blue: 0.0)
    
    /// Blue - complete/success state
    static let warmUpComplete = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    // MARK: - Background Colors (Dark Mode First - Improved Contrast)
    
    /// Primary background - Pure black base (OLED optimized)
    /// Rationale: Original had blue tint conflicting with primary color
    static let backgroundPrimary = Color(red: 0.0, green: 0.0, blue: 0.0)
    
    /// Secondary background - Cards/sections background
    /// Rationale: Increased contrast from primary (0.05 -> 0.08 RGB difference)
    static let backgroundSecondary = Color(red: 0.08, green: 0.08, blue: 0.08)
    
    /// Card background - Floating surfaces
    /// Rationale: Better distinction from secondary background
    static let backgroundCard = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    /// Elevated surfaces - Buttons/interactive elements
    static let backgroundElevated = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    // MARK: - Text Colors (Improved Contrast)
    
    /// Primary text - High emphasis
    static let textPrimary = Color(red: 1.0, green: 1.0, blue: 1.0)
    
    /// Secondary text - Medium emphasis
    /// Rationale: Increased brightness for better readability
    static let textSecondary = Color(red: 0.85, green: 0.85, blue: 0.85)
    
    /// Muted text - Low emphasis
    /// Rationale: Increased brightness for visibility in dark mode
    static let textMuted = Color(red: 0.65, green: 0.65, blue: 0.65)
    
    // MARK: - Temperature-Based Colors
    
    /// Extreme cold indicator (< -30°F)
    static let tempExtreme = Color(red: 0.7, green: 0.2, blue: 0.9)
    
    /// Very cold indicator (-20°F to -30°F)
    static let tempVeryCold = Color(red: 0.2, green: 0.7, blue: 1.0)
    
    /// Cold indicator (-10°F to -20°F)
    static let tempCold = Color(red: 0.4, green: 0.75, blue: 1.0)
    
    /// Mild indicator (0°F to -10°F)
    static let tempMild = Color(red: 0.65, green: 0.85, blue: 1.0)
    
    /// Warm indicator (> 0°F)
    static let tempWarm = Color(red: 0.8, green: 0.9, blue: 1.0)
}

// MARK: - Gradient Presets

extension Gradient {
    
    /// Primary brand gradient (refreshed: warmer blue to cyan)
    static let hotCarPrimary = Gradient(colors: [
        Color.hotCarPrimary,
        Color(red: 0.0, green: 0.75, blue: 1.0)
    ])
    
    /// Warm-up active gradient (red to orange)
    static let warmUpActive = Gradient(colors: [
        Color.warmUpActive,
        Color(red: 1.0, green: 0.55, blue: 0.0)
    ])
    
    /// Temperature cold gradient
    static let tempCold = Gradient(colors: [
        Color.tempVeryCold,
        Color.tempCold
    ])
    
    /// Card background gradient (subtle depth)
    static let cardBackground = Gradient(colors: [
        Color.backgroundCard,
        Color.backgroundSecondary
    ])
}

// MARK: - Shadow Presets (Multi-level System)

struct HotCarShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    
    // MARK: - Card Shadows
    
    /// Card shadow - Light elevation
    static let cardLight = HotCarShadow(
        color: Color.black,
        radius: 8,
        x: 0,
        y: 2,
        opacity: 0.15
    )
    
    /// Card shadow - Medium elevation
    static let cardMedium = HotCarShadow(
        color: Color.black,
        radius: 16,
        x: 0,
        y: 4,
        opacity: 0.2
    )
    
    /// Card shadow - Deep elevation
    static let cardDeep = HotCarShadow(
        color: Color.black,
        radius: 24,
        x: 0,
        y: 8,
        opacity: 0.25
    )
    
    // MARK: - Button Shadows
    
    /// Button shadow - Default state
    static let buttonDefault = HotCarShadow(
        color: Color.hotCarPrimary,
        radius: 8,
        x: 0,
        y: 2,
        opacity: 0.3
    )
    
    /// Button shadow - Hover/pressed state
    static let buttonPressed = HotCarShadow(
        color: Color.hotCarPrimary,
        radius: 12,
        x: 0,
        y: 4,
        opacity: 0.4
    )
    
    /// Button shadow - Active state
    static let buttonActive = HotCarShadow(
        color: Color.warmUpActive,
        radius: 16,
        x: 0,
        y: 6,
        opacity: 0.5
    )
    
    // MARK: - Modal/Popup Shadows
    
    static let modal = HotCarShadow(
        color: Color.black,
        radius: 32,
        x: 0,
        y: 16,
        opacity: 0.3
    )
}

// MARK: - Border Presets

struct HotCarBorder {
    let color: Color
    let width: CGFloat
    
    /// Card border - Subtle divider
    static let cardSubtle = HotCarBorder(
        color: Color.textMuted.opacity(0.1),
        width: 0.5
    )
    
    /// Card border - Defined divider
    static let cardDefined = HotCarBorder(
        color: Color.textSecondary.opacity(0.15),
        width: 1
    )
    
    /// Input border
    static let input = HotCarBorder(
        color: Color.textMuted.opacity(0.3),
        width: 1
    )
    
    /// Selected state border
    static let selected = HotCarBorder(
        color: Color.hotCarPrimary,
        width: 2
    )
}