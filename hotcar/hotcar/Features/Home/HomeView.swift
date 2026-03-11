//
//  HomeView.swift
//  hotcar
//
//  HotCar Main Screen - Home View
//  Displays current temperature, warm-up calculator, and quick actions
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingVehicleList = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Temperature Section
                    temperatureSection
                    
                    // Warm-Up Timer Section
                    warmUpSection
                    
                    // Vehicle Section
                    vehicleSection
                    
                    // Quick Stats Section
                    statsSection
                    
                    // Tomorrow Forecast
                    forecastSection
                }
                .padding(.horizontal, .hotCarSpacingLg)
                .padding(.vertical, .hotCarSpacingMd)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("HotCar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingVehicleList = true }) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.hotCarPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingVehicleList) {
                VehicleListView()
            }
        }
        .onAppear {
            viewModel.loadWeather()
        }
    }
    
    // MARK: - Temperature Section
    
    private var temperatureSection: some View {
        VStack(spacing: 12) {
            if let temperature = viewModel.currentTemperature {
                TemperatureDisplay(
                    temperature: temperature,
                    showUnit: true,
                    size: .large
                )
                
                Text(viewModel.locationName)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
            } else if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .hotCarPrimary))
            } else {
                Text("Unable to load temperature")
                    .font(.hotCarCaption)
                    .foregroundColor(.textMuted)
            }
        }
        .padding(.vertical, .hotCarSpacingLg)
    }
    
    // MARK: - Warm-Up Section
    
    private var warmUpSection: some View {
        VStack(spacing: 16) {
            Text("Recommended Warm-Up Time")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            TimerButton(
                minutes: viewModel.calculatedWarmUpTime,
                isActive: viewModel.isTimerActive,
                action: {
                    viewModel.toggleTimer()
                }
            )
            
            // Warm-up advice
            if let advice = viewModel.warmUpAdvice {
                Text(advice)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, .hotCarSpacingSm)
            }
        }
        .padding(.card)
        .background(Color.backgroundSecondary)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    // MARK: - Vehicle Section
    
    private var vehicleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Vehicle")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            if let vehicle = viewModel.primaryVehicle {
                VehicleCard(
                    vehicle: vehicle,
                    isPrimary: true,
                    onTap: {
                        showingVehicleList = true
                    }
                )
            } else {
                Button(action: { showingVehicleList = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.hotCarPrimary)
                        Text("Add Your First Vehicle")
                            .foregroundColor(.hotCarPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .hotCarSpacingMd)
                    .background(Color.backgroundCard)
                    .cornerRadius(.hotCarRadiusMd)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            // Fuel Saved Card
            StatCard(
                icon: "dollarsign.circle.fill",
                title: "Saved",
                value: "$\(String(format: "%.2f", viewModel.fuelSaved))",
                subtitle: "This Month",
                color: .warmUpReady
            )
            
            // Fuel Used Card
            StatCard(
                icon: "fuel.fill",
                title: "Fuel Used",
                value: "\(String(format: "%.1f", viewModel.fuelUsed))L",
                subtitle: "This Month",
                color: .hotCarSecondary
            )
        }
    }
    
    // MARK: - Forecast Section
    
    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.hotCarPrimary)
                Text("Tomorrow Morning")
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
            }
            
            if let tomorrowTemp = viewModel.tomorrowTemperature {
                HStack {
                    TemperatureDisplay(
                        temperature: tomorrowTemp,
                        showUnit: true,
                        size: .medium
                    )
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Plan ahead!")
                            .font(.hotCarCaption)
                            .foregroundColor(.textSecondary)
                        
                        Text("Start \(viewModel.calculatedWarmUpTimeForTomorrow) min early")
                            .font(.hotCarCaption)
                            .foregroundColor(.hotCarPrimary)
                    }
                }
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
