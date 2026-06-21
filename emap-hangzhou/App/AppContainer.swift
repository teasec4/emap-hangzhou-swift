//
//  AppContainer.swift
//  emap-hangzhou
//

import Foundation

@Observable
final class AppContainer {
    let locationService: LocationService
    let routeService: RouteService

    init(
        locationService: LocationService = LocationService(),
        routeService: RouteService = RouteService()
    ) {
        self.locationService = locationService
        self.routeService = routeService
    }
}
