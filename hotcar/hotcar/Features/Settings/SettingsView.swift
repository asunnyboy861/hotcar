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
    @State private var showingExportSheet = false
    @State private var exportFileURL: URL?
    
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
            .navigationTitle(NSLocalizedString("settings_title", tableName: "Localizable", comment: "Settings page title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("button_done", tableName: "Localizable", comment: "Done button")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportFileURL {
                    ShareSheet(activityItems: [url])
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
            .onChange(of: viewModel.temperatureUnit) {
                viewModel.triggerSave()
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
            .onChange(of: viewModel.defaultTargetTemp) {
                viewModel.triggerSave()
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
            .onChange(of: viewModel.defaultTimerDuration) {
                viewModel.triggerSave()
            }
            
            Toggle("Auto-start Timer", isOn: $viewModel.autoStartTimer)
                .onChange(of: viewModel.autoStartTimer) {
                    viewModel.triggerSave()
                }
            
            Toggle("Notifications", isOn: $viewModel.showNotifications)
                .onChange(of: viewModel.showNotifications) {
                    viewModel.triggerSave()
                }
            
            Picker("Notification Sound", selection: $viewModel.notificationSound) {
                ForEach(AppSettings.NotificationSound.allCases, id: \.self) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }
            .onChange(of: viewModel.notificationSound) {
                    viewModel.triggerSave()
                }
            
            Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedback)
                .onChange(of: viewModel.hapticFeedback) {
                    viewModel.triggerSave()
                }
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
            .onChange(of: viewModel.darkMode) {
                viewModel.triggerSave()
            }
        }
    }
    
    // MARK: - Privacy Section
    
    private var privacySection: some View {
        Section(header: Text("Privacy")) {
            Toggle("Enable Analytics", isOn: $viewModel.analyticsEnabled)
            
            Toggle("Crash Reporting", isOn: $viewModel.crashReportingEnabled)
            
            Button(action: {
                exportData()
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
                        Text(NSLocalizedString("contact_support_button", tableName: "Localizable", comment: "Contact support button"))
                            .foregroundColor(.hotCarPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.hotCarPrimary)
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
    
    // MARK: - Export Data
    
    private func exportData() {
        let data = viewModel.exportData()
        
        // Create temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "HotCar_Export_\(Date().ISO8601Format()).json"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL, atomically: true, encoding: .utf8)
            exportFileURL = fileURL
            showingExportSheet = true
        } catch {
            print("Failed to create export file: \(error)")
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    SettingsView()
}
