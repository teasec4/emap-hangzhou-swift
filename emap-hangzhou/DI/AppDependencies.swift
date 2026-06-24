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
    let poisService: PoisRequestService
    let modelContainer: ModelContainer

    static func live() throws -> AppDependencies {
        let container = try makeModelContainer(isStoredInMemoryOnly: false)
        let locationService = LocationService()
        let routeService = RouteService()
        let poisService = PoisRequestService()
        return AppDependencies(
            locationService: locationService,
            routeService: routeService,
            poisService: poisService,
            modelContainer: container
        )
    }

    /// Preview / mock dependency tree with sample data.
    static var mock: AppDependencies {
        let container = try! makeModelContainer(isStoredInMemoryOnly: true)
        let locationService = LocationService()
        let routeService = RouteService()
        let poisService = MockPoisService()
        return AppDependencies(
            locationService: locationService,
            routeService: routeService,
            poisService: poisService,
            modelContainer: container
        )
    }

    func makeMapViewModel() -> MapViewModel {
        MapViewModel(
            routeService: routeService,
            locationService: locationService,
            poisService: poisService
        )
    }

    private static func makeModelContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let schema = Schema([
            Place.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

// MARK: - Mock POI service for previews

private final class MockPoisService: PoisRequestService {
    override func fetchPlaces() async throws -> [ServerPlace] {
        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(400))
        return Self.samples
    }

    static let samples: [ServerPlace] = [
        ServerPlace(
            id: "a1b2c3d4-0001-4000-8000-000000000001",
            name: "West Lake Tea House",
            category: "food",
            subcategory: "chinese",
            lat: 30.2451,
            lng: 120.1302,
            comment: "Calm table, simple tea set, and a good place to bring someone after a walk by the lake.",
            createdAt: "2026-06-22T08:00:00Z",
            updatedAt: "2026-06-22T08:00:00Z"
        ),
        ServerPlace(
            id: "a1b2c3d4-0002-4000-8000-000000000002",
            name: "Liangzhu Museum",
            category: "culture",
            subcategory: "museum",
            lat: 30.3956,
            lng: 120.0438,
            comment: "A clean museum route for a slow afternoon: architecture, artifacts, and a good coffee stop nearby.",
            createdAt: "2026-06-22T09:00:00Z",
            updatedAt: "2026-06-22T09:00:00Z"
        ),
        ServerPlace(
            id: "a1b2c3d4-0003-4000-8000-000000000003",
            name: "Alibaba Xixi Campus",
            category: "culture",
            subcategory: "historic",
            lat: 30.2792,
            lng: 120.0246,
            comment: "Useful for first-time visitors who want to understand the city through its modern tech side.",
            createdAt: "2026-06-23T10:00:00Z",
            updatedAt: "2026-06-23T10:00:00Z"
        ),
        ServerPlace(
            id: "a1b2c3d4-0004-4000-8000-000000000004",
            name: "Leifeng Pagoda",
            category: "culture",
            subcategory: "temple",
            lat: 30.2314,
            lng: 120.1449,
            comment: "",
            createdAt: "2026-06-23T11:00:00Z",
            updatedAt: "2026-06-23T11:00:00Z"
        ),
        ServerPlace(
            id: "a1b2c3d4-0005-4000-8000-000000000005",
            name: "Hangzhou Botanical Garden",
            category: "nature",
            subcategory: "garden",
            lat: 30.2589,
            lng: 120.1202,
            comment: "Lots of walking paths and quiet corners.",
            createdAt: "2026-06-23T12:00:00Z",
            updatedAt: "2026-06-23T12:00:00Z"
        )
    ]
}
