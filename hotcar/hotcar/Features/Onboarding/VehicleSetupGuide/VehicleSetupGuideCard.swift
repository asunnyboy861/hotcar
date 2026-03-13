//
//  VehicleSetupGuideCard.swift
//  hotcar
//
//  HotCar Onboarding - Vehicle Setup Guide Card
//  Guides first-time users to add their vehicle
//

import SwiftUI

/// Vehicle setup guide card component
/// Responsibility: Display guidance for adding first vehicle
struct VehicleSetupGuideCard: View {
    
    // MARK: - Properties
    
    let onAddVehicle: () -> Void
    let onDismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: HotCarSpacing.medium) {
            // Icon
            Image(systemName: "car.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.hotCarPrimary)
            
            // Title
            Text(NSLocalizedString("guide_add_vehicle_title", tableName: "Localizable", comment: "Title for add vehicle guide"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            // Description
            Text(NSLocalizedString("guide_add_vehicle_desc", tableName: "Localizable", comment: "Description for add vehicle guide"))
                .font(.hotCarBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Add Button
            Button(action: onAddVehicle) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(NSLocalizedString("button_add_vehicle", tableName: "Localizable", comment: "Button to add vehicle"))
                }
                .font(.hotCarHeadline)
                .foregroundColor(.white)
                .padding(.horizontal, HotCarSpacing.large)
                .padding(.vertical, HotCarSpacing.medium)
                .background(Color.hotCarPrimary)
                .cornerRadius(HotCarRadius.medium)
            }
            
            // Dismiss Button
            Button(action: onDismiss) {
                Text(NSLocalizedString("button_later", tableName: "Localizable", comment: "Button to dismiss guide"))
                    .font(.hotCarCaption)
                    .foregroundColor(.textMuted)
            }
        }
        .padding(HotCarSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.large)
                .fill(Color.backgroundSecondary)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview {
    VehicleSetupGuideCard(
        onAddVehicle: {},
        onDismiss: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}
