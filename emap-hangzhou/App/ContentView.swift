//
//  ContentView.swift
//  emap-hangzhou
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    let initialCoordinate: CLLocationCoordinate2D?

    var body: some View {
        MapView(initialCoordinate: initialCoordinate)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView(initialCoordinate: nil)
        .environment(AppContainer())
        .modelContainer(for: Place.self, inMemory: true)
}
