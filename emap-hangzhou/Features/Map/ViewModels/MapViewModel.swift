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
    private var poisService: PoisRequestService
    private var pollingTask: Task<Void, Never>?

    init(
        routeService: RouteService,
        locationService: LocationService,
        poisService: PoisRequestService = PoisRequestService()
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
        self.poisService = poisService
    }

    // MARK: - Server sync

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            // Initial fetch
            await fetchPlaces()
            // Then poll every 5 seconds
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                await fetchPlaces()
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func fetchPlaces() async {
        do {
            let serverPlaces = try await poisService.fetchPlaces()
            let mapped = serverPlaces.map { $0.toPlace() }
            // Only update if data changed (compare counts as cheap heuristic)
            if mapped.count != places.count || hasChanges(mapped) {
                places = mapped
            }
        } catch {
            // Silent — server might be unreachable, keep cached data
            print("[emap] fetch failed: \(error.localizedDescription)")
        }
    }

    private func hasChanges(_ newPlaces: [Place]) -> Bool {
        let oldIds = Set(places.map(\.id))
        let newIds = Set(newPlaces.map(\.id))
        return oldIds != newIds
    }

    // MARK: - Place selection

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
