//
//  FordAPIService.swift
//  hotcar
//
//  HotCar Service - Ford API Integration
//  Remote climate control and vehicle status for Ford vehicles
//  Uses FordPass API
//

import Foundation
import Security

final class FordAPIService {
    
    // MARK: - Singleton
    
    static let shared = FordAPIService()
    
    // MARK: - Constants
    
    private let baseURL = "https://usapi.cv.ford.com/api"
    private let apiVersion = "v1"
    
    // MARK: - Properties
    
    private var accessToken: String?
    private var vehicleID: String?
    
    // MARK: - Keychain Keys
    
    private let keychainService = "com.hotcar.ford"
    private let tokenKey = "ford_access_token"
    private let vehicleKey = "ford_vehicle_id"
    
    // MARK: - Initialization
    
    private init() {
        loadTokenFromKeychain()
    }
    
    // MARK: - Keychain Operations
    
    private func saveTokenToKeychain(_ token: String) {
        let data = Data(token.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    private func loadTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data, let token = String(data: data, encoding: .utf8) {
            accessToken = token
        }
    }
    
    // MARK: - Authentication
    
    func authenticate(email: String, password: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/oauth/v2/token") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("en-US", forHTTPHeaderField: "Accept-Language")
        
        let body: [String: Any] = [
            "grant_type": "password",
            "client_id": "9fb503e0-715b-47e8-adbf-b2b49406c977",
            "client_secret": "A8B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7",
            "username": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.authenticationFailed
            }
            throw APIError.authenticationFailed
        }
        
        let decoder = JSONDecoder()
        let authResponse = try decoder.decode(FordAuthResponse.self, from: data)
        
        accessToken = authResponse.accessToken
        saveTokenToKeychain(authResponse.accessToken)
        
        return authResponse.accessToken
    }
    
    // MARK: - Vehicle List
    
    func getVehicleList() async throws -> [FordVehicle] {
        guard let token = accessToken else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(apiVersion)/vehicles") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("en-US", forHTTPHeaderField: "Accept-Language")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.tokenExpired
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }
        
        let decoder = JSONDecoder()
        let vehiclesResponse = try decoder.decode(FordVehiclesResponse.self, from: data)
        
        return vehiclesResponse.vehicles
    }
    
    // MARK: - Climate Control
    
    func startClimate() async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(apiVersion)/vehicles/\(vehicleID)/engine/start") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.tokenExpired
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.commandFailed
        }
    }
    
    func stopClimate() async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(apiVersion)/vehicles/\(vehicleID)/engine/stop") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.tokenExpired
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.commandFailed
        }
    }
    
    // MARK: - Vehicle Status
    
    func getClimateState() async throws -> ClimateState {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(apiVersion)/vehicles/\(vehicleID)/status") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.tokenExpired
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }
        
        let decoder = JSONDecoder()
        let statusResponse = try decoder.decode(FordStatusResponse.self, from: data)
        
        let isEngineOn = statusResponse.vehicleStatus.engineStatus == "engineRunning"
        
        return ClimateState(
            isClimateOn: isEngineOn,
            insideTemp: statusResponse.vehicleStatus.cabinTemperature,
            outsideTemp: statusResponse.vehicleStatus.ambientTemperature
        )
    }
    
    // MARK: - Set Temperature
    
    func setTemperature(driver: Double, passenger: Double) async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(apiVersion)/vehicles/\(vehicleID)/climate/set") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "driverTemp": driver,
            "passengerTemp": passenger
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.commandFailed
        }
    }
    
    // MARK: - Helper Methods
    
    func setVehicle(_ vehicle: FordVehicle) {
        vehicleID = vehicle.vehicleId
        saveVehicleIDToKeychain(vehicle.vehicleId)
    }
    
    func setAccessToken(_ token: String?) {
        accessToken = token
        if let token = token {
            saveTokenToKeychain(token)
        }
    }
    
    var isAuthenticated: Bool {
        return accessToken != nil
    }
    
    private func saveVehicleIDToKeychain(_ vehicleID: String) {
        let data = Data(vehicleID.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: vehicleKey
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: vehicleKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    func logout() {
        accessToken = nil
        vehicleID = nil
        
        let tokenQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(tokenQuery as CFDictionary)
        
        let vehicleQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: vehicleKey
        ]
        SecItemDelete(vehicleQuery as CFDictionary)
    }
}

// MARK: - API Errors

extension FordAPIService {
    
    enum APIError: LocalizedError {
        case invalidURL
        case authenticationFailed
        case notAuthenticated
        case tokenExpired
        case networkError
        case commandFailed
        case decodingError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .authenticationFailed:
                return "Authentication failed. Please check your FordPass credentials."
            case .notAuthenticated:
                return "Not authenticated. Please log in to FordPass first."
            case .tokenExpired:
                return "Session expired. Please log in again."
            case .networkError:
                return "Network error. Please check your connection."
            case .commandFailed:
                return "Command failed. Please try again."
            case .decodingError:
                return "Failed to parse response"
            }
        }
    }
}

// MARK: - Response Models

private struct FordAuthResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

private struct FordVehiclesResponse: Codable {
    let vehicles: [FordVehicle]
}

struct FordVehicle: Codable, Identifiable {
    let vehicleId: String
    let vin: String
    let year: Int
    let make: String
    let model: String
    let nickname: String?
    
    var id: String { vehicleId }
}

private struct FordStatusResponse: Codable {
    let vehicleStatus: FordVehicleStatus
}

private struct FordVehicleStatus: Codable {
    let engineStatus: String
    let cabinTemperature: Double?
    let ambientTemperature: Double?
    let doorLockStatus: String?
    let batteryStatus: Double?
}
