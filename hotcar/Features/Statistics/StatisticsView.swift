//
//  StatisticsView.swift
//  hotcar
//
//  HotCar Statistics - Main View
//  Display warm-up statistics and insights
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedPeriod: TimeRange = .weekly
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    overviewSection
                    
                    // Chart
                    chartSection
                    
                    // Breakdown
                    breakdownSection
                    
                    // Insights
                    insightsSection
                }
                .padding(.horizontal, .hotCarSpacingLg)
                .padding(.vertical, .hotCarSpacingMd)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Daily").tag(TimeRange.daily)
                        Text("Weekly").tag(TimeRange.weekly)
                        Text("Monthly").tag(TimeRange.monthly)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
        .onChange(of: selectedPeriod) { newPeriod in
            viewModel.setTimeRange(newPeriod)
        }
        .onAppear {
            viewModel.loadStatistics()
        }
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(spacing: 12) {
            Text("Overview")
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Total Sessions",
                    value: "\(viewModel.statistics.totalSessions)",
                    icon: "list.bullet.rectangle",
                    color: .hotCarPrimary
                )
                
                StatCard(
                    title: "Total Time",
                    value: viewModel.getFormattedTotalTime(),
                    icon: "clock",
                    color: .hotCarSecondary
                )
                
                StatCard(
                    title: "Fuel Used",
                    value: viewModel.getFormattedFuelUsed(),
                    icon: "drop.fill",
                    color: .warmUpActive
                )
                
                StatCard(
                    title: "Total Cost",
                    value: viewModel.getFormattedTotalCost(),
                    icon: "dollarsign.circle.fill",
                    color: .tempCold
                )
            }
        }
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            if !viewModel.chartData.daily.isEmpty {
                Chart(viewModel.chartData.daily, id: \.id) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Sessions", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.hotCarPrimary, .hotCarPrimary.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(.hotCarRadiusSm)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatDate(date))
                                    .font(.hotCarCaption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(value.as(Int.self) ?? 0)")
                                .font(.hotCarCaption)
                        }
                    }
                }
            } else {
                emptyChart
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    // MARK: - Breakdown Section
    
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 16) {
                // By Vehicle
                if !viewModel.statistics.sessionsByVehicle.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Vehicle")
                            .font(.hotCarCaption)
                            .foregroundColor(.textSecondary)
                        
                        ForEach(viewModel.statistics.sessionsByVehicle.sorted(by: >), id: \.key) { vehicle, count in
                            BreakdownRow(
                                label: vehicle,
                                value: count,
                                total: viewModel.statistics.totalSessions,
                                color: .hotCarPrimary
                            )
                        }
                    }
                }
                
                Divider()
                
                // By Type
                if !viewModel.statistics.sessionsByType.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Vehicle Type")
                            .font(.hotCarCaption)
                            .foregroundColor(.textSecondary)
                        
                        ForEach(viewModel.statistics.sessionsByType.sorted(by: >), id: \.key) { type, count in
                            BreakdownRow(
                                label: VehicleType(rawValue: type)?.displayName ?? type,
                                value: count,
                                total: viewModel.statistics.totalSessions,
                                color: .hotCarSecondary
                            )
                        }
                    }
                }
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                InsightRow(
                    icon: "leaf.fill",
                    title: "Average Duration",
                    value: viewModel.getFormattedAverageDuration(),
                    color: .warmUpReady
                )
                
                InsightRow(
                    icon: "thermometer.medium",
                    title: "Average Temperature",
                    value: String(format: "%.1f°C", viewModel.statistics.averageTemperature),
                    color: .tempCold
                )
                
                InsightRow(
                    icon: "wallet.pass.fill",
                    title: "Est. Monthly Savings",
                    value: String(format: "$%.2f", viewModel.statistics.estimatedMonthlySavings),
                    color: .hotCarPrimary
                )
            }
        }
        .padding(.card)
        .background(Color.backgroundCard)
        .cornerRadius(.hotCarRadiusLg)
    }
    
    // MARK: - Empty Chart
    
    private var emptyChart: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundColor(.textMuted)
            
            Text("No data yet")
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            Text("Start using the warm-up timer to see statistics")
                .font(.hotCarCaption)
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Breakdown Row

struct BreakdownRow: View {
    let label: String
    let value: Int
    let total: Int
    let color: Color
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total) * 100
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.hotCarCaption)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(value) sessions")
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
}
