//
//  QuickStatsView.swift
//  hotcar
//
//  HotCar Statistics - Quick Stats View Component
//  Simplified statistics overview for home screen
//  Optimized for US/Canada/Nordic markets with English localization
//

import SwiftUI

// MARK: - Quick Stats View

/// Simplified statistics view component
/// Responsibility: Display key statistics overview on home screen
/// Uses existing WarmUpStatistics with liters (L) for fuel
struct QuickStatsView: View {
    
    // MARK: - Properties
    
    let statistics: WarmUpStatistics  // Use existing type directly
    let isNewUser: Bool
    let onTapDetails: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: HotCarSpacing.medium) {
            // Header
            header
            
            // Statistics cards
            if isNewUser {
                newUserPlaceholder
            } else {
                statsGrid
            }
        }
        .padding(HotCarSpacing.medium)
        .background(Color.backgroundCard)
        .cornerRadius(HotCarRadius.large)
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text(NSLocalizedString("stats_this_month", tableName: "Localizable", comment: "Section title for current month statistics"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Button(action: onTapDetails) {
                HStack(spacing: 4) {
                    Text(NSLocalizedString("button_details", tableName: "Localizable", comment: "Button to view detailed statistics"))
                        .font(.hotCarCaption)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(.hotCarPrimary)
            }
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        HStack(spacing: HotCarSpacing.medium) {
            StatItem(
                icon: "dollarsign.circle.fill",
                value: String(format: "%.2f", statistics.totalCost),
                unit: "$",
                label: NSLocalizedString("stat_cost", tableName: "Localizable", comment: "Label for fuel cost statistics"),
                color: .warmUpReady
            )
            
            Divider()
                .background(Color.textMuted.opacity(0.2))
            
            StatItem(
                icon: "fuel.pump.fill",
                value: String(format: "%.1f", statistics.totalFuelUsed),
                unit: NSLocalizedString("unit_liter", tableName: "Localizable", comment: "Unit abbreviation for liters"),
                label: NSLocalizedString("stat_fuel_used", tableName: "Localizable", comment: "Label for fuel used statistics"),
                color: .hotCarSecondary
            )
            
            Divider()
                .background(Color.textMuted.opacity(0.2))
            
            StatItem(
                icon: "leaf.fill",
                value: String(format: "%.1f", statistics.totalCO2Saved),
                unit: NSLocalizedString("unit_kg", tableName: "Localizable", comment: "Unit abbreviation for kilograms"),
                label: NSLocalizedString("stat_co2_saved", tableName: "Localizable", comment: "Label for CO2 saved statistics"),
                color: .green
            )
        }
    }
    
    // MARK: - New User Placeholder
    
    private var newUserPlaceholder: some View {
        VStack(spacing: HotCarSpacing.small) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 32))
                .foregroundColor(.textMuted.opacity(0.5))
            
            Text(NSLocalizedString("new_user_track_savings", tableName: "Localizable", comment: "Message for new users to start tracking fuel usage"))
                .font(.hotCarCaption)
                .foregroundColor(.textMuted)
            
            Text(NSLocalizedString("new_user_use_timer", tableName: "Localizable", comment: "Instruction for new users to use the timer"))
                .font(.hotCarFootnote)
                .foregroundColor(.textMuted.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HotCarSpacing.large)
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: HotCarSpacing.small) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if unit == "$" {
                    Text(unit)
                        .font(.hotCarCaption)
                }
                Text(value)
                    .font(.hotCarTitle)
                    .fontWeight(.bold)
                if unit != "$" {
                    Text(unit)
                        .font(.hotCarCaption)
                }
            }
            .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.hotCarFootnote)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("With Data") {
    QuickStatsView(
        statistics: WarmUpStatistics.sample,
        isNewUser: false,
        onTapDetails: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("New User") {
    QuickStatsView(
        statistics: WarmUpStatistics.empty,
        isNewUser: true,
        onTapDetails: {}
    )
    .padding()
    .background(Color.backgroundPrimary)
}
