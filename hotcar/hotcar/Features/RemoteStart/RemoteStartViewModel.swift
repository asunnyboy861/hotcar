//
//  RemoteStartViewModel.swift
//  hotcar
//
//  HotCar Feature - Remote Start ViewModel
//  Manages Tesla and other OEM remote start functionality
//

import Foundation

@MainActor
final class RemoteStartViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAuthenticated: Bool = false
    @Published var isClimateOn: Bool = false
    @Published var insideTemperature: Double?
    @Published var outsideTemperature: Double?
    @Published var targetTemperature: Double = 21.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var vehicleName: String = ""
    
    // MARK: - Dependencies
    
    private let teslaService = TeslaAPIService.shared
    private let vehicleService = VehicleService.shared
    
    // MARK: - Initialization
    
    init() {
        checkAuthentication()
    }
    
    // MARK: - Public Methods
    
    func checkAuthentication() {
        // Check if we have stored credentials
        if let token = UserDefaults.standard.string(forKey: "tesla_access_token") {
            teslaService.setAccessToken(token)
            isAuthenticated = true
        }
    }
    
    func authenticate(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let token = try await teslaService.authenticate(email: email, password: password)
            teslaService.setAccessToken(token)
            
            // Store token securely (in production, use Keychain)
            UserDefaults.standard.set(token, forKey: "tesla_access_token")
            
            isAuthenticated = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func loadVehicles() async throws -> [TeslaAPIService.TeslaVehicle] {
        isLoading = true
        
        do {
            let vehicles = try await teslaService.getVehicleList()
            isLoading = false
            return vehicles
        } catch {
            isLoading = false
            throw error
        }
    }
    
    func selectVehicle(_ vehicle: TeslaAPIService.TeslaVehicle) {
        teslaService.setVehicle(vehicle)
        vehicleName = vehicle.displayName
    }
    
    func startClimate() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await teslaService.startClimate()
            isClimateOn = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func stopClimate() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await teslaService.stopClimate()
            isClimateOn = false
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func toggleClimate() async {
        if isClimateOn {
            await stopClimate()
        } else {
            await startClimate()
        }
    }
    
    func setTargetTemperature(_ temperature: Double) async {
        targetTemperature = temperature
        
        do {
            try await teslaService.setTemperature(
                driver: temperature,
                passenger: temperature
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func refreshClimateState() async {
        do {
            let climateState = try await teslaService.getClimateState()
            
            await MainActor.run {
                isClimateOn = climateState.isClimateOn
                insideTemperature = climateState.insideTemp
                outsideTemperature = climateState.outsideTemp
                targetTemperature = climateState.driverTempSetting
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func startPreconditioning() async {
        await startClimate()
    }
    
    func logout() {
        teslaService.setAccessToken(nil)
        UserDefaults.standard.removeObject(forKey: "tesla_access_token")
        isAuthenticated = false
        isClimateOn = false
        vehicleName = ""
    }
}
