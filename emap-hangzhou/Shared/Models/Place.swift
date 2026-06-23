//
//  Place.swift
//  emap-hangzhou
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Place {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String
    var latitude: Double
    var longitude: Double
    var categoryRawValue: String
    var createdAt: Date

    // MARK: - Future expansion (not yet implemented)
    // var photos: [Data]?
    // var rating: Int?
    // var tags: [String]?
    // var isVisited: Bool
    // var link: URL?
    // var city: String?
    // var country: String?
    // var collectionName: String?

    var category: PlaceCategory {
        get { PlaceCategory(rawValue: categoryRawValue) ?? .scenery }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID? = nil,
        title: String,
        note: String = "",
        latitude: Double,
        longitude: Double,
        category: PlaceCategory,
        createdAt: Date = .now
    ) {
        self.id = id ?? UUID()
        self.title = title
        self.note = note
        self.latitude = latitude
        self.longitude = longitude
        self.categoryRawValue = category.rawValue
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
