//
//  ShareImageGenerator.swift
//  hotcar
//
//  HotCar Sharing - Share Image Generator
//  Generates shareable images for social media
//

import SwiftUI

/// Share image generator component
/// Responsibility: Generate styled shareable images
struct ShareImageGenerator: View {
    
    // MARK: - Properties
    
    let data: ShareData
    
    // MARK: - Unit Conversion (ShareData uses gal/lbs, display uses L/kg)
    
    private var fuelSavedLiters: Double { data.fuelSaved * 3.78541 }
    private var co2ReducedKg: Double { data.co2Reduced * 0.453592 }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.05, green: 0.1, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 60) {
                // Header
                headerSection
                
                // Main stats
                mainStatsSection
                
                // Detail stats grid
                detailStatsSection
                
                Spacer()
                
                // Footer
                footerSection
            }
            .padding(80)
        }
        .frame(width: 1080, height: 1920)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App icon placeholder
            Image(systemName: "car.circle.fill")
                .font(.system(size: 120))
                .foregroundColor(.white)
            
            Text("HotCar")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(data.period.displayName)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Main Stats Section
    
    private var mainStatsSection: some View {
        VStack(spacing: 24) {
            Text(NSLocalizedString("share_savings_title", tableName: "Localizable", comment: "Share card savings title"))
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            Text(data.formattedMoneySaved)
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(.green)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 80)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Detail Stats Section
    
    private var detailStatsSection: some View {
        HStack(spacing: 40) {
            statBox(
                icon: "drop.fill",
                value: String(format: "%.1f L", fuelSavedLiters),
                label: NSLocalizedString("share_fuel_saved", tableName: "Localizable", comment: "Share card fuel saved")
            )
            
            statBox(
                icon: "leaf.fill",
                value: String(format: "%.1f kg", co2ReducedKg),
                label: NSLocalizedString("share_co2_reduced", tableName: "Localizable", comment: "Share card CO2 reduced")
            )
            
            statBox(
                icon: "flame.fill",
                value: "\(data.sessions)",
                label: NSLocalizedString("share_sessions", tableName: "Localizable", comment: "Share card sessions")
            )
        }
    }
    
    private func statBox(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.hotCarPrimary)
            
            Text(value)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("share_tagline", tableName: "Localizable", comment: "Share card tagline"))
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("#HotCar #WinterWarmUp #FuelEfficiency")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Image Generation Extension

extension ShareImageGenerator {
    /// Generate UIImage from the view
    func generateImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = CGSize(width: 1080, height: 1920)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - Preview

#Preview {
    ShareImageGenerator(
        data: ShareData(
            fuelSaved: 5.2,
            moneySaved: 18.20,
            co2Reduced: 102.0,
            sessions: 12,
            period: .weekly
        )
    )
    .frame(width: 300, height: 533)
}
