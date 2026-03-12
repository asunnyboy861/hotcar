//
//  VehicleListView.swift
//  hotcar
//
//  HotCar Vehicle Management - Vehicle List View
//  Display and manage user's vehicles
//

import SwiftUI

struct VehicleListView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = VehicleListViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddVehicle = false
    @State private var selectedVehicle: Vehicle?
    @State private var showingEditVehicle = false
    @State private var showingMaintenance = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.vehicles.isEmpty {
                    emptyState
                } else {
                    vehicleList
                }
            }
            .navigationTitle("My Vehicles")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddVehicle = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
            }
        }
    }
    
    // MARK: - Vehicle List
    
    private var vehicleList: some View {
        List(viewModel.vehicles) { vehicle in
            VStack(alignment: .leading, spacing: 8) {
                VehicleRow(
                    vehicle: vehicle,
                    isPrimary: vehicle.isPrimary,
                    onTogglePrimary: {
                        viewModel.setPrimaryVehicle(vehicle)
                    },
                    onDelete: {
                        viewModel.deleteVehicle(vehicle)
                    }
                )
                
                NavigationLink(destination: MaintenanceRemindersView(vehicleId: vehicle.id)) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.hotCarSecondary)
                        VStack(alignment: .leading) {
                            Text("Maintenance Reminders")
                                .font(.hotCarCaption)
                                .foregroundColor(.hotCarSecondary)
                            Text("\(viewModel.getReminderCount(for: vehicle.id)) reminders")
                                .font(.hotCarFootnote)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.textMuted)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 64))
                .foregroundColor(.textMuted)
            
            Text("No Vehicles Yet")
                .font(.hotCarTitle)
                .foregroundColor(.textPrimary)
            
            Text("Add your first vehicle to get started")
                .font(.hotCarBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddVehicle = true }) {
                Label("Add Vehicle", systemImage: "plus")
                    .font(.hotCarButton)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.hotCarPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(.hotCarRadiusMd)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Vehicle Row

struct VehicleRow: View {
    
    let vehicle: Vehicle
    let isPrimary: Bool
    let onTogglePrimary: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: vehicle.type.icon)
                .font(.system(size: 32))
                .foregroundColor(.hotCarPrimary)
                .frame(width: 50)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.name)
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
                
                Text("\(vehicle.year) • \(vehicle.engineType.displayName)")
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Primary Toggle
            if isPrimary {
                Image(systemName: "star.fill")
                    .foregroundColor(.hotCarSecondary)
            } else {
                Button(action: onTogglePrimary) {
                    Image(systemName: "star")
                        .foregroundColor(.textMuted)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VehicleListView()
}
