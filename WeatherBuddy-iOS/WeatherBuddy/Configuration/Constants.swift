//
//  Constants.swift
//  WeatherBuddy
//
//  App-wide constants and configuration

import Foundation

enum AppConstants {
    
    // MARK: - Rive Configuration
    
    enum Rive {
        static let fileName = "weatherbuddy_final"
        static let artboardName = "Main Screen"
        static let stateMachineName = "State Machine 1"
        static let dataBindingDelay: TimeInterval = 0.5
        static let forecastUpdateDelay: TimeInterval = 0.1
        static let maxForecastDays = 5
    }
    
    // MARK: - Weather Configuration
    
    enum Weather {
        static let defaultLocation = "Tel Aviv"
        static let defaultTemperature = 68.0  // Fahrenheit (20°C = 68°F)
        static let totalForecastDays = 7
        static let usesFahrenheit = true  // Backend returns Fahrenheit
    }
    
    // MARK: - UI Configuration
    
    enum UI {
        static let buttonPadding: CGFloat = 10
        static let searchBarSpacing: CGFloat = 8
        static let loadingScale: CGFloat = 1.5
    }
}

