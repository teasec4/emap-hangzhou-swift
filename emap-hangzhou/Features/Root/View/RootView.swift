//
//  RootView.swift
//  emap-hangzhou
//
//  Created by Максим Ковалев on 6/23/26.
//
import SwiftUI

@MainActor
struct RootView: View{
    @State private var rootState: RootState = .splash
    @State private var appDependencies: AppDependencies

    init(appDependencies: AppDependencies) {
        _appDependencies = State(initialValue: appDependencies)
    }

    @ViewBuilder
    var body: some View{
        switch rootState {
        case .splash:
            SplashView()
                .task {
                    try? await Task.sleep(for: .seconds(2.5))
                    rootState = .main
                }
        case .main:
            ContentView(mapViewModel: appDependencies.makeMapViewModel())
        }
    }
}

private enum RootState{
    case splash
    case main
}
