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
    @ObservationIgnored private var visibleRegion: MKCoordinateRegion
    private var clusterRegion: MKCoordinateRegion

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
        let initialRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        cameraPosition = .region(initialRegion)
        visibleRegion = initialRegion
        clusterRegion = initialRegion
        self.routeService = routeService
        self.locationService = locationService
        self.poisService = poisService
    }

    var placeClusters: [PlaceCluster] {
        PlaceCluster.make(from: places, in: clusterRegion)
    }

    // MARK: - Server sync

    func startPolling() {
        guard pollingTask == nil else { return } // already running
        isLoading = true
        pollingTask = Task {
            await fetchPlaces()
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

    func requestUserLocation() {
        locationService.requestLocation()
    }

    func updateVisibleRegion(_ region: MKCoordinateRegion) {
        visibleRegion = region

        guard shouldUpdateClusters(for: region) else { return }
        clusterRegion = region
    }

    private func fetchPlaces() async {
        do {
            let serverPlaces = try await poisService.fetchPlaces()
            let mapped = serverPlaces.map { $0.toPlace() }
            if mapped.count != places.count || hasChanges(mapped) {
                places = mapped
            }
            // First successful load — hide loading
            if isLoading {
                isLoading = false
            }
        } catch {
            // Keep cached data; hide loading after first attempt even on failure
            if isLoading {
                isLoading = false
            }
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

    func focus(on cluster: PlaceCluster) {
        selectedPlace = nil

        let zoomedRegion = MKCoordinateRegion(
            center: cluster.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: max(visibleRegion.span.latitudeDelta * 0.45, 0.002),
                longitudeDelta: max(visibleRegion.span.longitudeDelta * 0.45, 0.002)
            )
        )

        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(zoomedRegion)
        }
        visibleRegion = zoomedRegion
        clusterRegion = zoomedRegion
    }

    private func shouldUpdateClusters(for region: MKCoordinateRegion) -> Bool {
        let latitudeZoomChange = relativeChange(
            from: clusterRegion.span.latitudeDelta,
            to: region.span.latitudeDelta
        )
        let longitudeZoomChange = relativeChange(
            from: clusterRegion.span.longitudeDelta,
            to: region.span.longitudeDelta
        )

        return max(latitudeZoomChange, longitudeZoomChange) > 0.12
    }

    private func relativeChange(from oldValue: CLLocationDegrees, to newValue: CLLocationDegrees) -> Double {
        guard oldValue > 0 else { return 1 }
        return abs(newValue - oldValue) / oldValue
    }
}

struct PlaceCluster: Identifiable {
    let id: String
    let places: [Place]
    let coordinate: CLLocationCoordinate2D

    var singlePlace: Place? {
        places.count == 1 ? places[0] : nil
    }

    var dominantCategory: PlaceCategory {
        places.first?.category ?? .nature
    }

    static func make(from places: [Place], in region: MKCoordinateRegion) -> [PlaceCluster] {
        guard !places.isEmpty else { return [] }

        let latitudeCellSize = max(region.span.latitudeDelta / 8, 0.00045)
        let longitudeCellSize = max(region.span.longitudeDelta / 8, 0.00045)

        var buckets: [ClusterKey: [Place]] = [:]

        for place in places {
            let key = ClusterKey(
                latitude: Int((place.latitude / latitudeCellSize).rounded(.down)),
                longitude: Int((place.longitude / longitudeCellSize).rounded(.down))
            )
            buckets[key, default: []].append(place)
        }

        return buckets.map { key, bucketPlaces in
            PlaceCluster(
                id: bucketPlaces.count == 1 ? "place-\(bucketPlaces[0].id.uuidString)" : "cluster-\(key.latitude)-\(key.longitude)",
                places: bucketPlaces,
                coordinate: averageCoordinate(for: bucketPlaces)
            )
        }
        .sorted { $0.id < $1.id }
    }

    private static func averageCoordinate(for places: [Place]) -> CLLocationCoordinate2D {
        let count = Double(places.count)
        let latitude = places.reduce(0) { $0 + $1.latitude } / count
        let longitude = places.reduce(0) { $0 + $1.longitude } / count

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private struct ClusterKey: Hashable {
    let latitude: Int
    let longitude: Int
}
