//
//  emap_hangzhouApp.swift
//  emap-hangzhou
//

import SwiftUI
import SwiftData
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

@main
struct emap_hangzhouApp: App {
    @State private var container = AppContainer()
    @State private var state: AppState = .splash

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch state {
                case .splash:
                    SplashView()
                case .main(let coordinate):
                    ContentView(initialCoordinate: coordinate)
                }
            }
            .environment(container)
            .onAppear {
                container.locationService.onLocationReceived = { coordinate in
                    withAnimation(.easeInOut(duration: 0.4)) {
                        state = .main(coordinate)
                    }
                }
                container.locationService.requestLocation()
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    if case .splash = state {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            state = .main(nil)
                        }
                    }
                }
            }
        }
        .modelContainer(for: Place.self)
    }
}

// MARK: - App State

enum AppState: Equatable {
    case splash
    case main(CLLocationCoordinate2D?)
}
