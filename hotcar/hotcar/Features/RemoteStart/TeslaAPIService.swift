//
//  TeslaAPIService.swift
//  hotcar
//
//  HotCar Service - Tesla API Integration
//  Remote climate control and vehicle status
//

import Foundation

final class TeslaAPIService {
    
    // MARK: - Singleton
    
    static let shared = TeslaAPIService()
    
    // MARK: - Constants
    
    private let baseURL = "https://owner-api.teslamotors.com"
    private let apiVersion = "2"
    
    // MARK: - Properties
    
    private var accessToken: String?
    private var vehicleID: Int64?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Authentication
    
    func authenticate(email: String, password: String) async throws -> String {
        // Note: This is a simplified example
        // In production, you would use OAuth 2.0 flow
        
        let urlString = "\(baseURL)/oauth/token"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "grant_type": "password",
            "client_id": "81527cff06844c8a39fffa1e88dc1487087d189a46ef54d8d4d1a3661002479d",
            "client_secret": "c7253eb7b747aaa1aa37e7727a58669b11e4f0c678c3be7895a9b7653e9004b1",
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.authenticationFailed
        }
        
        let decoder = JSONDecoder()
        let authResponse = try decoder.decode(AuthResponse.self, from: data)
        
        accessToken = authResponse.accessToken
        return authResponse.accessToken
    }
    
    // MARK: - Vehicle List
    
    func getVehicleList() async throws -> [TeslaVehicle] {
        guard let token = accessToken else {
            throw APIError.notAuthenticated
        }
        
        let urlString = "\(baseURL)/api/\(apiVersion)/vehicles"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }
        
        let decoder = JSONDecoder()
        let vehiclesResponse = try decoder.decode([TeslaVehicle].self, from: data)
        
        return vehiclesResponse
    }
    
    // MARK: - Climate Control
    
    func startClimate() async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        let urlString = "\(baseURL)/api/\(apiVersion)/vehicles/\(vehicleID)/command/climate/start"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.commandFailed
        }
    }
    
    func stopClimate() async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        let urlString = "\(baseURL)/api/\(apiVersion)/vehicles/\(vehicleID)/command/climate/stop"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.commandFailed
        }
    }
    
    // MARK: - Vehicle Status
    
    func getClimateState() async throws -> ClimateState {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        let urlString = "\(baseURL)/api/\(apiVersion)/vehicles/\(vehicleID)/data_request/climate_state"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }
        
        let decoder = JSONDecoder()
        let climateResponse = try decoder.decode(ClimateStateResponse.self, from: data)
        
        return climateResponse.response
    }
    
    // MARK: - Set Temperature
    
    func setTemperature(driver: Double, passenger: Double) async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        let urlString = "\(baseURL)/api/\(apiVersion)/vehicles/\(vehicleID)/command/climate/set_temp"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Double] = [
            "driver_temp": driver,
            "passenger_temp": passenger
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.commandFailed
        }
    }
    
    // MARK: - Preconditioning
    
    func startPreconditioning() async throws {
        try await startClimate()
    }
    
    // MARK: - Helper Methods
    
    func setVehicle(_ vehicle: TeslaVehicle) {
        vehicleID = vehicle.id
    }
    
    func setAccessToken(_ token: String?) {
        accessToken = token
    }
}

// MARK: - API Errors

extension TeslaAPIService {
    
    enum APIError: LocalizedError {
        case invalidURL
        case authenticationFailed
        case notAuthenticated
        case networkError
        case commandFailed
        case decodingError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .authenticationFailed:
                return "Authentication failed. Please check your credentials."
            case .notAuthenticated:
                return "Not authenticated. Please log in first."
            case .networkError:
                return "Network error occurred"
            case .commandFailed:
                return "Command failed. Please try again."
            case .decodingError:
                return "Failed to decode response"
            }
        }
    }
}

// MARK: - Response Models

extension TeslaAPIService {
    
    struct AuthResponse: Codable {
        let accessToken: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
        }
    }
    
    struct TeslaVehicle: Codable, Identifiable {
        let id: Int64
        let vin: String
        let displayName: String
        let color: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case vin
            case displayName = "display_name"
            case color
        }
    }
    
    struct ClimateState: Codable {
        let isClimateOn: Bool
        let insideTemp: Double
        let outsideTemp: Double
        let driverTempSetting: Double
        let passengerTempSetting: Double
        let isFrontDefrosterOn: Bool
        let isRearDefrosterOn: Bool
        let fanStatus: Int
        let isPreconditioning: Bool
        
        enum CodingKeys: String, CodingKey {
            case isClimateOn = "is_climate_on"
            case insideTemp = "inside_temp"
            case outsideTemp = "outside_temp"
            case driverTempSetting = "driver_temp_setting"
            case passengerTempSetting = "passenger_temp_setting"
            case isFrontDefrosterOn = "is_front_defroster_on"
            case isRearDefrosterOn = "is_rear_defroster_on"
            case fanStatus = "fan_status"
            case isPreconditioning = "is_preconditioning"
        }
    }
    
    struct ClimateStateResponse: Codable {
        let response: ClimateState
    }
}

// MARK: - Temperature Conversion

extension TeslaAPIService {
    
    /// Convert Celsius to Fahrenheit
    static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }
    
    /// Convert Fahrenheit to Celsius
    static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5/9
    }
}
