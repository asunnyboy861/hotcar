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
    @State private var selectedChartType: WarmUpTrendChart.ChartType = .duration
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: HotCarSpacing.large) {
                    // Overview Cards
                    overviewSection
                    
                    // Trend Chart
                    trendChartSection
                    
                    // Activity Chart
                    chartSection
                    
                    // Breakdown
                    breakdownSection
                    
                    // Insights
                    insightsSection
                }
                .padding(.horizontal, HotCarLayout.screenMargin)
                .padding(.vertical, HotCarSpacing.medium)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle(NSLocalizedString("statistics_title", tableName: "Localizable", comment: "Statistics page title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Period", selection: $selectedPeriod) {
                        Text(NSLocalizedString("time_daily", tableName: "Localizable", comment: "Daily time range")).tag(TimeRange.daily)
                        Text(NSLocalizedString("time_weekly", tableName: "Localizable", comment: "Weekly time range")).tag(TimeRange.weekly)
                        Text(NSLocalizedString("time_monthly", tableName: "Localizable", comment: "Monthly time range")).tag(TimeRange.monthly)
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
        VStack(spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("stats_overview", tableName: "Localizable", comment: "Statistics overview section title"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: HotCarSpacing.medium) {
                StatCard(
                    icon: "list.bullet.rectangle",
                    title: NSLocalizedString("stat_total_sessions", tableName: "Localizable", comment: "Total sessions stat"),
                    value: "\(viewModel.statistics.totalSessions)",
                    subtitle: NSLocalizedString("stat_all_time", tableName: "Localizable", comment: "All time subtitle"),
                    color: .hotCarPrimary
                )
                
                StatCard(
                    icon: "clock",
                    title: NSLocalizedString("stat_total_time", tableName: "Localizable", comment: "Total time stat"),
                    value: viewModel.getFormattedTotalTime(),
                    subtitle: NSLocalizedString("stat_all_time", tableName: "Localizable", comment: "All time subtitle"),
                    color: .hotCarSecondary
                )
                
                StatCard(
                    icon: "drop.fill",
                    title: NSLocalizedString("stat_fuel_used", tableName: "Localizable", comment: "Fuel used stat"),
                    value: viewModel.getFormattedFuelUsed(),
                    subtitle: NSLocalizedString("stat_all_time", tableName: "Localizable", comment: "All time subtitle"),
                    color: .warmUpActive
                )
                
                StatCard(
                    icon: "dollarsign.circle.fill",
                    title: NSLocalizedString("stat_total_cost", tableName: "Localizable", comment: "Total cost stat"),
                    value: viewModel.getFormattedTotalCost(),
                    subtitle: NSLocalizedString("stat_all_time", tableName: "Localizable", comment: "All time subtitle"),
                    color: .tempCold
                )
            }
        }
    }
    
    // MARK: - Trend Chart Section
    
    private var trendChartSection: some View {
        VStack(spacing: HotCarSpacing.medium) {
            // Chart Type Selector
            chartTypeSelector
            
            // Chart
            if #available(iOS 16.0, *) {
                WarmUpTrendChart(
                    dataPoints: currentChartData,
                    chartType: selectedChartType,
                    unit: chartUnit
                )
            } else {
                // Fallback for iOS 15
                WarmUpTrendChartFallback(
                    dataPoints: currentChartData,
                    chartType: selectedChartType,
                    unit: chartUnit
                )
            }
        }
    }
    
    private var chartTypeSelector: some View {
        HStack(spacing: HotCarSpacing.small) {
            chartTypeButton(for: .duration)
            chartTypeButton(for: .frequency)
            chartTypeButton(for: .temperature)
            
            Spacer()
        }
    }
    
    private func chartTypeButton(for type: WarmUpTrendChart.ChartType) -> some View {
        let isSelected = selectedChartType == type
        let backgroundColor = isSelected ? Color.hotCarPrimary : Color.backgroundSecondary.opacity(0.5)
        let textColor = isSelected ? Color.white : Color.textSecondary
        let fontWeight: Font.Weight = isSelected ? .semibold : .regular

        return Button(action: { selectedChartType = type }) {
            Text(type.title)
                .font(.hotCarCaption)
                .fontWeight(fontWeight)
                .foregroundColor(textColor)
                .padding(.horizontal, HotCarSpacing.medium)
                .padding(.vertical, HotCarSpacing.small)
                .background(
                    RoundedRectangle(cornerRadius: HotCarRadius.small)
                        .fill(backgroundColor)
                )
        }
    }
    
    private var currentChartData: [ChartDataPoint] {
        switch selectedPeriod {
        case .daily:
            return viewModel.chartData.daily
        case .weekly:
            return viewModel.chartData.weekly
        case .monthly:
            return viewModel.chartData.monthly
        }
    }
    
    private var chartUnit: String {
        switch selectedChartType {
        case .duration:
            return NSLocalizedString("unit_min", tableName: "Localizable", comment: "Minutes unit")
        case .frequency:
            return NSLocalizedString("unit_sessions", tableName: "Localizable", comment: "Sessions unit")
        case .temperature:
            return "°C"
        }
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("stats_activity", tableName: "Localizable", comment: "Activity section title"))
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
                    .cornerRadius(HotCarRadius.small)
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
        .padding(HotCarSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.medium)
                .fill(Color.backgroundSecondary)
        )
    }
    
    // MARK: - Breakdown Section
    
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("stats_breakdown", tableName: "Localizable", comment: "Breakdown section title"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: HotCarSpacing.medium) {
                // By Vehicle
                if !viewModel.statistics.sessionsByVehicle.isEmpty {
                    VStack(alignment: .leading, spacing: HotCarSpacing.small) {
                        Text(NSLocalizedString("stats_by_vehicle", tableName: "Localizable", comment: "By vehicle label"))
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
                    VStack(alignment: .leading, spacing: HotCarSpacing.small) {
                        Text(NSLocalizedString("stats_by_type", tableName: "Localizable", comment: "By vehicle type label"))
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
        .padding(HotCarSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.medium)
                .fill(Color.backgroundSecondary)
        )
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("stats_insights", tableName: "Localizable", comment: "Insights section title"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
                InsightRow(
                    icon: "leaf.fill",
                    title: NSLocalizedString("stats_avg_duration", tableName: "Localizable", comment: "Average duration label"),
                    value: viewModel.getFormattedAverageDuration(),
                    color: .warmUpReady
                )
                
                InsightRow(
                    icon: "thermometer.medium",
                    title: NSLocalizedString("stats_avg_temp", tableName: "Localizable", comment: "Average temperature label"),
                    value: String(format: "%.1f°C", viewModel.statistics.averageTemperature),
                    color: .tempCold
                )
                
                InsightRow(
                    icon: "wallet.pass.fill",
                    title: NSLocalizedString("stats_monthly_savings", tableName: "Localizable", comment: "Monthly savings label"),
                    value: String(format: "$%.2f", viewModel.statistics.estimatedMonthlySavings),
                    color: .hotCarPrimary
                )
            }
        }
        .padding(HotCarSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.medium)
                .fill(Color.backgroundSecondary)
        )
    }
    
    // MARK: - Empty Chart
    
    private var emptyChart: some View {
        VStack(spacing: HotCarSpacing.medium) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundColor(.textMuted)
            
            Text(NSLocalizedString("chart_no_data_title", tableName: "Localizable", comment: "No data title"))
                .font(.hotCarHeadline)
                .foregroundColor(.textSecondary)
            
            Text(NSLocalizedString("chart_no_data_desc", tableName: "Localizable", comment: "No data description"))
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
