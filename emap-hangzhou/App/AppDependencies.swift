//
//  AppDependencies.swift
//  emap-hangzhou
//

import Foundation
import SwiftData

@MainActor
struct AppDependencies {
    let locationService: LocationService
    let routeService: RouteService
    let modelContainer: ModelContainer

    static func live() throws -> AppDependencies{
        let container = try makeModelContainer(isStiredInMemoryOnly: false)
        let locationService = LocationService()
        let routeService = RouteService()
        return AppDependencies(
            locationService: locationService,
            routeService: routeService,
            modelContainer: container
        )
    }

    private static func makeModelContainer(isStiredInMemoryOnly: Bool) throws -> ModelContainer{
        let schema = Schema([
            Place.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStiredInMemoryOnly)

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
