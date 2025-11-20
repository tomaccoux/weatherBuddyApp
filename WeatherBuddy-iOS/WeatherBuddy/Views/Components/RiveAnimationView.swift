//
//  RiveAnimationView.swift
//  WeatherBuddy
//
//  Component for displaying Rive animation or loading state

import SwiftUI
import RiveRuntime

struct RiveAnimationView: View {
    let riveViewModel: WeatherRiveViewModel?
    let isLoading: Bool
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            if let riveViewModel = riveViewModel {
                riveViewModel.view()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LoadingView(isLoading: isLoading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Loading View

private struct LoadingView: View {
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(loadingText)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private var loadingText: String {
        isLoading ? "Loading weather..." : "Preparing animation..."
    }
}

