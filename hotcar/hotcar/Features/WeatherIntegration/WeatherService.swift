//
//  WeatherService.swift
//  hotcar
//
//  HotCar Service - Weather Integration
//  Fetches weather data from Open-Meteo API
//

import Foundation

final class WeatherService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = WeatherService()
    
    // MARK: - Published Properties
    
    @Published var currentTemperature: Double?
    @Published var tomorrowMorningTemp: Double?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    
    // MARK: - Constants
    
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    
    // MARK: - Dependencies
    
    private let locationService = LocationService.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    @MainActor
    func fetchCurrentTemperature() async {
        isLoading = true
        errorMessage = nil
        
        // Get location from LocationService
        let location = locationService.getCurrentLocation()
        
        print("📍 HotCar Location: lat=\(location.latitude), lon=\(location.longitude)")
        
        let urlString = "\(baseURL)?latitude=\(location.latitude)&longitude=\(location.longitude)&current_weather=true&temperature_unit=fahrenheit"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "Server error"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let weatherData = try decoder.decode(WeatherResponse.self, from: data)
            
            await MainActor.run {
                self.currentTemperature = weatherData.currentWeather.temperature
                self.lastUpdateTime = Date()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func fetchTomorrowMorningTemperature() async {
        let location = locationService.getCurrentLocation()
        
        let urlString = "\(baseURL)?latitude=\(location.latitude)&longitude=\(location.longitude)&hourly=temperature_2m&forecast_days=2&temperature_unit=fahrenheit"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return
            }
            
            let decoder = JSONDecoder()
            let weatherData = try decoder.decode(HourlyWeatherResponse.self, from: data)
            
            // Get temperature for 7 AM tomorrow
            let tomorrow7AM = Calendar.current.startOfDay(for: Date())
                .addingTimeInterval(24 * 60 * 60 + 7 * 60 * 60)
            
            if let index = weatherData.hourly.time.firstIndex(where: { $0 >= tomorrow7AM }) {
                await MainActor.run {
                    self.tomorrowMorningTemp = weatherData.hourly.temperature[index]
                }
            }
        } catch {
            print("Error fetching tomorrow's temperature: \(error)")
        }
    }
    
    /// Refresh weather data with fresh location
    @MainActor
    func refreshWeatherWithLocation() async {
        // Force refresh location
        locationService.forceRefreshLocation()
        
        // Wait a bit for location update
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Fetch weather
        await fetchCurrentTemperature()
        await fetchTomorrowMorningTemperature()
    }
    
    /// Get temperature in specified unit
    func getTemperatureInUnit(_ celsius: Double, unit: AppSettings.TemperatureUnit) -> Double {
        return unit.convert(from: celsius)
    }
}

// MARK: - Weather Response Models

struct WeatherResponse: Codable {
    let currentWeather: CurrentWeather
    
    enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
    }
}

struct CurrentWeather: Codable {
    let temperature: Double
}

struct HourlyWeatherResponse: Codable {
    let hourly: HourlyData
}

struct HourlyData: Codable {
    let time: [Date]
    let temperature: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
    }
}
