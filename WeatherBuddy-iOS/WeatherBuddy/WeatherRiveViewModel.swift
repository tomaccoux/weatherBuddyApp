//
//  WeatherRiveViewModel.swift
//  WeatherBuddy
//
//  Simplified version of DrawRiveViewModel for data binding
//

import Foundation
import RiveRuntime
import SwiftUI

class WeatherRiveViewModel: RiveViewModel {
    var dataBinding: RiveDataBindingViewModel.Instance?
    
    init(
        bundleFileName: String,
        artboardName: String? = nil,
        stateMachineName: String? = nil,
        fit: RiveFit,
        autoPlay: Bool = true
    ) {
        super.init(
            fileName: bundleFileName,
            stateMachineName: stateMachineName,
            fit: fit,
            autoPlay: autoPlay,
            artboardName: artboardName
        )
        
        setupDataBinding()
    }
    
    private func setupDataBinding() {
        riveModel?.enableAutoBind { [weak self] instance in
            self?.dataBinding = instance
        }
    }
}

