//
//  ContentView.swift
//  emap-hangzhou
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @State var mapViewModel: MapViewModel
    
    @State var isPresented: Bool = true
    @State private var selectedDetent: PresentationDetent = .height(80)
    
    @State private var panelContent: PanelContentType = .recommendation

    init(mapViewModel: MapViewModel) {
        _mapViewModel = State(initialValue: mapViewModel)
    }

    var body: some View {
        VStack{
            MapView(viewModel: mapViewModel)
        }
        .sheet(isPresented: $isPresented){
            panelContentBuilder
            .presentationDetents([ .height(80), .medium, .large], selection: $selectedDetent)
            .presentationBackgroundInteraction(.enabled)
            .interactiveDismissDisabled()
            .onAppear{
                panelContent = .recommendation
            }
        }
        .onChange(of: mapViewModel.selectedPlace) { _, place in
            if let place {
                panelContent = .place(place: place)
                selectedDetent = .medium
            } else {
                panelContent = .recommendation
                selectedDetent = .height(80)
            }
        }
    }
    
    @ViewBuilder
    private var panelContentBuilder: some View{
        switch panelContent {
        case .recommendation:
            let userCoord = mapViewModel.locationService.currentLocation?.coordinate
            WorkspacePanel(selectedDetent: $selectedDetent, content: RecommendationContent(
                places: mapViewModel.places,
                userCoordinate: userCoord,
                onRoute: { place in
                    mapViewModel.routeService.openInAppleMaps(to: place)
                }
            ))
        case .place(let place):
            WorkspacePanel(
                selectedDetent: $selectedDetent,
                content: PlaceRecommendationSheet(place: place, routeService: mapViewModel.routeService)
            )
        }
    }

}

private struct WorkspacePanel<Content: View>: View {
    let content:Content
    @Binding var selectedDetent: PresentationDetent
    
    init(
        selectedDetent: Binding<PresentationDetent>,
        content: Content
    ){
        self._selectedDetent = selectedDetent
        self.content = content
    }

    var body: some View {
        if selectedDetent == .height(80){
            SheetButton(onTap: {
                selectedDetent = .medium
            })
        } else{
            VStack(spacing: 14) {
                Capsule()
                    .fill(.secondary.opacity(0.35))
                    .frame(width: 40, height: 5)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    content
                    
                }
            }

            .padding(.horizontal, 16)
            .safeAreaPadding(.bottom)
            .padding(.bottom, 14)
            .background(.regularMaterial)
        }
        

    }
}

private struct RecommendationContent: View {
    let places: [Place]
    let userCoordinate: CLLocationCoordinate2D?
    let onRoute: (Place) -> Void

    private var sortedPlaces: [Place] {
        guard let user = userCoordinate else { return Array(places.prefix(10)) }
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        return places
            .map { (place: $0, distance: CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLoc)) }
            .sorted { $0.distance < $1.distance }
            .prefix(10)
            .map(\.place)
    }

    var body: some View {
        if places.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "mappin.slash")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No places nearby yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else {
            LazyVStack(spacing: 10) {
                ForEach(sortedPlaces) { place in
                    PlaceCard(place: place, distance: distanceString(for: place)) {
                        onRoute(place)
                    }
                }
            }
            .padding(.bottom, 14)
        }
    }

    private func distanceString(for place: Place) -> String {
        guard let user = userCoordinate else { return "" }
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let placeLoc = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let meters = userLoc.distance(from: placeLoc)
        if meters < 1000 {
            return "\(Int(meters)) m"
        } else {
            return String(format: "%.1f km", meters / 1000)
        }
    }
}

private struct SheetButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Label("Show nearby", systemImage: "list.bullet")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



private struct PlaceCard: View {
    let place: Place
    let distance: String
    let onRoute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: place.category.iconName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(place.category.color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(place.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !distance.isEmpty {
                    Label(distance, systemImage: "figure.walk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !place.note.isEmpty {
                Text(place.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Spacer()
                Button(action: onRoute) {
                    Label("Route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MockRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let tagline: String
    let description: String
    let category: PlaceCategory
    let rating: String
    let distance: String
    let price: String
    let latitude: Double
    let longitude: Double

    var place: Place {
        Place(
            title: title,
            note: description,
            latitude: latitude,
            longitude: longitude,
            category: category
        )
    }

    static let samples = [
        MockRecommendation(
            title: "West Lake Tea House",
            tagline: "Quiet tea spot near the water",
            description: "Calm table, simple tea set, and a good place to bring someone after a walk by the lake.",
            category: .food,
            rating: "4.8",
            distance: "12 min",
            price: "Moderate",
            latitude: 30.2451,
            longitude: 120.1302
        ),
        MockRecommendation(
            title: "Liangzhu Museum",
            tagline: "Design, history, soft light",
            description: "A clean museum route for a slow afternoon: architecture, artifacts, and a good coffee stop nearby.",
            category: .exhibition,
            rating: "4.7",
            distance: "28 min",
            price: "Low",
            latitude: 30.3956,
            longitude: 120.0438
        ),
        MockRecommendation(
            title: "Alibaba Xixi Campus",
            tagline: "Tech landmark in Hangzhou",
            description: "Useful for first-time visitors who want to understand the city through its modern tech side.",
            category: .technology,
            rating: "4.6",
            distance: "35 min",
            price: "Free",
            latitude: 30.2792,
            longitude: 120.0246
        )
    ]
}

enum PanelContentType{
    case recommendation
    case place(place: Place)
}

//#Preview {
//    ContentView()
//
//}
