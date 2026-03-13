//
//  WarmUpTrendChart.swift
//  hotcar
//
//  HotCar Statistics - Warm-up Trend Chart Component
//  Displays time series chart of warm-up durations
//

import SwiftUI
import Charts

/// Warm-up time trend chart component
/// Responsibility: Display time series chart of warm-up durations
struct WarmUpTrendChart: View {
    
    // MARK: - Properties
    
    let dataPoints: [ChartDataPoint]
    let chartType: ChartType
    let unit: String
    @State private var selectedPoint: ChartDataPoint?
    
    enum ChartType {
        case duration
        case frequency
        case temperature
        
        var title: String {
            switch self {
            case .duration:
                return NSLocalizedString("chart_duration_title", tableName: "Localizable", comment: "Chart title for duration")
            case .frequency:
                return NSLocalizedString("chart_frequency_title", tableName: "Localizable", comment: "Chart title for frequency")
            case .temperature:
                return NSLocalizedString("chart_temperature_title", tableName: "Localizable", comment: "Chart title for temperature")
            }
        }
        
        var yAxisLabel: String {
            switch self {
            case .duration:
                return NSLocalizedString("chart_minutes", tableName: "Localizable", comment: "Chart Y axis label for minutes")
            case .frequency:
                return NSLocalizedString("chart_sessions", tableName: "Localizable", comment: "Chart Y axis label for sessions")
            case .temperature:
                return NSLocalizedString("chart_celsius", tableName: "Localizable", comment: "Chart Y axis label for celsius")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasData: Bool {
        !dataPoints.isEmpty && dataPoints.contains { $0.value > 0 }
    }
    
    private var averageValue: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.reduce(0) { $0 + $1.value } / Double(dataPoints.count)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            // Header
            chartHeader
            
            // Chart
            if hasData {
                chartContent
                    .frame(height: 200)
            } else {
                emptyStateView
            }
            
            // Selected value indicator
            if let selected = selectedPoint {
                selectedValueView(selected)
            }
        }
        .padding(HotCarSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.medium)
                .fill(Color.backgroundSecondary)
        )
    }
    
    // MARK: - Header
    
    private var chartHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(chartType.title)
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
                
                if hasData {
                    Text(String(format: NSLocalizedString("chart_average_format", tableName: "Localizable", comment: "Chart average format"), averageValue, unit))
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Legend
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.hotCarPrimary)
                    .frame(width: 8, height: 8)
                Text(unit)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Chart Content
    
    @available(iOS 16.0, *)
    private var chartContent: some View {
        Chart(dataPoints) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(Color.hotCarPrimary.gradient)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(Color.hotCarPrimary.opacity(0.1))
            
            if let selected = selectedPoint, selected.id == point.id {
                RuleMark(x: .value("Date", point.date))
                    .foregroundStyle(Color.textPrimary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        if let date: Date = chartProxy.value(atX: location.x) {
                            selectedPoint = findClosestPoint(to: date)
                        }
                    }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: HotCarSpacing.medium) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.textMuted)
            
            Text(NSLocalizedString("chart_no_data", tableName: "Localizable", comment: "No data message for chart"))
                .font(.hotCarBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Selected Value View
    
    private func selectedValueView(_ point: ChartDataPoint) -> some View {
        HStack {
            Text(point.label)
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(String(format: "%.1f %@", point.value, unit))
                .font(.hotCarHeadline)
                .foregroundColor(.hotCarPrimary)
        }
        .padding(.horizontal, HotCarSpacing.small)
        .padding(.vertical, HotCarSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.small)
                .fill(Color.hotCarPrimary.opacity(0.1))
        )
    }
    
    // MARK: - Helper Methods
    
    private func findClosestPoint(to date: Date) -> ChartDataPoint? {
        return dataPoints.min { point1, point2 in
            abs(point1.date.timeIntervalSince(date)) < abs(point2.date.timeIntervalSince(date))
        }
    }
}

// MARK: - iOS 15 Fallback

@available(iOS 15.0, *)
struct WarmUpTrendChartFallback: View {
    let dataPoints: [ChartDataPoint]
    let chartType: WarmUpTrendChart.ChartType
    let unit: String
    
    var body: some View {
        VStack {
            Text(chartType.title)
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            Text("Charts require iOS 16+")
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    WarmUpTrendChart(
        dataPoints: [
            ChartDataPoint(date: Date().addingTimeInterval(-86400 * 6), value: 15, label: "Mon"),
            ChartDataPoint(date: Date().addingTimeInterval(-86400 * 5), value: 12, label: "Tue"),
            ChartDataPoint(date: Date().addingTimeInterval(-86400 * 4), value: 18, label: "Wed"),
            ChartDataPoint(date: Date().addingTimeInterval(-86400 * 3), value: 10, label: "Thu"),
            ChartDataPoint(date: Date().addingTimeInterval(-86400 * 2), value: 20, label: "Fri"),
            ChartDataPoint(date: Date().addingTimeInterval(-86400), value: 14, label: "Sat"),
            ChartDataPoint(date: Date(), value: 16, label: "Sun")
        ],
        chartType: .duration,
        unit: "min"
    )
    .padding()
    .background(Color.backgroundPrimary)
}
