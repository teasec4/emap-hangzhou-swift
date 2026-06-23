//
//  MapViewModel.swift
//  emap-hangzhou
//

import SwiftUI
import MapKit
import SwiftData

@Observable
final class MapViewModel {
    var places: [Place] = []
    var isLoading = false
    var selectedPlace: Place?
    var didCenterOnUserLocation = false
    var cameraPosition: MapCameraPosition

    var routeService: RouteService
    var locationService: LocationService

    init(
        routeService: RouteService,
        locationService: LocationService
    ) {
        let center = locationService.currentLocation?.coordinate ?? CLLocationCoordinate2D(
            latitude: 30.2741, longitude: 120.1551
        )
        cameraPosition = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        self.routeService = routeService
        self.locationService = locationService
    }


    func selectPlace(_ place: Place?) {
        selectedPlace = place
    }

    func centerOnUserLocation(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let position = MapCameraPosition.region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))

        if animated {
            withAnimation(.easeInOut(duration: 0.35)) {
                cameraPosition = position
            }
        } else {
            cameraPosition = position
        }

        didCenterOnUserLocation = true
    }

}
