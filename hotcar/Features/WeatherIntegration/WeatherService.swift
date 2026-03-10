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
    
    // MARK: - Constants
    
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    @MainActor
    func fetchCurrentTemperature() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement location services to get lat/lon
        // For now, using Toronto as default
        let latitude = 43.6532
        let longitude = -79.3832
        
        let urlString = "\(baseURL)?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
        
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
        // TODO: Implement location services to get lat/lon
        let latitude = 43.6532
        let longitude = -79.3832
        
        let urlString = "\(baseURL)?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m&forecast_days=2"
        
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
