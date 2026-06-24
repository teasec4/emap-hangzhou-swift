//
//  RootView.swift
//  emap-hangzhou
//
//  Created by Максим Ковалев on 6/23/26.
//
import SwiftUI

@MainActor
struct RootView: View {
    @State private var rootState: RootState = .splash
    @State private var appDependencies: AppDependencies
    @State private var mapViewModel: MapViewModel

    init(appDependencies: AppDependencies) {
        let deps = appDependencies
        _appDependencies = State(initialValue: deps)
        // Create ViewModel immediately so it starts loading during splash
        _mapViewModel = State(initialValue: deps.makeMapViewModel())
    }

    @ViewBuilder
    var body: some View {
        switch rootState {
        case .splash:
            SplashView()
                .task {
                    // Start loading map data in parallel with splash animation
                    mapViewModel.startPolling()
                    try? await Task.sleep(for: .seconds(2.5))
                    rootState = .main
                }
        case .main:
            ContentView(mapViewModel: mapViewModel)
        }
    }
}

private enum RootState {
    case splash
    case main
}
