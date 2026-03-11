//
//  VINDecoder.swift
//  hotcar
//
//  HotCar Service - VIN Decoder
//  Decodes Vehicle Identification Numbers
//

import Foundation

final class VINDecoder {
    
    // MARK: - Singleton
    
    static let shared = VINDecoder()
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    func decode(vin: String) async throws -> VINResult {
        // Validate VIN length
        guard vin.count == 17 else {
            throw VINErrror.invalidLength
        }
        
        // Use NHTSA API for VIN decoding
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/\(vin)?format=json"
        
        guard let url = URL(string: urlString) else {
            throw VINErrror.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw VINErrror.networkError
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(NHTSAResponse.self, from: data)
        
        return parseVINResponse(apiResponse)
    }
    
    // MARK: - Private Methods
    
    private func parseVINResponse(_ response: NHTSAResponse) -> VINResult {
        var result = VINResult()
        
        for variable in response.Results {
            switch variable.Variable {
            case "Make":
                result.make = variable.Value
            case "Model":
                result.model = variable.Value
            case "Model Year":
                result.year = Int(variable.Value)
            case "Plant Country":
                result.plantCountry = variable.Value
            case "Body Class":
                result.bodyClass = variable.Value
            case "Engine Type":
                result.engineType = variable.Value
            default:
                break
            }
        }
        
        return result
    }
}

// MARK: - VIN Result Model

extension VINDecoder {
    
    struct VINResult {
        var make: String?
        var model: String?
        var year: Int?
        var plantCountry: String?
        var bodyClass: String?
        var engineType: String?
    }
}

// MARK: - VIN Errors

extension VINDecoder {
    
    enum VINErrror: LocalizedError {
        case invalidLength
        case invalidURL
        case networkError
        case decodingError
        
        var errorDescription: String? {
            switch self {
            case .invalidLength:
                return "VIN must be 17 characters long"
            case .invalidURL:
                return "Invalid API URL"
            case .networkError:
                return "Network error occurred"
            case .decodingError:
                return "Failed to decode VIN data"
            }
        }
    }
}

// MARK: - NHTSA API Response Models

private struct NHTSAResponse: Codable {
    let Results: [NHTSAVariable]
}

private struct NHTSAVariable: Codable {
    let Variable: String
    let Value: String
}

// MARK: - VIN Validation

extension VINDecoder {
    
    func isValidVIN(_ vin: String) -> Bool {
        guard vin.count == 17 else { return false }
        
        // Check for valid characters (no I, O, Q)
        let invalidChars = CharacterSet(charactersIn: "IOQ")
        let vinChars = CharacterSet(charactersIn: vin.uppercased())
        
        return vinChars.isDisjoint(with: invalidChars)
    }
    
    func extractCheckDigit(_ vin: String) -> Character? {
        guard vin.count == 17 else { return nil }
        return vin[vin.index(vin.startIndex, offsetBy: 8)]
    }
    
    func validateCheckDigit(_ vin: String) -> Bool {
        guard vin.count == 17 else { return false }
        
        // VIN check digit algorithm implementation
        // This is a simplified version - full implementation would be more complex
        let weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
        let transliteration = [
            "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8,
            "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "P": 7, "R": 9,
            "S": 2, "T": 3, "U": 4, "V": 5, "W": 6, "X": 7, "Y": 8, "Z": 9
        ]
        
        var sum = 0
        for (index, char) in vin.uppercased().enumerated() {
            let value: Int
            if let digit = Int(String(char)) {
                value = digit
            } else if let letterValue = transliteration[String(char)] {
                value = letterValue
            } else {
                return false
            }
            
            sum += value * weights[index]
        }
        
        let remainder = sum % 11
        let checkDigit: Character
        if remainder == 10 {
            checkDigit = "X"
        } else {
            checkDigit = Character(String(remainder))
        }
        
        let actualCheckDigit = vin[vin.index(vin.startIndex, offsetBy: 8)]
        return checkDigit == actualCheckDigit
    }
}
