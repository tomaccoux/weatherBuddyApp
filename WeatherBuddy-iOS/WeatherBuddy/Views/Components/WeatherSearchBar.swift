//
//  WeatherSearchBar.swift
//  WeatherBuddy
//
//  Search bar component for weather location

import SwiftUI

struct WeatherSearchBar: View {
    @ObservedObject var viewModel: MainWeatherViewModel
    let onSearch: () -> Void
    let onLocationRequest: () -> Void
    let onToggleUnit: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            LocationButton(
                isActive: viewModel.isUsingCurrentLocation,
                action: onLocationRequest
            )
            
            SearchTextField(
                text: $viewModel.location,
                isDisabled: viewModel.isUsingCurrentLocation,
                onSubmit: onSearch
            )
            
            SearchButton(
                isDisabled: viewModel.isUsingCurrentLocation,
                action: onSearch
            )
            
            TemperatureUnitToggle(
                isCelsius: viewModel.isCelsius,
                action: onToggleUnit
            )
        }
        .padding()
        .background(searchBarGradient)
    }
    
    private var searchBarGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Sub-components

private struct LocationButton: View {
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isActive ? "location.fill" : "location")
                .foregroundColor(.white)
                .padding(10)
                .background(buttonColor)
                .clipShape(Circle())
        }
    }
    
    private var buttonColor: Color {
        isActive ? Color.green.opacity(0.7) : Color.blue.opacity(0.7)
    }
}

private struct SearchTextField: View {
    @Binding var text: String
    let isDisabled: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        TextField("Enter location", text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.7 : 1.0)
            .onSubmit(onSubmit)
    }
}

private struct SearchButton: View {
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue.opacity(0.7))
                .clipShape(Circle())
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

private struct TemperatureUnitToggle: View {
    let isCelsius: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isCelsius ? "°C" : "°F")
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

