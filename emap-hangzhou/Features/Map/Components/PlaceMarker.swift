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

struct ClusterMarker: View {
    let cluster: PlaceCluster
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(cluster.places.count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(cluster.dominantCategory.color, in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 3)
                }
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
