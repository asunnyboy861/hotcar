//
//  HomeView.swift
//  hotcar
//
//  HotCar Home Screen - Refactored Main View
//  Optimized for US/Canada/Nordic markets with English localization
//  Uses new component architecture for improved maintainability
//

import SwiftUI

// MARK: - Home View

/// Main home screen view
/// Responsibility: Assemble all home screen components and manage navigation
struct HomeView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var onboardingManager = OnboardingManager.shared
    @State private var showingVehicleList = false
    @State private var showingSettings = false
    @State private var showingStatistics = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: HotCarSpacing.large) {
                        // Vehicle Setup Guide (shown when no vehicles)
                        vehicleSetupGuideSection
                        
                        // Status Bar (Location + Temperature)
                        statusBarSection
                        
                        // Quick Config Bar (Vehicle Selector)
                        quickConfigSection
                        
                        // Hero Timer Card (Core Feature)
                        heroTimerSection
                        
                        // Cabin Temperature Card (Remote Mode Only)
                        temperatureCardSection
                        
                        // Quick Stats Section
                        quickStatsSection
                        
                        // Tomorrow Forecast Banner
                        forecastSection
                        
                        // Bottom padding for safe area
                        Spacer(minLength: HotCarSpacing.page)
                    }
                    .padding(.horizontal, HotCarLayout.screenMargin)
                    .padding(.top, HotCarSpacing.medium)
                    .padding(.bottom, HotCarSpacing.large)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundPrimary.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingVehicleList = true }) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.hotCarPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingVehicleList) {
                VehicleListView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView()
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .onAppear {
            viewModel.loadInitialData()
        }
    }
    
    // MARK: - Vehicle Setup Guide Section
    
    @ViewBuilder
    private var vehicleSetupGuideSection: some View {
        if onboardingManager.shouldShowVehicleGuide {
            VehicleSetupGuideCard(
                onAddVehicle: {
                    showingVehicleList = true
                },
                onDismiss: {
                    onboardingManager.dismissVehicleGuide()
                }
            )
        }
    }
    
    // MARK: - Status Bar Section
    
    private var statusBarSection: some View {
        StatusBarView(
            locationName: viewModel.locationName,
            temperature: viewModel.currentTemperature ?? 0,
            unit: viewModel.temperatureUnit,
            isLoading: viewModel.isLoading
        )
    }
    
    // MARK: - Quick Config Section
    
    private var quickConfigSection: some View {
        QuickConfigBar(
            vehicles: viewModel.vehicles,
            primaryVehicle: viewModel.primaryVehicle,
            onSetPrimary: { vehicle in
                viewModel.setPrimaryVehicle(vehicle)
            },
            onOpenVehicleList: {
                showingVehicleList = true
            }
        )
    }
    
    // MARK: - Hero Timer Section
    
    private var heroTimerSection: some View {
        HeroTimerCard(
            recommendedMinutes: viewModel.finalRecommendedTime,
            isRunning: viewModel.isTimerActive,
            progress: viewModel.timerProgress,
            remainingSeconds: viewModel.timeRemaining,
            vehicleName: viewModel.primaryVehicle?.name ?? NSLocalizedString("default_vehicle", tableName: "Localizable", comment: "Default vehicle name when none is selected"),
            temperatureStatus: viewModel.temperatureStatus ?? .aboveFreezing,
            onStart: {
                viewModel.startTimer()
            },
            onStop: {
                viewModel.stopTimer()
            },
            onAdjustTime: { minutes in
                viewModel.adjustTimerTime(by: minutes)
            }
        )
        // Display connection status badge when in remote mode
        .overlay(alignment: .topTrailing) {
            if viewModel.timerMode == .remote {
                ConnectionStatusBadge(state: viewModel.vehicleConnectionState)
            }
        }
    }
    
    // MARK: - Temperature Card Section
    
    @ViewBuilder
    private var temperatureCardSection: some View {
        if viewModel.timerMode == .remote {
            CabinTemperatureCard(
                insideTemp: viewModel.insideTemperature,
                outsideTemp: viewModel.outsideTemperature,
                targetTemp: 21.0,  // Will be converted to user's unit in the component
                isHeating: viewModel.isClimateOn,
                temperatureUnit: viewModel.temperatureUnit
            )
        }
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        QuickStatsView(
            statistics: viewModel.statistics,
            isNewUser: viewModel.isNewUser,
            onTapDetails: {
                showingStatistics = true
            }
        )
    }
    
    // MARK: - Forecast Section
    
    @ViewBuilder
    private var forecastSection: some View {
        if let tomorrowTemp = viewModel.tomorrowTemperature {
            ForecastBanner(
                tomorrowTemperature: tomorrowTemp,
                recommendedMinutes: viewModel.calculatedWarmUpTimeForTomorrow,
                unit: viewModel.temperatureUnit,
                onSetReminder: {
                    // TODO: Implement reminder functionality
                }
            )
        }
    }
}

// MARK: - Connection Status Badge

/// Displays vehicle connection state for Tesla API mode
struct ConnectionStatusBadge: View {
    let state: HomeViewModel.VehicleConnectionState
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(stateColor)
                .frame(width: 8, height: 8)
            
            Text(stateText)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.backgroundSecondary.opacity(0.9))
        .cornerRadius(12)
    }
    
    private var stateColor: Color {
        switch state {
        case .disconnected: return .textMuted
        case .connecting: return .orange
        case .connected: return .hotCarPrimary
        case .error: return .warmUpActive
        }
    }
    
    private var stateText: String {
        switch state {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .error: return "Error"
        }
    }
}

// MARK: - Cabin Temperature Card

/// Displays cabin temperature information for remote climate control mode
struct CabinTemperatureCard: View {
    let insideTemp: Double?
    let outsideTemp: Double?
    let targetTemp: Double
    let isHeating: Bool
    let temperatureUnit: AppSettings.TemperatureUnit
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Cabin Temperature")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if let inside = insideTemp {
                    // Display temperature with unit symbol based on settings
                    Text(String(format: "%.1f", inside))
                        .font(.hotCarDisplay)
                        .foregroundColor(.hotCarPrimary)
                    
                    Text(temperatureUnit.symbol)
                        .font(.hotCarTitle)
                        .foregroundColor(.textMuted)
                } else {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let outside = outsideTemp {
                HStack {
                    Image(systemName: "thermometer")
                        .foregroundColor(.textMuted)
                    
                    Text("Outside: \(String(format: "%.1f", outside))\(temperatureUnit.symbol)")
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Heating progress indicator
            if isHeating, let inside = insideTemp {
                HeatingProgressView(
                    current: inside,
                    target: targetTemp,
                    temperatureUnit: temperatureUnit
                )
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
}

// MARK: - Heating Progress View

/// Displays heating progress from current temperature to target
struct HeatingProgressView: View {
    let current: Double
    let target: Double
    let temperatureUnit: AppSettings.TemperatureUnit
    
    private var progress: Double {
        // Calculate progress based on temperature range
        // Convert target to Celsius for calculation if needed
        let targetCelsius = temperatureUnit.toCelsius(target)
        let currentCelsius = temperatureUnit.toCelsius(current)
        
        // Assume starting from -20°C
        let startTemp: Double = -20
        let totalRange = targetCelsius - startTemp
        let currentProgress = currentCelsius - startTemp
        return min(1.0, max(0.0, currentProgress / totalRange))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Heating Progress")
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.hotCarCaption)
                    .foregroundColor(.hotCarPrimary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.backgroundSecondary)
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.hotCarPrimary, .orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Preview

#Preview("Home View - Cold Weather") {
    HomeView()
}

#Preview("Home View - Light Mode") {
    HomeView()
        .preferredColorScheme(.light)
}
