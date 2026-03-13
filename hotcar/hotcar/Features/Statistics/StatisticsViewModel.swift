//
//  StatisticsViewModel.swift
//  hotcar
//
//  HotCar Statistics - ViewModel
//

import Foundation

@MainActor
final class StatisticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var statistics: WarmUpStatistics = WarmUpStatistics()
    @Published var selectedTimeRange: TimeRange = .weekly
    @Published var chartData: TimeRangeData = TimeRangeData()
    @Published var selectedVehicleId: String?
    
    // MARK: - Computed Properties
    
    /// Access sessions from StatisticsService
    var sessions: [WarmUpSession] {
        statisticsService.sessions
    }
    
    // MARK: - Dependencies
    
    private let statisticsService = StatisticsService.shared
    
    // MARK: - Initialization
    
    init() {
        loadStatistics()
    }
    
    // MARK: - Public Methods
    
    func loadStatistics() {
        statistics = statisticsService.getStatistics(for: selectedVehicleId)
        chartData = statisticsService.getChartData(for: selectedTimeRange)
    }
    
    func setTimeRange(_ timeRange: TimeRange) {
        selectedTimeRange = timeRange
        loadStatistics()
    }
    
    func setVehicle(_ vehicleId: String?) {
        selectedVehicleId = vehicleId
        loadStatistics()
    }
    
    func getFormattedTotalTime() -> String {
        let hours = statistics.totalMinutes / 60
        let minutes = statistics.totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getFormattedFuelUsed() -> String {
        return String(format: "%.2f L", statistics.totalFuelUsed)
    }
    
    func getFormattedTotalCost() -> String {
        return String(format: "$%.2f", statistics.totalCost)
    }
    
    func getFormattedAverageDuration() -> String {
        return String(format: "%.1f min", statistics.averageDuration)
    }
}
