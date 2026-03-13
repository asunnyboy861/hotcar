//
//  VehicleAPIProtocol.swift
//  hotcar
//
//  HotCar - Unified Vehicle API Protocol
//  Abstracts different vehicle brand APIs into a single interface
//

import Foundation

protocol VehicleAPIProtocol {
    
    var isAuthenticated: Bool { get }
    
    func authenticate(email: String, password: String) async throws -> String
    
    func startClimate() async throws
    
    func stopClimate() async throws
    
    func getClimateState() async throws -> ClimateState
    
    func setAccessToken(_ token: String?)
    
    func logout()
}

enum VehicleBrand: String, CaseIterable, Codable {
    case tesla = "Tesla"
    case ford = "Ford"
    case gm = "GM"
    case toyota = "Toyota"
    
    var displayName: String {
        return rawValue
    }
    
    var iconName: String {
        switch self {
        case .tesla: return "car.2.fill"
        case .ford: return "car.fill"
        case .gm: return "car.side.fill"
        case .toyota: return "car.2.fill"
        }
    }
    
    var authURL: String {
        switch self {
        case .tesla: return "https://owner-api.teslamotors.com/oauth/token"
        case .ford: return "https://usapi.cv.ford.com/api/oauth/v2/token"
        case .gm: return "https://api.gm.com/oauth/v2/token"
        case .toyota: return "https://api.toyota.com/oauth/v2/token"
        }
    }
}

enum VehicleAPIError: LocalizedError {
    case notAuthenticated
    case authenticationFailed
    case tokenExpired
    case commandFailed
    case networkError
    case invalidURL
    case decodingError
    case unsupportedBrand
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please log in first."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .tokenExpired:
            return "Session expired. Please log in again."
        case .commandFailed:
            return "Command failed. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidURL:
            return "Invalid API URL"
        case .decodingError:
            return "Failed to parse response"
        case .unsupportedBrand:
            return "This vehicle brand is not supported yet."
        }
    }
}

// MARK: - Climate State

public struct ClimateState {
    public let isClimateOn: Bool
    public let insideTemp: Double?
    public let outsideTemp: Double?
    
    public init(isClimateOn: Bool, insideTemp: Double?, outsideTemp: Double?) {
        self.isClimateOn = isClimateOn
        self.insideTemp = insideTemp
        self.outsideTemp = outsideTemp
    }
    
    public static let empty = ClimateState(isClimateOn: false, insideTemp: nil, outsideTemp: nil)
}

// MARK: - API Factory

final class VehicleAPIFactory {
    
    static let shared = VehicleAPIFactory()
    
    private init() {}
    
    func getAPI(for brand: VehicleBrand) -> Any {
        switch brand {
        case .tesla:
            return TeslaAPIService.shared
        case .ford:
            return FordAPIService.shared
        case .gm:
            return GMAPIService.shared
        case .toyota:
            return ToyotaAPIService.shared
        }
    }
    
    func detectBrand(from apiToken: String?) -> VehicleBrand? {
        guard let token = apiToken, !token.isEmpty else {
            return nil
        }
        
        if token.hasPrefix("tesla_") {
            return .tesla
        } else if token.hasPrefix("ford_") {
            return .ford
        } else if token.hasPrefix("gm_") {
            return .gm
        } else if token.hasPrefix("toyota_") {
            return .toyota
        }
        
        return nil
    }
}
