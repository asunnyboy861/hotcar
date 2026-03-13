//
//  GMAPIService.swift
//  hotcar
//
//  HotCar Service - GM API Integration
//  Remote climate control and vehicle status for GM vehicles
//  Uses myChevrolet / GM API
//

import Foundation
import Security

final class GMAPIService {
    
    // MARK: - Singleton
    
    static let shared = GMAPIService()
    
    // MARK: - Constants
    
    private let baseURL = "https://api.gm.com/vehicles/v1"
    private let authURL = "https://api.gm.com/oauth/v2/token"
    
    // MARK: - Properties
    
    private var accessToken: String?
    private var vehicleID: String?
    
    // MARK: - Keychain Keys
    
    private let keychainService = "com.hotcar.gm"
    private let tokenKey = "gm_access_token"
    private let vehicleKey = "gm_vehicle_id"
    
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
        guard let url = URL(string: authURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "grant_type": "password",
            "client_id": "GM_MOBILE_APP_CLIENT_ID",
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
        let authResponse = try decoder.decode(GMAuthResponse.self, from: data)
        
        accessToken = authResponse.accessToken
        saveTokenToKeychain(authResponse.accessToken)
        
        return authResponse.accessToken
    }
    
    // MARK: - Vehicle List
    
    func getVehicleList() async throws -> [GMVehicle] {
        guard let token = accessToken else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
        let vehiclesResponse = try decoder.decode(GMVehiclesResponse.self, from: data)
        
        return vehiclesResponse.vehicles
    }
    
    // MARK: - Climate Control
    
    func startClimate() async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(vehicleID)/commands/remote-start") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "command": [
                "type": "remoteStart"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
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
        
        guard let url = URL(string: "\(baseURL)/\(vehicleID)/commands/remote-stop") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "command": [
                "type": "remoteStop"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
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
        
        guard let url = URL(string: "\(baseURL)/\(vehicleID)/status") else {
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
        let statusResponse = try decoder.decode(GMStatusResponse.self, from: data)
        
        let isEngineOn = statusResponse.vehicleStatus?.engineStatus?.value == "RUNNING"
        
        return ClimateState(
            isClimateOn: isEngineOn,
            insideTemp: statusResponse.vehicleStatus?.cabinTemperature,
            outsideTemp: statusResponse.vehicleStatus?.ambientTemperature
        )
    }
    
    // MARK: - Set Temperature
    
    func setTemperature(driver: Double, passenger: Double) async throws {
        guard let token = accessToken,
              let vehicleID = vehicleID else {
            throw APIError.notAuthenticated
        }
        
        guard let url = URL(string: "\(baseURL)/\(vehicleID)/climate/set-temp") else {
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
    
    func setVehicle(_ vehicle: GMVehicle) {
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

extension GMAPIService {
    
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
                return "Authentication failed. Please check your myChevrolet credentials."
            case .notAuthenticated:
                return "Not authenticated. Please log in to myChevrolet first."
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

private struct GMAuthResponse: Codable {
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

private struct GMVehiclesResponse: Codable {
    let vehicles: [GMVehicle]
}

struct GMVehicle: Codable, Identifiable {
    let vehicleId: String
    let vin: String
    let year: Int
    let make: String
    let model: String
    let nickname: String?
    
    var id: String { vehicleId }
}

private struct GMStatusResponse: Codable {
    let vehicleStatus: GMVehicleStatus?
}

private struct GMVehicleStatus: Codable {
    let engineStatus: GMEngineStatus?
    let cabinTemperature: Double?
    let ambientTemperature: Double?
    let doorLockStatus: String?
    let batteryStatus: Double?
}

private struct GMEngineStatus: Codable {
    let value: String?
}
