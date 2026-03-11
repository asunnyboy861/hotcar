//
//  RemoteStartView.swift
//  hotcar
//
//  HotCar Feature - Remote Start View
//  Interface for Tesla climate control
//

import SwiftUI

struct RemoteStartView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = RemoteStartViewModel()
    @State private var showingAuthSheet = false
    @State private var showingVehicleSelector = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if !viewModel.isAuthenticated {
                    notAuthenticatedView
                } else {
                    climateControlView
                }
            }
            .navigationTitle("Remote Start")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isAuthenticated {
                        Button(action: { viewModel.logout() }) {
                            Text("Logout")
                                .foregroundColor(.warmUpActive)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAuthSheet) {
                TeslaAuthView()
            }
        }
    }
    
    // MARK: - Not Authenticated View
    
    private var notAuthenticatedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "car.fill")
                .font(.system(size: 80))
                .foregroundColor(.hotCarPrimary)
            
            Text("Connect Your Tesla")
                .font(.hotCarLargeTitle)
                .foregroundColor(.textPrimary)
            
            Text("Sign in with your Tesla account to enable remote climate control")
                .font(.hotCarBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAuthSheet = true }) {
                Label("Sign In", systemImage: "key")
                    .font(.hotCarButton)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.hotCarPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(.hotCarRadiusLg)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Supports Tesla Model S, 3, X, Y")
                .font(.hotCarCaption)
                .foregroundColor(.textMuted)
        }
        .padding()
    }
    
    // MARK: - Climate Control View
    
    private var climateControlView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Vehicle Info
                vehicleInfoCard
                
                // Temperature Display
                temperatureCard
                
                // Climate Controls
                climateControlsCard
                
                // Quick Actions
                quickActionsCard
                
                // Status
                statusCard
            }
            .padding(.horizontal, .hotCarSpacingLg)
            .padding(.vertical, .hotCarSpacingMd)
        }
        .background(Color.backgroundPrimary)
        .refreshable {
            await viewModel.refreshClimateState()
        }
        .onAppear {
            Task {
                await viewModel.refreshClimateState()
            }
        }
    }
    
    private var vehicleInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "car.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.hotCarPrimary)
                
                VStack(alignment: .leading) {
                    Text(viewModel.vehicleName)
                        .font(.hotCarHeadline)
                        .foregroundColor(.textPrimary)
                    
                    Text("Connected")
                        .font(.hotCarCaption)
                        .foregroundColor(.warmUpReady)
                }
                
                Spacer()
                
                Button(action: { showingVehicleSelector = true }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.hotCarPrimary)
                }
            }
        }
        .padding(.card)
        .background(Color.backgroundSecondary)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    private var temperatureCard: some View {
        VStack(spacing: 16) {
            Text("Cabin Temperature")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if let insideTemp = viewModel.insideTemperature {
                    Text(String(format: "%.1f", insideTemp))
                        .font(.hotCarDisplay)
                        .foregroundColor(.hotCarPrimary)
                    
                    Text("°C")
                        .font(.hotCarTitle)
                        .foregroundColor(.textMuted)
                } else {
                    ProgressView()
                }
            }
            
            if let outsideTemp = viewModel.outsideTemperature {
                HStack {
                    Image(systemName: "thermometer")
                        .foregroundColor(.textMuted)
                    
                    Text("Outside: \(String(format: "%.1f", outsideTemp))°C")
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    private var climateControlsCard: some View {
        VStack(spacing: 16) {
            Text("Climate Control")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            // Start/Stop Button
            Button(action: {
                Task {
                    await viewModel.toggleClimate()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.isClimateOn ? "power.circle.fill" : "power.circle")
                        .font(.system(size: 24))
                    
                    Text(viewModel.isClimateOn ? "Stop Climate" : "Start Climate")
                        .font(.hotCarButton)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.isClimateOn ? Color.warmUpActive : Color.hotCarPrimary)
                .foregroundColor(.white)
                .cornerRadius(.hotCarRadiusLg)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel.isLoading)
            
            // Temperature Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Target Temperature")
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f°C", viewModel.targetTemperature))
                        .font(.hotCarHeadline)
                        .foregroundColor(.hotCarPrimary)
                }
                
                Slider(
                    value: Binding(
                        get: { viewModel.targetTemperature },
                        set: { newValue in
                            Task {
                                await viewModel.setTargetTemperature(newValue)
                            }
                        }
                    ),
                    in: 15...30,
                    step: 0.5
                )
                .tint(.hotCarPrimary)
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    private var quickActionsCard: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "snowflake",
                    title: "Max A/C",
                    color: .tempCold
                )
                
                QuickActionButton(
                    icon: "flame.fill",
                    title: "Heat",
                    color: .warmUpActive
                )
                
                QuickActionButton(
                    icon: "wind",
                    title: "Fan",
                    color: .hotCarSecondary
                )
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.hotCarPrimary)
                Text("Status")
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
            }
            
            if let error = viewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.hotCarCaption)
                    .foregroundColor(.warmUpActive)
            } else if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .hotCarPrimary))
                    Text("Updating...")
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                }
            } else {
                Label(
                    viewModel.isClimateOn ? "Climate control is ON" : "Climate control is OFF",
                    systemImage: viewModel.isClimateOn ? "checkmark.circle.fill" : "circle"
                )
                .font(.hotCarCaption)
                .foregroundColor(viewModel.isClimateOn ? .warmUpReady : .textMuted)
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(title)
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.backgroundSecondary)
        .cornerRadius(.hotCarRadiusMd)
    }
}

// MARK: - Preview

#Preview {
    RemoteStartView()
}
