//
//  MapView.swift
//  emap-hangzhou
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @State var viewModel: MapViewModel

    // тут будем получать места с АПИ сервака или из кеша
    @Query(sort: \Place.createdAt) private var places: [Place]

    init(viewModel: MapViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPlace) {
                UserAnnotation()

                ForEach(places) { place in
                    Annotation(coordinate: place.coordinate) {
                        PlaceMarker(place: place)
                            .onTapGesture {
                                viewModel.selectedPlace = place
                            }
                    } label: {
                        Text(place.title)
                    }
                    .tag(place)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))

        }

        // для отслеживания локации
        .onChange(of: viewModel.locationService.currentLocation?.coordinate) { _, coordinate in
            guard let coordinate, !viewModel.didCenterOnUserLocation else { return }
            viewModel.centerOnUserLocation(coordinate)
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
