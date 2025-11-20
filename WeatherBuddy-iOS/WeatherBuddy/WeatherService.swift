//
//  WeatherService.swift
//  WeatherBuddy
//
//  Created by Alon Raz Levi on 16/11/2025.
//

import Foundation
import CoreLocation

// MARK: - Weather Models
struct WeatherResponse: Codable {
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
    
    struct CurrentWeather: Codable {
        let temp: Double
        let weather: [WeatherCondition]
    }
    
    struct HourlyWeather: Codable {
        let dt: Int
        let temp: Double
        let weather: [WeatherCondition]
    }
    
    struct DailyWeather: Codable {
        let dt: Int
        let temp: Temperature
        let weather: [WeatherCondition]
        
        struct Temperature: Codable {
            let min: Double
            let max: Double
        }
    }
    
    struct WeatherCondition: Codable {
        let id: Int
        let main: String
        let description: String
    }
}

// MARK: - Weather Service (Using Open-Meteo - Free, No API Key!)
class WeatherService: ObservableObject {
    // Using Open-Meteo: Free, no API key, no registration needed!
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        // Open-Meteo API: Free, no API key needed!
        // Request temperature in Fahrenheit
        let urlString = "\(baseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code&hourly=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,weather_code&temperature_unit=fahrenheit&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherError.invalidResponse
        }
        
        // Parse response
        let decoder = JSONDecoder()
        let openMeteoResponse = try decoder.decode(OpenMeteoResponse.self, from: data)
        
        // Convert to our app's format
        return convertOpenMeteoToWeatherResponse(openMeteoResponse)
    }
    
    func getWeatherForLocation(_ location: String) async throws -> WeatherResponse {
        // Use geocoding to convert location name to coordinates
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(location)
        
        guard let coordinate = placemarks.first?.location?.coordinate else {
            throw WeatherError.locationNotFound
        }
        
        return try await fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// MARK: - Open-Meteo API Models (Free, No API Key!)
struct OpenMeteoResponse: Codable {
    let current: Current
    let hourly: Hourly
    let daily: Daily
    
    struct Current: Codable {
        let temperature_2m: Double
        let weather_code: Int
    }
    
    struct Hourly: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let weather_code: [Int]
    }
    
    struct Daily: Codable {
        let time: [String]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let weather_code: [Int]
    }
}

// MARK: - Conversion Helper
extension WeatherService {
    private func convertOpenMeteoToWeatherResponse(_ response: OpenMeteoResponse) -> WeatherResponse {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate]
        
        // Date formatter for daily dates (YYYY-MM-DD format only)
        let dailyDateFormatter = DateFormatter()
        dailyDateFormatter.dateFormat = "yyyy-MM-dd"
        dailyDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Convert current weather
        let weatherId = convertWMOCodeToOpenWeatherMapID(response.current.weather_code)
        let currentWeather = WeatherResponse.CurrentWeather(
            temp: response.current.temperature_2m,
            weather: [WeatherResponse.WeatherCondition(
                id: weatherId,
                main: getWeatherMain(from: weatherId),
                description: getWeatherDescription(from: weatherId)
            )]
        )
        
        // Convert hourly forecast
        let hourly = zip(response.hourly.time, zip(response.hourly.temperature_2m, response.hourly.weather_code))
            .prefix(24)
            .map { (timeString, tempAndCode) in
                let (temp, wmoCode) = tempAndCode
                let weatherId = convertWMOCodeToOpenWeatherMapID(wmoCode)
                let timestamp = dateFormatter.date(from: timeString)?.timeIntervalSince1970 ?? 0
                
                return WeatherResponse.HourlyWeather(
                    dt: Int(timestamp),
                    temp: temp,
                    weather: [WeatherResponse.WeatherCondition(
                        id: weatherId,
                        main: getWeatherMain(from: weatherId),
                        description: getWeatherDescription(from: weatherId)
                    )]
                )
            }
        
        // Convert daily forecast
        let daily = zip(response.daily.time, zip(response.daily.temperature_2m_max, zip(response.daily.temperature_2m_min, response.daily.weather_code)))
            .enumerated()
            .map { (index, element) in
                let (timeString, data) = element
                let (maxTemp, minAndCode) = data
                let (minTemp, wmoCode) = minAndCode
                let weatherId = convertWMOCodeToOpenWeatherMapID(wmoCode)
                let timestamp = dailyDateFormatter.date(from: timeString)?.timeIntervalSince1970 ?? 0
                
                return WeatherResponse.DailyWeather(
                    dt: Int(timestamp),
                    temp: WeatherResponse.DailyWeather.Temperature(
                        min: minTemp,
                        max: maxTemp
                    ),
                    weather: [WeatherResponse.WeatherCondition(
                        id: weatherId,
                        main: getWeatherMain(from: weatherId),
                        description: getWeatherDescription(from: weatherId)
                    )]
                )
            }
        
        return WeatherResponse(
            current: currentWeather,
            hourly: Array(hourly),
            daily: Array(daily)
        )
    }
    
    // Convert WMO weather codes to OpenWeatherMap IDs for compatibility
    private func convertWMOCodeToOpenWeatherMapID(_ wmoCode: Int) -> Int {
        switch wmoCode {
        case 0: return 800  // Clear
        case 1, 2: return 801  // Partly cloudy
        case 3: return 804  // Overcast
        case 45, 48: return 741  // Fog
        case 51, 53, 55: return 300  // Drizzle
        case 61, 63, 65: return 500  // Rain
        case 71, 73, 75, 77: return 600  // Snow
        case 80, 81, 82: return 520  // Shower
        case 85, 86: return 620  // Snow shower
        case 95, 96, 99: return 200  // Thunderstorm
        default: return 800  // Default to clear
        }
    }
    
    private func getWeatherMain(from id: Int) -> String {
        switch id {
        case 200...299: return "Thunderstorm"
        case 300...399: return "Drizzle"
        case 500...599: return "Rain"
        case 600...699: return "Snow"
        case 700...799: return "Atmosphere"
        case 800: return "Clear"
        case 801...804: return "Clouds"
        default: return "Clear"
        }
    }
    
    private func getWeatherDescription(from id: Int) -> String {
        switch id {
        case 200: return "thunderstorm with light rain"
        case 201: return "thunderstorm with rain"
        case 300: return "light drizzle"
        case 500: return "light rain"
        case 600: return "light snow"
        case 741: return "fog"
        case 800: return "clear sky"
        case 801: return "few clouds"
        case 804: return "overcast clouds"
        default: return "clear sky"
        }
    }
}

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case locationNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server. Please check your internet connection."
        case .locationNotFound:
            return "Location not found"
        }
    }
}





