//
//  Spacing.swift
//  hotcar
//
//  HotCar Theme - Spacing & Border Radius System
//  Consistent spacing scale for visual harmony
//  Optimized for US market design preferences
//

import SwiftUI

// MARK: - Spacing Scale (8pt Grid System)

struct HotCarSpacing {
    
    // MARK: - Micro Spacing (1-4pt)
    
    /// 1pt - Hairline spacing (subtle separators)
    static let hairline: CGFloat = 1
    
    /// 2pt - Extra tight spacing
    static let extraTight: CGFloat = 2
    
    /// 4pt - Tight spacing (icon margins)
    static let tight: CGFloat = 4
    
    // MARK: - Small Spacing (8pt)
    
    /// 8pt - Small spacing (compact layouts)
    static let small: CGFloat = 8
    
    // MARK: - Medium Spacing (12-16pt)
    
    /// 12pt - Medium-small spacing
    static let mediumSmall: CGFloat = 12
    
    /// 16pt - Medium spacing (standard padding)
    static let medium: CGFloat = 16
    
    // MARK: - Large Spacing (20-24pt)
    
    /// 20pt - Medium-large spacing
    static let mediumLarge: CGFloat = 20
    
    /// 24pt - Large spacing (section padding)
    static let large: CGFloat = 24
    
    // MARK: - Extra Large Spacing (32-48pt)
    
    /// 32pt - Extra large spacing
    static let extraLarge: CGFloat = 32
    
    /// 40pt - Section spacing
    static let section: CGFloat = 40
    
    /// 48pt - Page spacing
    static let page: CGFloat = 48
}

// MARK: - Border Radius Scale

struct HotCarRadius {
    
    // MARK: - Small Radius (4-8pt)
    
    /// 4pt - Minimal radius (small buttons, chips)
    static let small: CGFloat = 4
    
    /// 6pt - Small-medium radius
    static let smallMedium: CGFloat = 6
    
    /// 8pt - Standard radius (buttons, inputs)
    static let medium: CGFloat = 8
    
    // MARK: - Medium Radius (12-16pt)
    
    /// 12pt - Medium-large radius (cards)
    static let mediumLarge: CGFloat = 12
    
    /// 16pt - Large radius (large cards, modals)
    static let large: CGFloat = 16
    
    // MARK: - Large Radius (20-24pt)
    
    /// 20pt - Extra large radius
    static let extraLarge: CGFloat = 20
    
    /// 24pt - Maximum radius (hero cards)
    static let maximum: CGFloat = 24
    
    // MARK: - Pill/Circle
    
    /// Pill shape (half of button height)
    static let pill: CGFloat = 999
    
    /// Circle (for avatars, icons)
    static let circle: CGFloat = 999
}

// MARK: - View Extensions for Easy Application

extension View {
    
    // MARK: - Padding Presets
    
    /// Apply standard content padding (16pt)
    func hotCarPadding() -> some View {
        self.padding(HotCarSpacing.medium)
    }
    
    /// Apply card padding (20pt)
    func hotCarCardPadding() -> some View {
        self.padding(HotCarSpacing.mediumLarge)
    }
    
    /// Apply section padding (24pt horizontal, 32pt vertical)
    func hotCarSectionPadding() -> some View {
        self.padding(.horizontal, HotCarSpacing.large)
            .padding(.vertical, HotCarSpacing.extraLarge)
    }
    
    // MARK: - Corner Radius Presets
    
    /// Apply small radius (4pt)
    func hotCarSmallRadius() -> some View {
        self.cornerRadius(HotCarRadius.small)
    }
    
    /// Apply medium radius (8pt)
    func hotCarMediumRadius() -> some View {
        self.cornerRadius(HotCarRadius.medium)
    }
    
    /// Apply card radius (16pt)
    func hotCarCardRadius() -> some View {
        self.cornerRadius(HotCarRadius.large)
    }
    
    /// Apply large radius (24pt)
    func hotCarLargeRadius() -> some View {
        self.cornerRadius(HotCarRadius.maximum)
    }
}

// MARK: - Card Style Presets

struct HotCarCardStyle {
    
    /// Light card style (subtle elevation)
    static let light = CardStyle(
        backgroundColor: Color.backgroundCard,
        cornerRadius: HotCarRadius.large,
        shadowRadius: 8,
        shadowOpacity: 0.15
    )
    
    /// Standard card style
    static let standard = CardStyle(
        backgroundColor: Color.backgroundCard,
        cornerRadius: HotCarRadius.large,
        shadowRadius: 16,
        shadowOpacity: 0.2
    )
    
    /// Elevated card style (prominent)
    static let elevated = CardStyle(
        backgroundColor: Color.backgroundElevated,
        cornerRadius: HotCarRadius.mediumLarge,
        shadowRadius: 24,
        shadowOpacity: 0.25
    )
}

struct CardStyle {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
}

// MARK: - Layout Constants

struct HotCarLayout {
    
    // MARK: - Screen Margins
    
    /// Screen edge padding (horizontal)
    static let screenMargin: CGFloat = 20
    
    /// Safe area inset (for notched devices)
    static let safeAreaInset: CGFloat = 44
    
    // MARK: - Component Sizes
    
    /// Standard button height
    static let buttonHeight: CGFloat = 50
    
    /// Large button height
    static let largeButtonHeight: CGFloat = 56
    
    /// Icon size (standard)
    static let iconSize: CGFloat = 24
    
    /// Large icon size
    static let largeIconSize: CGFloat = 32
    
    /// Avatar size
    static let avatarSize: CGFloat = 40
    
    /// Large avatar size
    static let largeAvatarSize: CGFloat = 56
    
    // MARK: - Card Dimensions
    
    /// Standard card padding (internal)
    static let cardPadding: CGFloat = 16
    
    /// Card minimum height
    static let cardMinHeight: CGFloat = 80
    
    // MARK: - Navigation
    
    /// Navigation bar height (including safe area)
    static let navBarHeight: CGFloat = 44
    
    /// Tab bar height
    static let tabBarHeight: CGFloat = 49
}

// MARK: - CGFloat Extension for Spacing

extension CGFloat {
    
    /// Extra small spacing (4pt)
    static let hotCarSpacingXS: CGFloat = 4
    
    /// Small spacing (8pt)
    static let hotCarSpacingSm: CGFloat = 8
    
    /// Medium spacing (12pt)
    static let hotCarSpacingMd: CGFloat = 12
    
    /// Large spacing (16pt)
    static let hotCarSpacingLg: CGFloat = 16
    
    /// Extra large spacing (24pt)
    static let hotCarSpacingXl: CGFloat = 24
    
    /// Extra extra large spacing (32pt)
    static let hotCarSpacingXXl: CGFloat = 32
    
    /// Page margin (20pt)
    static let hotCarSpacingPage: CGFloat = 20
}

// MARK: - CGFloat Extension for Corner Radius

extension CGFloat {
    
    /// Small radius (4pt) - small buttons, chips
    static let hotCarRadiusSm: CGFloat = 4
    
    /// Medium radius (8pt) - inputs, small cards
    static let hotCarRadiusMd: CGFloat = 8
    
    /// Large radius (12pt) - standard cards
    static let hotCarRadiusLg: CGFloat = 12
    
    /// Extra large radius (16pt) - large cards, buttons
    static let hotCarRadiusXl: CGFloat = 16
    
    /// Extra extra large radius (20pt) - special cards
    static let hotCarRadiusXXl: CGFloat = 20
    
    /// Full radius (999pt) - circular buttons, avatars
    static let hotCarRadiusFull: CGFloat = 999
}

// MARK: - EdgeInsets Extension for Card Padding

extension EdgeInsets {
    
    /// Standard card padding (16pt all sides)
    static let card = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    
    /// Compact card padding (12pt all sides)
    static let cardCompact = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
    
    /// Loose card padding (20pt all sides)
    static let cardLoose = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
}