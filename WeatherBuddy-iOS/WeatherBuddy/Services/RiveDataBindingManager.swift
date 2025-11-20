//
//  RiveDataBindingManager.swift
//  WeatherBuddy
//
//  Manager for handling Rive data binding updates

import Foundation
import RiveRuntime

@MainActor
final class RiveDataBindingManager {
    
    // MARK: - Constants
    
    private enum RivePropertyPath {
        static let location = "Location"
        static let currentHour = "CurrenyHour"
        static let currentWeather = "CurrentWeather"
        static let weather = "Weather"
        static let dayOfWeek = "DayOfWeek"
        static let degree = "Degree"
        static let fromDegree = "FromDegree"
        static let toDegree = "ToDegree"
        static let forecastList = "Forcast"
    }
    
    // MARK: - Public Methods
    
    func updateDataBinding(
        _ dataBinding: RiveDataBindingViewModel.Instance,
        with viewModel: MainWeatherViewModel
    ) {
        updateLocation(dataBinding, location: viewModel.location)
        updateCurrentHour(dataBinding, hour: viewModel.currentHour)
        updateCurrentWeather(dataBinding, viewModel: viewModel)
        updateForecast(dataBinding, forecast: viewModel.forecast)
    }
    
    // MARK: - Private Methods
    
    private func updateLocation(
        _ dataBinding: RiveDataBindingViewModel.Instance,
        location: String
    ) {
        dataBinding.stringProperty(fromPath: RivePropertyPath.location)?.value = location
    }
    
    private func updateCurrentHour(
        _ dataBinding: RiveDataBindingViewModel.Instance,
        hour: Int
    ) {
        dataBinding.numberProperty(fromPath: RivePropertyPath.currentHour)?.value = Float(hour)
    }
    
    private func updateCurrentWeather(
        _ dataBinding: RiveDataBindingViewModel.Instance,
        viewModel: MainWeatherViewModel
    ) {
        guard let currentWeatherVM = dataBinding.viewModelInstanceProperty(
            fromPath: RivePropertyPath.currentWeather
        ) else { return }
        
        updateWeatherType(currentWeatherVM, weatherIndex: viewModel.currentWeatherIndex)
        updateDayOfWeek(currentWeatherVM, day: viewModel.currentDay)
        updateTemperature(
            currentWeatherVM,
            temperature: viewModel.currentTemperature,
            forecast: viewModel.forecast
        )
    }
    
    private func updateWeatherType(
        _ weatherVM: RiveDataBindingViewModel.Instance,
        weatherIndex: RiveWeatherIndex
    ) {
        weatherVM.enumProperty(fromPath: RivePropertyPath.weather)?.value =
            weatherIndex.riveEnumValue
    }
    
    private func updateDayOfWeek(
        _ weatherVM: RiveDataBindingViewModel.Instance,
        day: RiveDayOfWeek
    ) {
        weatherVM.enumProperty(fromPath: RivePropertyPath.dayOfWeek)?.value =
            day.abbreviation
    }
    
    private func updateTemperature(
        _ weatherVM: RiveDataBindingViewModel.Instance,
        temperature: Double,
        forecast: [ForecastItem]
    ) {
        weatherVM.numberProperty(fromPath: RivePropertyPath.degree)?.value =
            Float(temperature)
        
        guard let todayForecast = forecast.first else { return }
        
        weatherVM.numberProperty(fromPath: RivePropertyPath.fromDegree)?.value =
            Float(todayForecast.minTemp)
        weatherVM.numberProperty(fromPath: RivePropertyPath.toDegree)?.value =
            Float(todayForecast.maxTemp)
    }
    
    private func updateForecast(
        _ dataBinding: RiveDataBindingViewModel.Instance,
        forecast: [ForecastItem]
    ) {
        guard !forecast.isEmpty else { return }
        
        do {
            let forecastListProperty = try dataBinding.listProperty(
                fromPath: RivePropertyPath.forecastList
            )
            let forecastToShow = forecast.prefix(5)
            
            for (index, forecastItem) in forecastToShow.enumerated() {
                guard let item = try? forecastListProperty?.instance(at: Int32(index)) else {
                    continue
                }
                
                updateForecastItem(item, with: forecastItem)
            }
        } catch {
            // Forecast list not accessible
        }
    }
    
    private func updateForecastItem(
        _ item: RiveDataBindingViewModel.Instance,
        with forecastItem: ForecastItem
    ) {
        item.enumProperty(fromPath: RivePropertyPath.weather)?.value =
            forecastItem.weatherIndex.riveEnumValue
        item.enumProperty(fromPath: RivePropertyPath.dayOfWeek)?.value =
            forecastItem.day.abbreviation
        item.numberProperty(fromPath: RivePropertyPath.degree)?.value =
            Float(forecastItem.temperature)
        item.numberProperty(fromPath: RivePropertyPath.fromDegree)?.value =
            Float(forecastItem.minTemp)
        item.numberProperty(fromPath: RivePropertyPath.toDegree)?.value =
            Float(forecastItem.maxTemp)
    }
}

// MARK: - RiveWeatherIndex Extension

private extension RiveWeatherIndex {
    var riveEnumValue: String {
        switch self {
        case .sunny: return "Clear Skies"
        case .rain: return "Rainy"
        case .snow: return "Snowy"
        case .heatwave: return "Heat Wave"
        }
    }
}

