//
//  VehicleCard.swift
//  hotcar
//
//  HotCar UI Component - Vehicle Card (Refactored)
//  Display vehicle information in a card format
//  Updated with new design system
//

import SwiftUI

struct VehicleCard: View {
    
    // MARK: - Properties
    
    let vehicle: Vehicle
    let isPrimary: Bool
    let onTap: () -> Void
    
    // MARK: - Initialization
    
    init(
        vehicle: Vehicle,
        isPrimary: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.vehicle = vehicle
        self.isPrimary = isPrimary
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: HotCarSpacing.mediumLarge) {
                // Vehicle Icon
                vehicleIcon
                
                // Vehicle Info
                vehicleInfo
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
            .padding(HotCarSpacing.mediumLarge)
            .background(Color.backgroundCard)
            .cornerRadius(HotCarRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: HotCarRadius.large)
                    .stroke(
                        isPrimary ? Color.hotCarSecondary.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Vehicle Icon
    
    private var vehicleIcon: some View {
        ZStack {
            Circle()
                .fill(Color.hotCarPrimary.opacity(0.15))
                .frame(width: 56, height: 56)
            
            Image(systemName: vehicle.type.icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.hotCarPrimary)
        }
        .cornerRadius(HotCarRadius.medium)
    }
    
    // MARK: - Vehicle Info
    
    private var vehicleInfo: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.small) {
            // Vehicle Name
            Text(vehicle.name)
                .font(.hotCarHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            // Vehicle Details
            Text(vehicleDetails)
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
            
            // Primary Badge
            if isPrimary {
                primaryBadge
            }
        }
    }
    
    private var vehicleDetails: String {
        "\(vehicle.year) • \(vehicle.engineType.displayName)"
    }
    
    private var primaryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
            Text("Primary Vehicle")
        }
        .font(.hotCarFootnote)
        .fontWeight(.medium)
        .foregroundColor(.hotCarSecondary)
    }
}

// MARK: - Preview

#Preview {
    VehicleCard(
        vehicle: Vehicle(
            id: "1",
            name: "2023 Ford F-150",
            year: 2023,
            type: .truck,
            engineType: .gasoline
        ),
        isPrimary: true
    ) {}
    .padding()
    .background(Color.backgroundPrimary)
}