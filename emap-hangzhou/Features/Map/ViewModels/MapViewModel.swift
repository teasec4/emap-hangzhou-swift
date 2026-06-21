//
//  MapViewModel.swift
//  emap-hangzhou
//

import SwiftUI
import MapKit
import SwiftData

@Observable
final class MapViewModel {

    var tappedCoordinate: CLLocationCoordinate2D?
    var selectedPlace: Place?
    var isAddSheetPresented = false
    var didCenterOnUserLocation = false

    var cameraPosition: MapCameraPosition

    init(initialCoordinate: CLLocationCoordinate2D? = nil) {
        let center = initialCoordinate ?? CLLocationCoordinate2D(
            latitude: 30.2741, longitude: 120.1551
        )
        cameraPosition = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    // MARK: - Add Place

    func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        selectedPlace = nil
        tappedCoordinate = coordinate
        isAddSheetPresented = true
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

    func savePlace(
        title: String,
        note: String,
        category: PlaceCategory,
        context: ModelContext
    ) {
        guard let coordinate = tappedCoordinate else { return }
        let place = Place(
            title: title,
            note: note,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            category: category
        )
        context.insert(place)
        try? context.save()

        tappedCoordinate = nil
        isAddSheetPresented = false
    }
}
