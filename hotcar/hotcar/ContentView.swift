//
//  ContentView.swift
//  hotcar
//
//  HotCar Main View - Root Container
//  Manages onboarding and main app flow
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var vehicleService = VehicleService.shared
    @State private var showingOnboarding = false
    @State private var showingAddVehicle = false
    
    var body: some View {
        Group {
            if onboardingManager.needsOnboarding {
                OnboardingView(isPresented: $showingOnboarding) {
                    onboardingManager.completeOnboarding()
                    checkForVehicle()
                }
            } else if onboardingManager.needsVehicleSetup {
                VehicleSetupPrompt(onComplete: {
                    onboardingManager.markVehicleAdded()
                })
            } else {
                HomeView()
            }
        }
        .onAppear {
            checkInitialState()
        }
    }
    
    private func checkInitialState() {
        if onboardingManager.needsOnboarding {
            showingOnboarding = true
        } else {
            checkForVehicle()
        }
    }
    
    private func checkForVehicle() {
        Task {
            await vehicleService.loadVehicles()
            if !vehicleService.vehicles.isEmpty {
                onboardingManager.markVehicleAdded()
            }
        }
    }
}

// MARK: - Vehicle Setup Prompt

struct VehicleSetupPrompt: View {
    let onComplete: () -> Void
    @State private var showingAddVehicle = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "car.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.hotCarSecondary)
            
            VStack(spacing: 12) {
                Text("Add Your First Vehicle")
                    .font(.hotCarLargeTitle)
                    .foregroundColor(.textPrimary)
                
                Text("Tell us about your vehicle to get personalized warm-up recommendations")
                    .font(.hotCarBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: { showingAddVehicle = true }) {
                    Text("Add Vehicle")
                        .font(.hotCarButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.hotCarSecondary, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Button("Skip for Now") {
                    onComplete()
                }
                .font(.hotCarCaption)
                .foregroundColor(.textMuted)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
        .sheet(isPresented: $showingAddVehicle) {
            AddVehicleView()
                .onDisappear {
                    if !VehicleService.shared.vehicles.isEmpty {
                        onComplete()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
