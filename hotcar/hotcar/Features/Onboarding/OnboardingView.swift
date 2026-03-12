//
//  OnboardingView.swift
//  hotcar
//
//  HotCar Onboarding - First Time User Experience
//  Guides users through initial setup
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    FeaturesPage()
                        .tag(1)
                    
                    PermissionsPage()
                        .tag(2)
                    
                    GetStartedPage(onComplete: {
                        isPresented = false
                        onComplete()
                    })
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.hotCarSecondary : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Welcome Page

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "car.fill")
                .font(.system(size: 80))
                .foregroundColor(.hotCarSecondary)
            
            VStack(spacing: 12) {
                Text("Welcome to HotCar")
                    .font(.hotCarLargeTitle)
                    .foregroundColor(.textPrimary)
                
                Text("Your intelligent winter warm-up assistant")
                    .font(.hotCarBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text("Swipe to continue →")
                .font(.hotCarCaption)
                .foregroundColor(.textMuted)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

// MARK: - Features Page

struct FeaturesPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "thermometer.snowflake",
                    title: "Smart Warm-Up Time",
                    description: "Calculates optimal warm-up time based on temperature, vehicle type, and engine"
                )
                
                FeatureRow(
                    icon: "bell.badge",
                    title: "Smart Reminders",
                    description: "Get notified before you need to warm up your car"
                )
                
                FeatureRow(
                    icon: "gauge",
                    title: "Fuel Savings",
                    description: "Track fuel consumption and savings over time"
                )
                
                FeatureRow(
                    icon: "car.2",
                    title: "Multi-Vehicle Support",
                    description: "Manage multiple vehicles with different warm-up profiles"
                )
            }
            
            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.hotCarSecondary)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Permissions Page

struct PermissionsPage: View {
    @StateObject private var locationService = LocationService.shared
    @State private var notificationGranted = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 24) {
                PermissionRow(
                    icon: "location.fill",
                    title: "Location Access",
                    description: "Required to get accurate weather data for your area",
                    isGranted: locationService.authorizationStatus == .authorizedWhenInUse || 
                               locationService.authorizationStatus == .authorizedAlways
                ) {
                    locationService.requestPermission()
                }
                
                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Get reminded when it's time to warm up your car",
                    isGranted: notificationGranted
                ) {
                    Task {
                        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                        await MainActor.run {
                            notificationGranted = granted ?? false
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("You can change these settings later in System Settings")
                .font(.hotCarCaption)
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .padding()
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private func checkNotificationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                notificationGranted = settings.authorizationStatus == .authorized
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let onGrant: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isGranted ? .green : .hotCarSecondary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Button("Allow") {
                    onGrant()
                }
                .font(.hotCarCaption)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.hotCarPrimary)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.backgroundCard)
        .cornerRadius(12)
    }
}

// MARK: - Get Started Page

struct GetStartedPage: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                Text("You're All Set!")
                    .font(.hotCarLargeTitle)
                    .foregroundColor(.textPrimary)
                
                Text("Add your first vehicle to get personalized warm-up recommendations")
                    .font(.hotCarBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: onComplete) {
                Text("Get Started")
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
            .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isPresented: .constant(true)) {
        print("Onboarding complete")
    }
}
