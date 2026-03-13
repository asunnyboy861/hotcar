//
//  StatisticsEmptyStateView.swift
//  hotcar
//
//  Empty state view for statistics
//  Guides new users to start their first warm-up session
//

import SwiftUI

/// Empty state view shown when no statistics data exists
struct StatisticsEmptyStateView: View {
    
    let onStartWarmUp: () -> Void
    
    var body: some View {
        VStack(spacing: HotCarSpacing.large) {
            Spacer()
            
            // Icon
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.textMuted)
            
            // Title
            Text("No Statistics Yet")
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            // Description
            Text("Complete your first warm-up session to see detailed statistics about your vehicle's performance and fuel savings.")
                .font(.hotCarBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HotCarSpacing.large)
            
            // Quick start button
            Button(action: onStartWarmUp) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Start Your First Warm-Up")
                }
                .font(.hotCarButton)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HotCarSpacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: HotCarRadius.medium)
                        .fill(Color.hotCarPrimary)
                )
            }
            .padding(.horizontal, HotCarSpacing.large)
            .padding(.top, HotCarSpacing.medium)
            
            Spacer()
        }
    }
}

// MARK: - Preview

struct StatisticsEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsEmptyStateView(onStartWarmUp: {})
            .background(Color.backgroundPrimary)
    }
}
