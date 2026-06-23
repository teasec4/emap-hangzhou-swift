//
//  PlaceRecommendationSheet.swift
//  emap-hangzhou
//

import SwiftUI

struct PlaceRecommendationSheet: View {
    @Environment(\.dismiss) private var dismiss

    let place: Place
    let routeService: RouteService

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


            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)

                Text(descriptionText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }



            Spacer(minLength: 8)

            HStack(spacing: 12) {
                Button("Apple Maps") {
                    routeService.openInAppleMaps(to: place)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()

                Button("AMap") {
                    routeService.openInAMap(to: place)
                    dismiss()
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


}

#Preview {
    PlaceRecommendationSheet(
        place: Place(
            title: "West Lake Tea House",
            note: "Quiet place by the water with a calm view and a simple tea menu.",
            latitude: 30.245,
            longitude: 120.13,
            category: .food
        ),
        routeService: RouteService()
    )
}
