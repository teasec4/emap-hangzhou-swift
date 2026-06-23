//
//  MapView.swift
//  emap-hangzhou
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @State var viewModel: MapViewModel

    // SwiftData: kept for future local persistence, not displayed yet
    @Query(sort: \Place.createdAt) private var localPlaces: [Place]

    init(viewModel: MapViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPlace) {
                UserAnnotation()

                // Show server-fetched places
                ForEach(viewModel.places) { place in
                    Annotation(coordinate: place.coordinate) {
                        PlaceMarker(place: place)
                    } label: {
                        Text(place.title)
                    }
                    .tag(place)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
        }
        .onChange(of: viewModel.locationService.currentLocation?.coordinate) { _, coordinate in
            guard let coordinate, !viewModel.didCenterOnUserLocation else { return }
            viewModel.centerOnUserLocation(coordinate)
        }
        .task {
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}

#Preview {
    MapView(viewModel: MapViewModel(
        routeService: RouteService(),
        locationService: LocationService()
    ))
    .modelContainer(for: Place.self, inMemory: true)
}
