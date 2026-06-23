//
//  ContentView.swift
//  emap-hangzhou
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @State var mapViewModel: MapViewModel
    @State private var workspaceDetent: WorkspaceDetent = .collapsed
    @State var searchInput: String = ""

    init(mapViewModel: MapViewModel) {
        _mapViewModel = State(initialValue: mapViewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                MapView(viewModel: mapViewModel)

                // защита карты чтобы она не скролилась когда меню expanded
                if workspaceDetent == .expanded {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            setWorkspaceDetent(.collapsed)
                        }
                }

                WorkspacePanel(
                    recommendations: MockRecommendation.samples,
                    onExpand: {
                        guard workspaceDetent == .collapsed else { return }
                        setWorkspaceDetent(.expanded)
                    },
                    onDragEnded: handleWorkspaceDrag,
                    onRoute: { recommendation in
                        mapViewModel.routeService.openInAppleMaps(to: recommendation.place)
                    },
                    searchInput: $searchInput
                )
                .ignoresSafeArea(edges: .bottom)
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * workspaceDetent.heightFraction)
            }
        }
    }

    // хандлер для expand
    private func handleWorkspaceDrag(_ value: DragGesture.Value) {
        let verticalMovement = value.predictedEndTranslation.height

        if verticalMovement > 80 {
            setWorkspaceDetent(.collapsed)
        } else if verticalMovement < -80 {
            setWorkspaceDetent(.expanded)
        }
    }

    private func setWorkspaceDetent(_ detent: WorkspaceDetent) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            workspaceDetent = detent
        }
    }
}

private struct WorkspacePanel: View {
    let recommendations: [MockRecommendation]
    let onExpand: () -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    let onRoute: (MockRecommendation) -> Void
    @Binding var searchInput: String

    var body: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(.secondary.opacity(0.35))
                .frame(width: 40, height: 5)
                .padding(.top, 4)

            SearchPlaceholder(searchInput: $searchInput)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(recommendations) { recommendation in
                        RecommendationCard(recommendation: recommendation) {
                            onRoute(recommendation)
                        }
                    }
                }
                .padding(.bottom, 14)
            }
        }

        .padding(.horizontal, 16)
        .safeAreaPadding(.bottom)
        .padding(.bottom, 14)
        .background(.regularMaterial)


        .onTapGesture(perform: onExpand)
        .gesture(
            DragGesture()
                .onEnded { value in
                    onDragEnded(value)
                }
        )
    }
}

private struct SearchPlaceholder: View {
    @Binding var searchInput: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search places", text: $searchInput)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()


        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}


private struct RecommendationCard: View {
    let recommendation: MockRecommendation
    let onRoute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: recommendation.category.iconName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(recommendation.category.color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(recommendation.tagline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Label(recommendation.rating, systemImage: "star.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.yellow)
            }

            Text(recommendation.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 10) {
                Label(recommendation.distance, systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(recommendation.price, systemImage: "creditcard")
                    .font(.caption)
                    .foregroundStyle(.secondary)

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

private enum WorkspaceDetent {
    case collapsed
    case expanded

    var heightFraction: CGFloat {
        switch self {
        case .collapsed: return 0.28
        case .expanded:  return 0.66
        }
    }
}

//#Preview {
//    ContentView()
//
//}
