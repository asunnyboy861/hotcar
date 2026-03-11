//
//  EditVehicleView.swift
//  hotcar
//
//  HotCar Vehicle Management - Edit Vehicle View
//  Form to edit existing vehicle details
//

import SwiftUI

struct EditVehicleView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditVehicleViewModel
    @State private var showingDeleteAlert = false
    
    // MARK: - Initialization
    
    init(vehicle: Vehicle) {
        _viewModel = StateObject(wrappedValue: EditVehicleViewModel(vehicle: vehicle))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section(header: Text("Basic Information")) {
                    TextField("Vehicle Name", text: $viewModel.vehicleName)
                    
                    Picker("Year", selection: $viewModel.selectedYear) {
                        ForEach(viewModel.availableYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    
                    Picker("Vehicle Type", selection: $viewModel.selectedType) {
                        ForEach(VehicleType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type.rawValue)
                        }
                    }
                    
                    Picker("Engine Type", selection: $viewModel.selectedEngineType) {
                        ForEach(EngineType.allCases, id: \.self) { engine in
                            Text(engine.displayName).tag(engine.rawValue)
                        }
                    }
                }
                
                // Options Section
                Section(header: Text("Options")) {
                    Toggle("Has Block Heater", isOn: $viewModel.hasBlockHeater)
                    
                    if viewModel.hasBlockHeater {
                        Toggle("Currently Plugged In", isOn: $viewModel.isPluggedIn)
                    }
                    
                    Toggle("Set as Primary Vehicle", isOn: $viewModel.isPrimary)
                }
                
                // Remote Start Section
                Section(header: Text("Remote Start (Optional)")) {
                    TextField("Brand (e.g., Tesla, Ford)", text: $viewModel.brand)
                    
                    TextField("VIN", text: $viewModel.vin)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.allCharacters)
                    
                    SecureField("API Token", text: $viewModel.apiToken)
                    
                    // VIN Decode Button
                    if !viewModel.vin.isEmpty {
                        Button(action: {
                            Task {
                                await viewModel.decodeVIN()
                            }
                        }) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                Text("Decode VIN")
                            }
                        }
                        .disabled(viewModel.isDecoding)
                    }
                    
                    // VIN Decoding Result
                    if let vinInfo = viewModel.vinDecodingResult {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("VIN Information")
                                .font(.hotCarHeadline)
                            
                            Text(vinInfo)
                                .font(.hotCarCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                // Danger Zone
                Section(header: Text("Danger Zone")) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Vehicle")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveVehicle()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Delete Vehicle?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteVehicle()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(viewModel.vehicleName)\"? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EditVehicleView(
        vehicle: Vehicle.sampleVehicles[0]
    )
}
