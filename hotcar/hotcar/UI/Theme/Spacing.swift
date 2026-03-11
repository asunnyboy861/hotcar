//
//  Spacing.swift
//  hotcar
//
//  HotCar Theme - Spacing System
//  Consistent spacing for cold-weather usability
//

import SwiftUI

// MARK: - Spacing Values

struct HotCarSpacing {
    
    /// Extra small: 4pt
    static let xs: CGFloat = 4
    
    /// Small: 8pt
    static let sm: CGFloat = 8
    
    /// Medium: 16pt
    static let md: CGFloat = 16
    
    /// Large: 24pt
    static let lg: CGFloat = 24
    
    /// Extra large: 32pt
    static let xl: CGFloat = 32
    
    /// Double extra large: 48pt
    static let xxl: CGFloat = 48
}

// MARK: - EdgeInsets Presets

extension EdgeInsets {
    
    /// Card padding (16pt)
    static let card = EdgeInsets(
        top: .hotCarSpacingMd,
        leading: .hotCarSpacingMd,
        bottom: .hotCarSpacingMd,
        trailing: .hotCarSpacingMd
    )
    
    /// Screen padding (24pt horizontal)
    static let screen = EdgeInsets(
        top: .hotCarSpacingLg,
        leading: .hotCarSpacingLg,
        bottom: .hotCarSpacingLg,
        trailing: .hotCarSpacingLg
    )
    
    /// Button padding (16pt vertical, 32pt horizontal)
    static let button = EdgeInsets(
        top: .hotCarSpacingMd,
        leading: .hotCarSpacingXl,
        bottom: .hotCarSpacingMd,
        trailing: .hotCarSpacingXl
    )
}

// MARK: - CGFloat Extension

extension CGFloat {
    
    static let hotCarSpacingXs: CGFloat = 4
    static let hotCarSpacingSm: CGFloat = 8
    static let hotCarSpacingMd: CGFloat = 16
    static let hotCarSpacingLg: CGFloat = 24
    static let hotCarSpacingXl: CGFloat = 32
    static let hotCarSpacingXxl: CGFloat = 48
}

// MARK: - View Extension for Spacing

extension View {
    
    /// Apply standard card padding
    func hotCarCardPadding() -> some View {
        self.padding(.card)
    }
    
    /// Apply standard screen padding
    func hotCarScreenPadding() -> some View {
        self.padding(.screen)
    }
    
    /// Apply standard button padding
    func hotCarButtonPadding() -> some View {
        self.padding(.button)
    }
}

// MARK: - Corner Radius Presets

extension CGFloat {
    
    /// Small corner radius (8pt)
    static let hotCarRadiusSm: CGFloat = 8
    
    /// Medium corner radius (12pt)
    static let hotCarRadiusMd: CGFloat = 12
    
    /// Large corner radius (16pt)
    static let hotCarRadiusLg: CGFloat = 16
    
    /// Extra large corner radius (20pt)
    static let hotCarRadiusXl: CGFloat = 20
    
    /// Circle (999pt)
    static let hotCarRadiusCircle: CGFloat = 999
}

// MARK: - View Extension for Corner Radius

extension View {
    
    /// Small rounded corners
    func hotCarRoundedSm() -> some View {
        self.cornerRadius(.hotCarRadiusSm)
    }
    
    /// Medium rounded corners
    func hotCarRoundedMd() -> some View {
        self.cornerRadius(.hotCarRadiusMd)
    }
    
    /// Large rounded corners
    func hotCarRoundedLg() -> some View {
        self.cornerRadius(.hotCarRadiusLg)
    }
    
    /// Extra large rounded corners
    func hotCarRoundedXl() -> some View {
        self.cornerRadius(.hotCarRadiusXl)
    }
}
