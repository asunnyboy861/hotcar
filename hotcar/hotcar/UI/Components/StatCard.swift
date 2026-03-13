//
//  StatCard.swift
//  hotcar
//
//  HotCar UI Component - Statistics Card (Refactored)
//  Updated with new design system
//

import SwiftUI

struct StatCard: View {
    
    // MARK: - Properties
    
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.hotCarTitle)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            // Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                
                Text(subtitle)
                    .font(.hotCarFootnote)
                    .foregroundColor(.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HotCarSpacing.mediumLarge)
        .background(Color.backgroundCard)
        .cornerRadius(HotCarRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: HotCarRadius.large)
                .stroke(Color.textSecondary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: HotCarSpacing.medium) {
        StatCard(
            icon: "dollarsign.circle.fill",
            title: "Saved",
            value: "$45.50",
            subtitle: "This Month",
            color: .warmUpReady
        )
        
        StatCard(
            icon: "fuel.fill",
            title: "Fuel Used",
            value: "12.5 gal",
            subtitle: "This Month",
            color: .hotCarSecondary
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}