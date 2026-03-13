//
//  QuickConfigBar.swift
//  hotcar
//
//  HotCar Home - Quick Configuration Bar Component
//  Quick vehicle switching and configuration display
//  Optimized for US/Canada/Nordic markets with English localization
//

import SwiftUI

// MARK: - Quick Config Bar

/// Quick configuration bar component
/// Responsibility: Quick vehicle switching and engine type display
/// Uses Primary Vehicle concept from existing VehicleService
struct QuickConfigBar: View {
    
    // MARK: - Properties
    
    let vehicles: [Vehicle]
    let primaryVehicle: Vehicle?     // Use Vehicle instead of ID
    let onSetPrimary: (Vehicle) -> Void  // Pass Vehicle object
    let onOpenVehicleList: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: HotCarSpacing.medium) {
            // Vehicle selector
            vehicleSelector
            
            Spacer()
            
            // Engine type indicator
            if let vehicle = primaryVehicle {
                engineTypeIndicator(for: vehicle)
            }
            
            // More button
            Button(action: onOpenVehicleList) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
        }
        .padding(HotCarSpacing.medium)
        .background(Color.backgroundCard)
        .cornerRadius(HotCarRadius.large)
    }
    
    // MARK: - Vehicle Selector
    
    private var vehicleSelector: some View {
        Menu {
            ForEach(vehicles) { vehicle in
                Button(action: { onSetPrimary(vehicle) }) {
                    HStack {
                        Image(systemName: vehicle.type.icon)
                        Text(vehicle.name)
                        if vehicle.isPrimary {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            Button(action: onOpenVehicleList) {
                Label(NSLocalizedString("menu_manage_vehicles", tableName: "Localizable", comment: "Menu item to manage vehicle list"), 
                      systemImage: "gear")
            }
        } label: {
            HStack(spacing: 8) {
                if let vehicle = primaryVehicle {
                    Image(systemName: vehicle.type.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.hotCarPrimary)
                    
                    Text(vehicle.name)
                        .font(.hotCarCaption)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                } else {
                    Image(systemName: "car.fill")
                        .foregroundColor(.textMuted)
                    Text(NSLocalizedString("select_vehicle", tableName: "Localizable", comment: "Prompt to select a vehicle when none is selected"))
                        .font(.hotCarCaption)
                        .foregroundColor(.textMuted)
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.textMuted)
            }
        }
    }
    
    // MARK: - Engine Type Indicator
    
    private func engineTypeIndicator(for vehicle: Vehicle) -> some View {
        HStack(spacing: 4) {
            Image(systemName: engineIcon(for: vehicle.engineType))
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
            
            Text(vehicle.engineType.displayName)
                .font(.hotCarFootnote)
                .foregroundColor(.textMuted)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.backgroundElevated)
        .cornerRadius(HotCarRadius.small)
    }
    
    private func engineIcon(for type: EngineType) -> String {
        switch type {
        case .gasoline:
            return "fuel.pump.fill"
        case .diesel:
            return "engine.combustion"
        case .hybrid:
            return "leaf.fill"
        case .electric:
            return "bolt.fill"
        }
    }
}

// MARK: - Preview

#Preview("With Vehicles") {
    QuickConfigBar(
        vehicles: [
            Vehicle(name: "Ford F-150", year: 2022, type: .truck, engineType: .gasoline, isPrimary: true),
            Vehicle(name: "Toyota Camry", year: 2020, type: .sedan, engineType: .hybrid),
            Vehicle(name: "BMW X5", year: 2023, type: .suv, engineType: .diesel)
        ],
        primaryVehicle: Vehicle(name: "Ford F-150", year: 2022, type: .truck, engineType: .gasoline, isPrimary: true),
        onSetPrimary: { _ in },
        onOpenVehicleList: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("No Vehicle") {
    QuickConfigBar(
        vehicles: [],
        primaryVehicle: nil,
        onSetPrimary: { _ in },
        onOpenVehicleList: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}
