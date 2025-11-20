//
//  WeatherViewModel.swift
//  WeatherBuddy
//
//  Created by Alon Raz Levi on 16/11/2025.
//

import Foundation
import Combine
import CoreLocation

@MainActor
class MainWeatherViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var location = AppConstants.Weather.defaultLocation
    @Published var currentTemperature = AppConstants.Weather.defaultTemperature
    @Published var currentWeatherIndex: RiveWeatherIndex = .sunny
    @Published var currentDay: RiveDayOfWeek = .sunday
    @Published var forecast: [ForecastItem] = []
    @Published var currentHour: Int = 12
    @Published var timeSection: RiveTimeSection = .afternoon
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCelsius = false
    @Published var isUsingCurrentLocation = false
    
    // MARK: - Dependencies
    
    let locationManager = LocationManager()
    private let weatherService = WeatherService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        updateCurrentTime()
        setupLocationObserver()
        
        Task {
            await loadWeather()
        }
    }
    
    // MARK: - Location Observing
    
    private func setupLocationObserver() {
        // Observe location updates
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                Task { @MainActor in
                    await self?.loadWeatherForCoordinates(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
            .store(in: &cancellables)
        
        // Observe location name updates
        locationManager.$locationName
            .compactMap { $0 }
            .sink { [weak self] name in
                self?.location = name
            }
            .store(in: &cancellables)
        
        // Observe authorization status changes
        locationManager.$authorizationStatus
            .dropFirst() // Skip initial value
            .sink { [weak self] status in
                guard let self = self else { return }
                
                // When permission is granted, automatically request location
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.locationManager.requestLocation()
                    self.isUsingCurrentLocation = true
                } else if status == .denied || status == .restricted {
                    self.errorMessage = "Location access denied. Please enable it in Settings."
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func requestCurrentLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Request permission - authorization observer will handle location request
            locationManager.requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission already granted, request location
            locationManager.requestLocation()
            isUsingCurrentLocation = true
        case .denied, .restricted:
            // Permission denied, show error
            errorMessage = "Location access denied. Please enable it in Settings."
        @unknown default:
            errorMessage = "Unable to access location"
        }
    }
    
    func updateCurrentTime() {
        let calendar = Calendar.current
        let now = Date()
        currentHour = calendar.component(.hour, from: now)
        timeSection = RiveTimeSection.from(hour: currentHour)
        currentDay = RiveDayOfWeek.from(date: now)
    }
    
    func loadWeather() async {
        isUsingCurrentLocation = false
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await weatherService.getWeatherForLocation(location)
            processWeatherResponse(response)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadWeatherForCoordinates(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await weatherService.fetchWeather(latitude: latitude, longitude: longitude)
            processWeatherResponse(response)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func processWeatherResponse(_ response: WeatherResponse) {
        let currentTemp = response.current.temp
        let currentWeatherId = response.current.weather.first?.id ?? 800
        currentTemperature = currentTemp
        let newWeatherIndex = RiveWeatherIndex.from(weatherId: currentWeatherId, temperature: currentTemp)
        
        currentWeatherIndex = newWeatherIndex
        updateCurrentTime()
        
        forecast = response.daily.prefix(AppConstants.Weather.totalForecastDays).enumerated().map { index, daily in
            let date = Date(timeIntervalSince1970: TimeInterval(daily.dt))
            let day = RiveDayOfWeek.from(date: date)
            
            let temperature: Double
            let weatherId: Int
            let weatherIndex: RiveWeatherIndex
            
            if index == 0 {
                temperature = currentTemp
                weatherId = currentWeatherId
                weatherIndex = newWeatherIndex
            } else {
                temperature = (daily.temp.min + daily.temp.max) / 2
                weatherId = daily.weather.first?.id ?? 800
                weatherIndex = RiveWeatherIndex.from(weatherId: weatherId, temperature: temperature)
            }
            
            return ForecastItem(
                temperature: temperature,
                minTemp: daily.temp.min,
                maxTemp: daily.temp.max,
                weatherIndex: weatherIndex,
                day: day,
                date: date
            )
        }
    }
    
    func toggleUnit() {
        isCelsius.toggle()
        if isCelsius {
            currentTemperature = fahrenheitToCelsius(currentTemperature)
            forecast = forecast.map { item in
                ForecastItem(
                    temperature: fahrenheitToCelsius(item.temperature),
                    minTemp: fahrenheitToCelsius(item.minTemp),
                    maxTemp: fahrenheitToCelsius(item.maxTemp),
                    weatherIndex: item.weatherIndex,
                    day: item.day,
                    date: item.date
                )
            }
        } else {
            currentTemperature = celsiusToFahrenheit(currentTemperature)
            forecast = forecast.map { item in
                ForecastItem(
                    temperature: celsiusToFahrenheit(item.temperature),
                    minTemp: celsiusToFahrenheit(item.minTemp),
                    maxTemp: celsiusToFahrenheit(item.maxTemp),
                    weatherIndex: item.weatherIndex,
                    day: item.day,
                    date: item.date
                )
            }
        }
    }
    
    // MARK: - Temperature Conversion
    
    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }
    
    private func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5/9
    }
}
