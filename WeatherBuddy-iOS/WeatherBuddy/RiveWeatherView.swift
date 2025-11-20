//
//  RiveWeatherView.swift
//  WeatherBuddy
//
//  Main view for weather display with Rive animation

import SwiftUI
import RiveRuntime

struct RiveWeatherView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = MainWeatherViewModel()
    @State private var riveViewModel: WeatherRiveViewModel?
    @State private var refreshID = UUID()
    
    private let dataBindingManager = RiveDataBindingManager()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                WeatherSearchBar(
                    viewModel: viewModel,
                    onSearch: handleSearch,
                    onLocationRequest: handleLocationRequest,
                    onToggleUnit: handleUnitToggle
                )
                
                RiveAnimationView(
                    riveViewModel: riveViewModel,
                    isLoading: viewModel.isLoading
                )
            }
            .background(backgroundGradient)
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear(perform: handleAppear)
        .setupWeatherObservers(
            viewModel: viewModel,
            riveViewModel: $riveViewModel,
            refreshID: $refreshID,
            onLoadRive: loadRiveFile,
            onUpdateInputs: updateRiveInputs
        )
    }
    
    // MARK: - Private Views
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var errorBinding: Binding<Bool> {
        .constant(viewModel.errorMessage != nil)
    }
    
    // MARK: - Actions
    
    private func handleAppear() {
        // Initial setup
    }
    
    private func handleSearch() {
        riveViewModel = nil
        Task {
            await viewModel.loadWeather()
        }
    }
    
    private func handleLocationRequest() {
        riveViewModel = nil
        viewModel.requestCurrentLocation()
    }
    
    private func handleUnitToggle() {
        viewModel.toggleUnit()
        updateRiveInputs()
    }
    
    // MARK: - Rive Management
    
    private func loadRiveFile() {
        riveViewModel = WeatherRiveViewModel(
            bundleFileName: AppConstants.Rive.fileName,
            artboardName: AppConstants.Rive.artboardName,
            stateMachineName: AppConstants.Rive.stateMachineName,
            fit: .contain,
            autoPlay: true
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Rive.dataBindingDelay) {
            updateRiveInputs()
        }
    }
    
    private func updateRiveInputs() {
        guard let riveViewModel = riveViewModel,
              let dataBinding = riveViewModel.dataBinding else {
            retryUpdateRiveInputs()
            return
        }
        
        dataBindingManager.updateDataBinding(dataBinding, with: viewModel)
    }
    
    private func retryUpdateRiveInputs() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Rive.dataBindingDelay) {
            updateRiveInputs()
        }
    }
}

// MARK: - Preview

#Preview {
    RiveWeatherView()
}

// MARK: - View Extension for Observers

private extension View {
    func setupWeatherObservers(
        viewModel: MainWeatherViewModel,
        riveViewModel: Binding<WeatherRiveViewModel?>,
        refreshID: Binding<UUID>,
        onLoadRive: @escaping () -> Void,
        onUpdateInputs: @escaping () -> Void
    ) -> some View {
        self
            .onChange(of: viewModel.isLoading) { oldValue, newValue in
                if oldValue && !newValue && riveViewModel.wrappedValue == nil {
                    onLoadRive()
                }
            }
            .onChange(of: viewModel.currentWeatherIndex) { _, _ in
                refreshID.wrappedValue = UUID()
                onUpdateInputs()
            }
            .onChange(of: viewModel.currentDay) { _, _ in
                refreshID.wrappedValue = UUID()
                onUpdateInputs()
            }
            .onChange(of: viewModel.currentTemperature) { _, _ in
                refreshID.wrappedValue = UUID()
                onUpdateInputs()
            }
            .onChange(of: viewModel.forecast) { _, newValue in
                guard !newValue.isEmpty else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Rive.forecastUpdateDelay) {
                    onUpdateInputs()
                }
            }
    }
}
