//
//  WeatherAlertView.swift
//  hotcar
//
//  HotCar View - Weather Alert Display
//  Shows active weather alerts and warnings
//

import SwiftUI

struct WeatherAlertView: View {
    @StateObject private var viewModel = WeatherAlertViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading alerts...")
                } else if viewModel.activeAlerts.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.shield",
                        title: "No Alerts",
                        message: "No active weather warnings"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.activeAlerts) { alert in
                                AlertCard(alert: alert)
                                    .onTapGesture {
                                        Task {
                                            await viewModel.markAsRead(alert.id)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Weather Alerts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.clearAll()
                        }
                    }) {
                        Text("Clear All")
                    }
                }
            }
            .task {
                await viewModel.loadAlerts()
                await viewModel.checkAlerts()
            }
        }
    }
}

struct AlertCard: View {
    let alert: WeatherAlert
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: alert.type.icon)
                    .font(.title2)
                    .foregroundColor(priorityColor)
                
                VStack(alignment: .leading) {
                    Text(alert.title)
                        .font(.headline)
                    Text(alert.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !alert.isRead {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            
            if isExpanded {
                Text(alert.message)
                    .font(.subheadline)
                
                if let metadata = alert.metadata {
                    VStack(alignment: .leading, spacing: 8) {
                        if let temp = metadata.currentTemperature {
                            Label(String(format: "%.1f°F", temp), systemImage: "thermometer")
                        }
                        if let change = metadata.temperatureChange {
                            Label(String(format: "%.1f°F drop", change), systemImage: "arrow.down")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.alertBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    var priorityColor: Color {
        switch alert.type.priority {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

@MainActor
final class WeatherAlertViewModel: ObservableObject {
    @Published var activeAlerts: [WeatherAlert] = []
    @Published var isLoading = false
    
    private let alertService = WeatherAlertService.shared
    
    func loadAlerts() async {
        isLoading = true
        await alertService.loadAlerts()
        activeAlerts = alertService.activeAlerts
        isLoading = false
    }
    
    func checkAlerts() async {
        await alertService.checkAndGenerateAlerts()
        activeAlerts = alertService.activeAlerts
    }
    
    func markAsRead(_ alertId: String) async {
        await alertService.markAlertAsRead(alertId)
        activeAlerts = alertService.activeAlerts
    }
    
    func clearAll() async {
        await alertService.clearAllAlerts()
        activeAlerts = []
    }
}

extension Color {
    static let alertBackground = Color.gray.opacity(0.2)
}

#Preview {
    WeatherAlertView()
}
