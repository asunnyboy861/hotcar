//
//  StatisticsService.swift
//  hotcar
//
//  HotCar Statistics - Service Layer
//  Manages statistics collection and analysis
//

import Foundation

@MainActor
final class StatisticsService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = StatisticsService()
    
    // MARK: - Published Properties
    
    @Published var sessions: [WarmUpSession] = []
    @Published var statistics: WarmUpStatistics = WarmUpStatistics()
    
    // MARK: - Dependencies
    
    private let storageKey = "com.hotcar.sessions"
    private let vehicleService = VehicleService.shared
    
    // MARK: - Initialization
    
    private init() {
        loadSessionsSync()
        calculateStatistics()
    }
    
    // MARK: - Public Methods
    
    func loadSessions() async {
        loadSessionsSync()
        calculateStatistics()
    }
    
    func addSession(_ session: WarmUpSession) async {
        sessions.append(session)
        saveSessions()
        calculateStatistics()
    }
    
    func updateSession(_ session: WarmUpSession) async {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
            calculateStatistics()
        }
    }
    
    func deleteSession(_ session: WarmUpSession) async {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
        calculateStatistics()
    }
    
    func getSessions(for vehicleId: String) -> [WarmUpSession] {
        sessions.filter { $0.vehicleId == vehicleId }
            .sorted { $0.startTime > $1.startTime }
    }
    
    func getSessions(for dateRange: DateRange) -> [WarmUpSession] {
        sessions.filter { dateRange.contains($0.startTime) }
            .sorted { $0.startTime > $1.startTime }
    }
    
    func getStatistics(for vehicleId: String? = nil) -> WarmUpStatistics {
        guard let vehicleId = vehicleId else {
            return statistics
        }
        
        let filteredSessions = sessions.filter { $0.vehicleId == vehicleId }
        return calculateStatistics(for: filteredSessions)
    }
    
    func getChartData(for timeRange: TimeRange) -> TimeRangeData {
        var result = TimeRangeData()
        
        switch timeRange {
        case .daily:
            result.daily = generateDailyData()
        case .weekly:
            result.weekly = generateWeeklyData()
        case .monthly:
            result.monthly = generateMonthlyData()
        }
        
        return result
    }
    
    func exportData() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(sessions),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "Error exporting data"
        }
        
        return jsonString
    }
    
    func recordIdleWaste(sessionId: String, idleSeconds: Int) async {
        let session = IdleWasteSession(
            id: sessionId,
            timestamp: Date(),
            idleSeconds: idleSeconds
        )
        
        idleSessions.append(session)
        saveIdleSessions()
        calculateIdleStatistics()
    }
    
    // MARK: - Idle Waste Tracking
    
    private var idleSessions: [IdleWasteSession] = []
    private let idleStorageKey = "com.hotcar.idlesessions"
    
    private func loadIdleSessions() {
        guard let data = UserDefaults.standard.data(forKey: idleStorageKey),
              let decoded = try? JSONDecoder().decode([IdleWasteSession].self, from: data) else {
            idleSessions = []
            return
        }
        idleSessions = decoded
    }
    
    private func saveIdleSessions() {
        if let encoded = try? JSONEncoder().encode(idleSessions) {
            UserDefaults.standard.set(encoded, forKey: idleStorageKey)
        }
    }
    
    private func calculateIdleStatistics() {
        let totalSeconds = idleSessions.reduce(0) { $0 + $1.idleSeconds }
        let fuelRate = 0.5 / 3600.0
        let fuelWasted = Double(totalSeconds) * fuelRate
        let co2Wasted = fuelWasted * 2.3
        
        IdleAlertService.shared.totalIdleSeconds = totalSeconds
        IdleAlertService.shared.fuelWasted = fuelWasted
        IdleAlertService.shared.co2Wasted = co2Wasted
    }
    
    // MARK: - Private Methods
    
    private func loadSessionsSync() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WarmUpSession].self, from: data) else {
            sessions = []
            return
        }
        sessions = decoded
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func calculateStatistics() {
        statistics = calculateStatistics(for: sessions)
    }
    
    private func calculateStatistics(for sessions: [WarmUpSession]) -> WarmUpStatistics {
        var stats = WarmUpStatistics()
        
        stats.totalSessions = sessions.count
        stats.totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        stats.totalFuelUsed = sessions.reduce(0) { $0 + $1.fuelEstimate }
        stats.totalCost = sessions.reduce(0) { $0 + $1.costEstimate }
        
        if !sessions.isEmpty {
            stats.averageDuration = Double(stats.totalMinutes) / Double(stats.totalSessions)
            stats.averageTemperature = sessions.reduce(0) { $0 + $1.outsideTemperature } / Double(stats.totalSessions)
        }
        
        let optimalMinutes = sessions.count * 10
        let savedMinutes = max(0, optimalMinutes - stats.totalMinutes)
        let savedFuelPerMinute = 0.008
        stats.totalFuelSaved = Double(savedMinutes) * savedFuelPerMinute
        stats.totalCO2Saved = stats.totalFuelSaved * 2.3
        
        stats.sessionsByVehicle = Dictionary(grouping: sessions) { $0.vehicleName }
            .mapValues { $0.count }
        
        stats.sessionsByType = Dictionary(grouping: sessions) { $0.vehicleType }
            .mapValues { $0.count }
        
        let calendar = Calendar.current
        let today = Date()
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let key = formatDateKey(date)
                let count = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: date) }.count
                stats.dailySessions[key] = count
            }
        }
        
        for weekOffset in 0..<4 {
            if let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) {
                let key = formatWeekKey(date)
                let count = sessions.filter {
                    calendar.isDate($0.startTime, equalTo: date, toGranularity: .weekOfYear)
                }.count
                stats.weeklySessions[key] = count
            }
        }
        
        for monthOffset in 0..<6 {
            if let date = calendar.date(byAdding: .month, value: -monthOffset, to: today) {
                let key = formatMonthKey(date)
                let count = sessions.filter {
                    calendar.isDate($0.startTime, equalTo: date, toGranularity: .month)
                }.count
                stats.monthlySessions[key] = count
            }
        }
        
        return stats
    }
    
    private func generateDailyData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var data: [ChartDataPoint] = []
        
        for dayOffset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let count = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: date) }.count
                data.append(ChartDataPoint(
                    date: date,
                    value: Double(count),
                    label: formatDayLabel(date)
                ))
            }
        }
        
        return data
    }
    
    private func generateWeeklyData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var data: [ChartDataPoint] = []
        
        for weekOffset in (0..<4).reversed() {
            if let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) {
                let count = sessions.filter {
                    calendar.isDate($0.startTime, equalTo: date, toGranularity: .weekOfYear)
                }.count
                data.append(ChartDataPoint(
                    date: date,
                    value: Double(count),
                    label: formatWeekLabel(date)
                ))
            }
        }
        
        return data
    }
    
    private func generateMonthlyData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var data: [ChartDataPoint] = []
        
        for monthOffset in (0..<6).reversed() {
            if let date = calendar.date(byAdding: .month, value: -monthOffset, to: today) {
                let count = sessions.filter {
                    calendar.isDate($0.startTime, equalTo: date, toGranularity: .month)
                }.count
                data.append(ChartDataPoint(
                    date: date,
                    value: Double(count),
                    label: formatMonthLabel(date)
                ))
            }
        }
        
        return data
    }
    
    // MARK: - Date Formatting
    
    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatWeekKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-'W'ww"
        return formatter.string(from: date)
    }
    
    private func formatMonthKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    private func formatDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func formatWeekLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatMonthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

enum TimeRange {
    case daily
    case weekly
    case monthly
}

struct DateRange {
    let startDate: Date
    let endDate: Date
    
    func contains(_ date: Date) -> Bool {
        return date >= startDate && date <= endDate
    }
}
