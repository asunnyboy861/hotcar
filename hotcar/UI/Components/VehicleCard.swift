//
//  VehicleCard.swift
//  hotcar
//
//  HotCar UI Component - Vehicle Card
//  Display vehicle information in a card format
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
            HStack(spacing: 16) {
                // Vehicle Icon
                vehicleIcon
                
                // Vehicle Info
                vehicleInfo
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.textMuted)
                    .font(.hotCarCaption)
            }
            .padding(.card)
            .background(Color.backgroundCard)
            .cornerRadius(.hotCarRadiusLg)
            .overlay(
                RoundedRectangle(cornerRadius: .hotCarRadiusLg)
                    .stroke(
                        isPrimary ? Color.hotCarSecondary.opacity(0.5) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Vehicle Icon
    
    private var vehicleIcon: some View {
        Image(systemName: vehicle.type.icon)
            .font(.system(size: 36))
            .foregroundColor(.hotCarPrimary)
            .frame(width: 60, height: 60)
            .background(Color.backgroundSecondary)
            .cornerRadius(.hotCarRadiusMd)
    }
    
    // MARK: - Vehicle Info
    
    private var vehicleInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Vehicle Name
            Text(vehicle.name)
                .font(.hotCarHeadline)
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
        Label("Primary Vehicle", systemImage: "star.fill")
            .font(.hotCarCaption)
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
