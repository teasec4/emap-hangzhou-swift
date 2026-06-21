//
//  PlaceMarker.swift
//  emap-hangzhou
//

import SwiftUI

struct PlaceMarker: View {
    let place: Place

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: place.category.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .padding(6)
                .background(place.category.color, in: Circle())

            Image(systemName: "triangle.fill")
                .font(.caption2)
                .foregroundStyle(place.category.color)
                .offset(y: -3)
        }
    }
}
