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
    @Published var isLoading: Bool = false
    
    // MARK: - Constants
    
    private let cacheKey = "com.hotcar.cachedLocation"
    private let cacheTimestampKey = "com.hotcar.cachedLocationTimestamp"
    private let cacheValidDuration: TimeInterval = 3600 // 1 hour
    
    // Default location (New York City, US)
    private let defaultLocation = CLLocationCoordinate2D(
        latitude: 40.7128,
        longitude: -74.0060
    )
    
    // MARK: - Dependencies
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Don't load cached location on init - let it be requested explicitly
        // This ensures fresh location is fetched when needed
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
        
        isLoading = true
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLoading = false
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
    
    // MARK: - Location Retrieval Methods
    
    /// Get current location with fallback to cached or default
    func getCurrentLocation() -> CLLocationCoordinate2D {
        // If we have a recent location update, use it
        if let location = currentLocation {
            print("📍 Using currentLocation: lat=\(location.latitude), lon=\(location.longitude)")
            return location
        }
        
        // Check if cache is valid (not expired)
        if isCacheValid(), let cached = loadCachedLocation() {
            print("📍 Using cached location: lat=\(cached.latitude), lon=\(cached.longitude)")
            return cached
        }
        
        // If cache is invalid or not available, request fresh location
        print("📍 No valid location available, requesting fresh location...")
        if authorizationStatus == .notDetermined {
            print("📍 Requesting permission...")
            requestPermission()
        } else if authorizationStatus == .authorizedWhenInUse || 
                  authorizationStatus == .authorizedAlways {
            // Start updating to get fresh location
            print("📍 Starting location updates...")
            startUpdatingLocation()
        } else {
            print("📍 Authorization status: \(authorizationStatus.rawValue)")
        }
        
        // Return default location as last resort
        print("📍 Using default location (New York)")
        return defaultLocation
    }
    
    /// Force refresh location from GPS
    func forceRefreshLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            // Request permission if not determined
            if authorizationStatus == .notDetermined {
                requestPermission()
            }
            return
        }
        
        isLoading = true
        locationManager.requestLocation()
    }
    
    /// Check if location cache is valid
    func isCacheValid() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: cacheTimestampKey) as? Date else {
            return false
        }
        
        return Date().timeIntervalSince(timestamp) < cacheValidDuration
    }
    
    /// Clear cached location data
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimestampKey)
        currentLocation = nil  // Reset in-memory location
        print("🗑️ Location cache cleared (including currentLocation)")
    }
    
    // MARK: - Private Methods
    
    private func formatPlacemarkName(_ placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        // For US locations, show City, State
        if let city = placemark.locality {
            components.append(city)
        }
        
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        // Only add country if not US (for international users)
        if let countryCode = placemark.isoCountryCode, countryCode != "US" {
            if let country = placemark.country {
                components.append(country)
            }
        }
        
        return components.isEmpty ? "Unknown Location" : components.joined(separator: ", ")
    }
    
    private func cacheLocation(_ location: CLLocationCoordinate2D) {
        UserDefaults.standard.set(location.latitude, forKey: "\(cacheKey).latitude")
        UserDefaults.standard.set(location.longitude, forKey: "\(cacheKey).longitude")
        UserDefaults.standard.set(Date(), forKey: cacheTimestampKey)
    }
    
    private func loadCachedLocation() -> CLLocationCoordinate2D? {
        let latitude = UserDefaults.standard.double(forKey: "\(cacheKey).latitude")
        let longitude = UserDefaults.standard.double(forKey: "\(cacheKey).longitude")
        
        // Check if we have valid cached data
        guard latitude != 0 && longitude != 0 else { return nil }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        
        print("📍 LocationService updated: lat=\(location.latitude), lon=\(location.longitude)")
        
        Task {
            await MainActor.run {
                self.currentLocation = location
                self.isLoading = false
                self.cacheLocation(location)
            }
            
            await reverseGeocode()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
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
                    self.isLoading = false
                case .notDetermined:
                    self.errorMessage = nil
                @unknown default:
                    break
                }
            }
        }
    }
}
