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
@MainActor
struct emap_hangzhouApp: App {
    @State private var dependencies: AppDependencies

    init(){
        do{
            let dependencies = try AppDependencies.live()
            _dependencies = State(initialValue: dependencies)

        } catch {
            fatalError("Failed to create app dependencies: \(error)")
        }
    }


    var body: some Scene {
        WindowGroup {
            RootView(appDependencies: dependencies)
        }
        .modelContainer(dependencies.modelContainer)

    }
}
