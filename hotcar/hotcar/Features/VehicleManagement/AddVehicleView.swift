//
//  AddVehicleView.swift
//  hotcar
//
//  HotCar Vehicle Management - Add Vehicle View
//  Form to add a new vehicle
//

import SwiftUI

struct AddVehicleView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddVehicleViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section(header: Text("Basic Information")) {
                    TextField("Vehicle Name (e.g., 2023 Ford F-150)", text: $viewModel.vehicleName)
                    
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
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveVehicle()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddVehicleView()
}
