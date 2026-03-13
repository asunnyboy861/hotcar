//
//  WeatherService.swift
//  hotcar
//
//  HotCar Service - Weather Integration
//  Fetches weather data from Open-Meteo API
//

import Foundation

// MARK: - Weather Error

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)
    case locationPermissionDenied
    case locationUnavailable
    case noCachedData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather service URL"
        case .networkError:
            return "Network connection failed. Please check your internet connection."
        case .serverError(let code):
            return "Weather service unavailable (Error \(code)). Please try again later."
        case .decodingError:
            return "Failed to parse weather data"
        case .locationPermissionDenied:
            return "Location access is required for accurate weather data"
        case .locationUnavailable:
            return "Unable to determine your location"
        case .noCachedData:
            return "No cached weather data available"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .locationPermissionDenied:
            return "Please enable location access in Settings > Privacy > Location Services"
        case .networkError, .serverError:
            return "Pull down to refresh or check your connection"
        case .locationUnavailable:
            return "Please check your location settings and try again"
        default:
            return nil
        }
    }
}

final class WeatherService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = WeatherService()
    
    // MARK: - Published Properties
    
    @Published var currentTemperature: Double?
    @Published var tomorrowMorningTemp: Double?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    
    /// Current error state
    @Published var currentError: WeatherError?
    
    /// Whether to show error alert (used to trigger alert)
    @Published var showError: Bool = false
    
    /// Whether using cached/default fallback data
    @Published var isUsingFallbackData: Bool = false
    
    // MARK: - Constants
    
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let weatherCacheKey = "com.hotcar.weather.cache"
    private let weatherCacheTimestampKey = "com.hotcar.weather.cacheTimestamp"
    private let cacheValidDuration: TimeInterval = 3600 // 1 hour
    
    // MARK: - Dependencies
    
    private let locationService = LocationService.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    @MainActor
    func fetchCurrentTemperature() async {
        isLoading = true
        errorMessage = nil
        currentError = nil
        isUsingFallbackData = false
        
        // Check location permission using LocationService
        let authStatus = LocationService.shared.authorizationStatus
        guard authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways else {
            if authStatus == .denied || authStatus == .restricted {
                handleError(.locationPermissionDenied)
            } else {
                handleError(.locationUnavailable)
            }
            useCachedDataOrDefault()
            return
        }
        
        // Get location from LocationService
        let location = locationService.getCurrentLocation()
        
        print("📍 HotCar Location: lat=\(location.latitude), lon=\(location.longitude)")
        
        let urlString = "\(baseURL)?latitude=\(location.latitude)&longitude=\(location.longitude)&current_weather=true&temperature_unit=celsius"
        
        guard let url = URL(string: urlString) else {
            handleError(.invalidURL)
            useCachedDataOrDefault()
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                handleError(.networkError(NSError(domain: "Invalid response", code: -1)))
                useCachedDataOrDefault()
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                handleError(.serverError(httpResponse.statusCode))
                useCachedDataOrDefault()
                return
            }
            
            let decoder = JSONDecoder()
            let weatherData = try decoder.decode(WeatherResponse.self, from: data)
            
            currentTemperature = weatherData.currentWeather.temperature
            cacheTemperature(weatherData.currentWeather.temperature)
            lastUpdateTime = Date()
            isLoading = false
            
        } catch let decodingError as DecodingError {
            handleError(.decodingError(decodingError))
            useCachedDataOrDefault()
        } catch {
            handleError(.networkError(error))
            useCachedDataOrDefault()
        }
    }
    
    @MainActor
    func fetchTomorrowMorningTemperature() async {
        let location = locationService.getCurrentLocation()
        
        let urlString = "\(baseURL)?latitude=\(location.latitude)&longitude=\(location.longitude)&hourly=temperature_2m&forecast_days=2&temperature_unit=celsius"
        
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
            
            // Get temperature for 7 AM tomorrow using parsed dates
            let tomorrow7AM = Calendar.current.startOfDay(for: Date())
                .addingTimeInterval(24 * 60 * 60 + 7 * 60 * 60)
            
            let dates = weatherData.hourly.parsedDates
            if let index = dates.firstIndex(where: { $0 >= tomorrow7AM }) {
                self.tomorrowMorningTemp = weatherData.hourly.temperature[index]
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
    
    // MARK: - Private Methods
    
    private func handleError(_ error: WeatherError) {
        currentError = error
        showError = true
        isLoading = false
        print("WeatherService Error: \(error.localizedDescription)")
    }
    
    private func cacheTemperature(_ temperature: Double) {
        UserDefaults.standard.set(temperature, forKey: weatherCacheKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: weatherCacheTimestampKey)
    }
    
    private func useCachedDataOrDefault() {
        isUsingFallbackData = true
        
        // Try to use cached data
        if let cached = UserDefaults.standard.object(forKey: weatherCacheKey) as? Double,
           let timestamp = UserDefaults.standard.object(forKey: weatherCacheTimestampKey) as? TimeInterval {
            let cacheDate = Date(timeIntervalSince1970: timestamp)
            // Cache valid for 1 hour
            if Date().timeIntervalSince(cacheDate) < cacheValidDuration {
                currentTemperature = cached
                return
            }
        }
        
        // Use default temperature (0°C)
        currentTemperature = 0
        if currentError == nil {
            currentError = .noCachedData
        }
    }
    
    /// Clear error state (used after user manually dismisses error alert)
    func clearError() {
        currentError = nil
        showError = false
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
    let time: [String]  // ISO 8601 format strings like "2024-01-15T07:00"
    let temperature: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
    }
    
    /// Parse ISO 8601 strings to Date objects
    /// Note: Open-Meteo returns format "yyyy-MM-dd'T'HH:mm" without seconds
    var parsedDates: [Date] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        return time.compactMap { formatter.date(from: $0) }
    }
}
