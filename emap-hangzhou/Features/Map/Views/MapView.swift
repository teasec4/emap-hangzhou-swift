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
            // через селкшн передаем Плейс
            Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPlace) {
                UserAnnotation()

                ForEach(viewModel.placeClusters) { cluster in
                    if let place = cluster.singlePlace {
                        Annotation(coordinate: place.coordinate) {
                            PlaceMarker(place: place)
                        } label: {
                            Text(place.title)
                        }
                        .tag(place)
                    } else {
                        Annotation(coordinate: cluster.coordinate) {
                            ClusterMarker(cluster: cluster) {
                                viewModel.focus(on: cluster)
                            }
                        } label: {
                            Text("\(cluster.places.count) places")
                        }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateVisibleRegion(context.region)
            }
        }
        .onChange(of: viewModel.locationService.currentLocation?.coordinate) { _, coordinate in
            guard let coordinate, !viewModel.didCenterOnUserLocation else { return }
            viewModel.centerOnUserLocation(coordinate)
        }
        .task {
            viewModel.requestUserLocation()
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}

#Preview {
    let deps = AppDependencies.mock
    return MapView(viewModel: deps.makeMapViewModel())
        .modelContainer(deps.modelContainer)
}
