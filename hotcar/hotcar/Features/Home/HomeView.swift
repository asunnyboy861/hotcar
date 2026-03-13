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
        NavigationView {
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
            recommendedMinutes: viewModel.calculatedWarmUpTime,
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

// MARK: - Preview

#Preview("Home View - Cold Weather") {
    HomeView()
}

#Preview("Home View - Light Mode") {
    HomeView()
        .preferredColorScheme(.light)
}
