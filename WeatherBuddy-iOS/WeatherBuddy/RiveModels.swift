//
//  RiveModels.swift
//  WeatherBuddy
//
//  Created by Alon Raz Levi on 16/11/2025.
//

import Foundation

// MARK: - Rive Enums (matching actual Rive file artboards)
enum RiveWeatherIndex: Double {
    case sunny = 0
    case rain = 1
    case snow = 2
    case heatwave = 3
    
    static func from(weatherId: Int, temperature: Double) -> RiveWeatherIndex {
        // Use temperature to differentiate between sunny and heatwave
        switch weatherId {
        case 200...299: // Thunderstorm -> Rain with storm
            return .rain
        case 300...599: // Drizzle and Rain
            return .rain
        case 600...699: // Snow
            return .snow
        case 701...781: // Atmosphere (mist, fog, etc.)
            return .rain
        case 800: // Clear
            return temperature > 86 ? .heatwave : .sunny  // 86°F (30°C)
        case 801...804: // Clouds
            return .sunny
        default:
            return .sunny
        }
    }
    
    var description: String {
        switch self {
        case .sunny: return "Clear Skies"  // Changed from "Sunny" to match Rive
        case .rain: return "Rainy"
        case .snow: return "Snowy"
        case .heatwave: return "Heat Wave"
        }
    }
    
    var iconName: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "snow"
        case .heatwave: return "thermometer.sun.fill"
        }
    }
}

enum RiveDayOfWeek: Double {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    /// Abbreviated day name (e.g., "Mon", "Tue")
    var abbreviation: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    static func from(date: Date) -> RiveDayOfWeek {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return RiveDayOfWeek(rawValue: Double(weekday - 1)) ?? .sunday
    }
}

enum RiveTimeSection: Double {
    case midnight = 0    // 12am-4am
    case earlyMorning = 1 // 4am-8am
    case morning = 2      // 8am-12pm
    case afternoon = 3    // 12pm-4pm
    case evening = 4      // 4pm-8pm
    case night = 5        // 8pm-12am
    
    static func from(hour: Int) -> RiveTimeSection {
        switch hour {
        case 0...3:
            return .midnight
        case 4...7:
            return .earlyMorning
        case 8...11:
            return .morning
        case 12...15:
            return .afternoon
        case 16...19:
            return .evening
        case 20...23:
            return .night
        default:
            return .afternoon
        }
    }
}

// MARK: - View Models for Rive
struct ForecastItem: Identifiable, Equatable {
    let id = UUID()
    let temperature: Double
    let minTemp: Double
    let maxTemp: Double
    let weatherIndex: RiveWeatherIndex
    let day: RiveDayOfWeek
    let date: Date
    
    // Equatable conformance - compare based on data, not UUID
    static func == (lhs: ForecastItem, rhs: ForecastItem) -> Bool {
        return lhs.temperature == rhs.temperature &&
               lhs.minTemp == rhs.minTemp &&
               lhs.maxTemp == rhs.maxTemp &&
               lhs.weatherIndex == rhs.weatherIndex &&
               lhs.day == rhs.day &&
               lhs.date == rhs.date
    }
}

