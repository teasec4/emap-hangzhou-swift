//
//  MapView.swift
//  emap-hangzhou
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MapViewModel

    @Query(sort: \Place.createdAt) private var places: [Place]

    init(initialCoordinate: CLLocationCoordinate2D? = nil) {
        _viewModel = State(initialValue: MapViewModel(initialCoordinate: initialCoordinate))
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPlace) {
                UserAnnotation()

                ForEach(places) { place in
                    Annotation(coordinate: place.coordinate) {
                        PlaceMarker(place: place)
                    } label: {
                        Text(place.title)
                    }
                    .tag(place)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onTapGesture { position in
                guard let coordinate = proxy.convert(position, from: .local) else { return }
                viewModel.handleMapTap(at: coordinate)
            }
        }
        .task {
            container.locationService.requestLocation()
        }
        .onChange(of: container.locationService.currentLocation?.coordinate) { _, coordinate in
            guard let coordinate, !viewModel.didCenterOnUserLocation else { return }
            viewModel.centerOnUserLocation(coordinate)
        }
        .sheet(isPresented: $viewModel.isAddSheetPresented) {
            if let coordinate = viewModel.tappedCoordinate {
                AddPlaceSheet(coordinate: coordinate) { title, note, category in
                    viewModel.savePlace(
                        title: title,
                        note: note,
                        category: category,
                        context: modelContext
                    )
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            PlaceRecommendationSheet(place: place)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct PlaceRecommendationSheet: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: place.category.iconName)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(place.category.color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(place.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    Label(place.category.displayName, systemImage: "mappin.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < 4 ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                }

                Text("4.8")
                    .font(.headline)

                Text("Team pick")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)

                Text(descriptionText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Menu")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    menuRow("Signature dish", detail: "Local favorite")
                    menuRow("Best time", detail: "Lunch or early evening")
                    menuRow("Budget", detail: "Moderate")
                }
                .font(.subheadline)
            }

            Spacer(minLength: 8)

            VStack(spacing: 12) {
                Button {
                    container.routeService.openInAppleMaps(to: place)
                    dismiss()
                } label: {
                    Label("Route in Apple Maps", systemImage: "map.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    container.routeService.openInAMap(to: place)
                    dismiss()
                } label: {
                    Label("Route in AMap", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(24)
    }

    private var descriptionText: String {
        let trimmedNote = place.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNote.isEmpty {
            return trimmedNote
        }

        return "A recommended spot from the team. Add a richer description later: why it is worth visiting, what to order, and when it is best to go."
    }

    private func menuRow(_ title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(detail)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MapView()
        .environment(AppContainer())
        .modelContainer(for: Place.self, inMemory: true)
}
