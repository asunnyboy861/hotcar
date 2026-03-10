//
//  LocationService.swift
//  hotcar
//
//  HotCar Service - Location Services
//  Handles user location for weather integration
//

import Foundation
import CoreLocation

final class LocationService: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = LocationService()
    
    // MARK: - Published Properties
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationName: String = "Unknown Location"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // MARK: - Public Methods
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            errorMessage = "Location permission not granted"
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func reverseGeocode() async {
        guard let location = currentLocation else { return }
        
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: location.latitude, longitude: location.longitude)
            )
            
            if let placemark = placemarks.first {
                await MainActor.run {
                    self.locationName = formatPlacemarkName(placemark)
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func formatPlacemarkName(_ placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let city = placemark.locality {
            components.append(city)
        }
        
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        
        Task {
            await MainActor.run {
                self.currentLocation = location
            }
            
            await reverseGeocode()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task {
            await MainActor.run {
                self.authorizationStatus = manager.authorizationStatus
                
                switch manager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.errorMessage = nil
                    startUpdatingLocation()
                case .denied, .restricted:
                    self.errorMessage = "Location access denied"
                case .notDetermined:
                    self.errorMessage = nil
                @unknown default:
                    break
                }
            }
        }
    }
}
