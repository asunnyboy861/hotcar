//
//  AddMaintenanceReminderView.swift
//  hotcar
//
//  HotCar Vehicle Management - Add Maintenance Reminder View
//  Form to add a new maintenance reminder
//

import SwiftUI

struct AddMaintenanceReminderView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddMaintenanceReminderViewModel
    
    // MARK: - Initialization
    
    init(vehicleId: String) {
        _viewModel = StateObject(wrappedValue: AddMaintenanceReminderViewModel(vehicleId: vehicleId))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Type Selection
                Section(header: Text(NSLocalizedString("add_reminder_type_section", tableName: "Localizable", comment: "Maintenance type section title"))) {
                    Picker("Type", selection: $viewModel.selectedType) {
                        ForEach(MaintenanceType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Details
                Section(header: Text(NSLocalizedString("add_reminder_details_section", tableName: "Localizable", comment: "Details section title"))) {
                    TextField("Title", text: $viewModel.title)
                    
                    TextField("Description (optional)", text: $viewModel.description)
                }
                
                // Due Date
                Section(header: Text(NSLocalizedString("add_reminder_due_date_section", tableName: "Localizable", comment: "Due date section title"))) {
                    Toggle("Set Due Date", isOn: $viewModel.hasDueDate)
                    
                    if viewModel.hasDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $viewModel.dueDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                    }
                }
                
                // Quick Intervals
                Section(header: Text(NSLocalizedString("add_reminder_quick_intervals", tableName: "Localizable", comment: "Quick intervals section title"))) {
                    ForEach(quickIntervals, id: \.label) { interval in
                        Button(action: {
                            viewModel.setInterval(interval.days)
                        }) {
                            HStack {
                                Text(interval.label)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.hotCarPrimary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("add_reminder_title", tableName: "Localizable", comment: "Add reminder page title"))
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
                            await viewModel.saveReminder()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
    
    // MARK: - Quick Intervals
    
    private var quickIntervals: [(label: String, days: Int)] {
        [
            ("1 Week", 7),
            ("2 Weeks", 14),
            ("1 Month", 30),
            ("3 Months", 90),
            ("6 Months", 180),
            ("1 Year", 365)
        ]
    }
}

// MARK: - Preview

#Preview {
    AddMaintenanceReminderView(vehicleId: "1")
}
