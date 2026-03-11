//
//  SettingsView.swift
//  hotcar
//
//  HotCar Settings - Main Settings View
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Temperature Settings
                temperatureSection
                
                // Timer Settings
                timerSection
                
                // Appearance
                appearanceSection
                
                // Privacy
                privacySection
                
                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Temperature Section
    
    private var temperatureSection: some View {
        Section(header: Text("Temperature")) {
            Picker("Unit", selection: $viewModel.temperatureUnit) {
                ForEach(AppSettings.TemperatureUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            
            Stepper(
                value: $viewModel.defaultTargetTemp,
                in: 15...30,
                step: 1
            ) {
                HStack {
                    Text("Target Temperature")
                    Spacer()
                    Text("\(Int(viewModel.defaultTargetTemp))°")
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Timer Section
    
    private var timerSection: some View {
        Section(header: Text("Timer")) {
            Stepper(
                value: $viewModel.defaultTimerDuration,
                in: 5...60,
                step: 5
            ) {
                HStack {
                    Text("Default Duration")
                    Spacer()
                    Text("\(viewModel.defaultTimerDuration) min")
                        .foregroundColor(.textSecondary)
                }
            }
            
            Toggle("Auto-start Timer", isOn: $viewModel.autoStartTimer)
            
            Toggle("Notifications", isOn: $viewModel.showNotifications)
            
            Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedback)
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            Picker("Dark Mode", selection: $viewModel.darkMode) {
                ForEach(AppSettings.DarkModeSetting.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
        }
    }
    
    // MARK: - Privacy Section
    
    private var privacySection: some View {
        Section(header: Text("Privacy")) {
            Toggle("Enable Analytics", isOn: $viewModel.analyticsEnabled)
            
            Toggle("Crash Reporting", isOn: $viewModel.crashReportingEnabled)
            
            Button(action: {
                viewModel.exportData()
            }) {
                HStack {
                    Text("Export My Data")
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.hotCarPrimary)
                }
            }
            
            Button(action: {
                viewModel.clearAllData()
            }) {
                HStack {
                    Text("Clear All Data")
                        .foregroundColor(.warmUpActive)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Group {
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundColor(.textSecondary)
                }
                
                Button(action: {
                    viewModel.showPrivacyPolicy()
                }) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.hotCarPrimary)
                    }
                }
                
                Button(action: {
                    viewModel.showTermsOfService()
                }) {
                    HStack {
                        Text("Terms of Service")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.hotCarPrimary)
                    }
                }
                
                Button(action: {
                    viewModel.contactSupport()
                }) {
                    HStack {
                        Text("Contact Support")
                            .foregroundColor(.hotCarPrimary)
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(action: {
                    viewModel.resetToDefaults()
                }) {
                    HStack {
                        Text("Reset to Defaults")
                            .foregroundColor(.warmUpActive)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
