//
//  StatCard.swift
//  hotcar
//
//  HotCar UI Component - Statistics Card
//  Display a single statistic in a card format
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
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            // Value
            Text(value)
                .font(.hotCarTitle)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            // Title
            Text(title)
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
            
            // Subtitle
            Text(subtitle)
                .font(.hotCarFootnote)
                .foregroundColor(.textMuted)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
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
            value: "12.5L",
            subtitle: "This Month",
            color: .hotCarSecondary
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}
