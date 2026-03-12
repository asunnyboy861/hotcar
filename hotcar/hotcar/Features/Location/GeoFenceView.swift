//
//  GeoFenceView.swift
//  hotcar
//
//  HotCar View - GeoFence Management
//  Allows users to create and manage location-based zones
//

import SwiftUI
import MapKit

struct GeoFenceView: View {
    @StateObject private var viewModel = GeoFenceViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.zones.isEmpty {
                    EmptyStateView(
                        icon: "location.circle",
                        title: "No Geo-Fences",
                        message: "Create location-based reminders for auto-start"
                    )
                } else {
                    List {
                        ForEach(viewModel.zones) { zone in
                            GeoFenceCard(
                                zone: zone,
                                onToggle: {
                                    Task {
                                        await viewModel.toggleZone(zone.id)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteZone(zone.id)
                                    }
                                }
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                Task {
                                    await viewModel.deleteZone(viewModel.zones[index].id)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Geo-Fences")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddSheet = true }) {
                            Label("Add Custom Zone", systemImage: "plus")
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.createHomeZone()
                            }
                        }) {
                            Label("Set Home Zone", systemImage: "house")
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.createWorkZone()
                            }
                        }) {
                            Label("Set Work Zone", systemImage: "building.2")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddGeoFenceSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadZones()
            }
        }
    }
}

struct GeoFenceCard: View {
    let zone: GeoFenceZone
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: zone.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text(zone.name)
                        .font(.headline)
                    
                    Text(String(format: "Radius: %.0f m", zone.radius))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: .init(
                    get: { zone.isEnabled },
                    set: { _ in onToggle() }
                ))
            }
            
            HStack {
                Label(zone.triggerOnEntry ? "On Entry" : "No Entry", systemImage: "arrow.right.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(zone.triggerOnExit ? "On Exit" : "No Exit", systemImage: "arrow.left.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.backgroundCard)
        .cornerRadius(12)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension GeoFenceZone {
    var icon: String {
        if name.lowercased().contains("home") {
            return "house.fill"
        } else if name.lowercased().contains("work") {
            return "building.2.fill"
        } else {
            return "mappin.circle.fill"
        }
    }
}

struct AddGeoFenceSheet: View {
    @ObservedObject var viewModel: GeoFenceViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var radius: Double = 100
    @State private var triggerOnEntry = true
    @State private var triggerOnExit = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Zone Name")) {
                    TextField("e.g., Gym, School", text: $name)
                }
                
                Section(header: Text("Radius")) {
                    Stepper("\(Int(radius)) meters", value: $radius, in: 50...500, step: 50)
                }
                
                Section(header: Text("Triggers")) {
                    Toggle("Notify on Entry", isOn: $triggerOnEntry)
                    Toggle("Notify on Exit", isOn: $triggerOnExit)
                }
                
                Section {
                    Text("Zone will be created at your current location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Geo-Fence")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            await viewModel.createZone(
                                name: name,
                                radius: radius,
                                triggerOnEntry: triggerOnEntry,
                                triggerOnExit: triggerOnExit
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

@MainActor
final class GeoFenceViewModel: ObservableObject {
    @Published var zones: [GeoFenceZone] = []
    
    private let geoFenceService = GeoFenceService.shared
    
    func loadZones() async {
        await geoFenceService.loadZones()
        zones = geoFenceService.zones
    }
    
    func createZone(
        name: String,
        radius: Double,
        triggerOnEntry: Bool,
        triggerOnExit: Bool
    ) async {
        guard let location = LocationService.shared.currentLocation else { return }
        
        let zone = GeoFenceZone(
            id: UUID().uuidString,
            name: name,
            center: CLLocationCoordinate2DCodable(from: location),
            radius: radius,
            isEnabled: true,
            triggerOnEntry: triggerOnEntry,
            triggerOnExit: triggerOnExit,
            vehicleId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await geoFenceService.saveZone(zone)
        zones = geoFenceService.zones
    }
    
    func createHomeZone() async {
        await geoFenceService.createHomeZone()
        zones = geoFenceService.zones
    }
    
    func createWorkZone() async {
        await geoFenceService.createWorkZone()
        zones = geoFenceService.zones
    }
    
    func toggleZone(_ zoneId: String) async {
        await geoFenceService.toggleZone(zoneId)
        zones = geoFenceService.zones
    }
    
    func deleteZone(_ zoneId: String) async {
        await geoFenceService.deleteZone(zoneId)
        zones = geoFenceService.zones
    }
}

#Preview {
    GeoFenceView()
}
