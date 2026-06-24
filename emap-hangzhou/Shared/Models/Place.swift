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
    var subcategoryRawValue: String?

    var createdAt: Date

    var category: PlaceCategory {
        get { PlaceCategory(rawValue: categoryRawValue) ?? .nature }
        set { categoryRawValue = newValue.rawValue }
    }

    var subcategory: PlaceSubcategory? {
        get {
            guard let raw = subcategoryRawValue else { return nil }
            return PlaceSubcategory(rawValue: raw)
        }
        set { subcategoryRawValue = newValue?.rawValue }
    }

    init(
        id: UUID? = nil,
        title: String,
        note: String = "",
        latitude: Double,
        longitude: Double,
        category: PlaceCategory,
        subcategory: PlaceSubcategory? = nil,
        createdAt: Date = .now
    ) {
        self.id = id ?? UUID()
        self.title = title
        self.note = note
        self.latitude = latitude
        self.longitude = longitude
        self.categoryRawValue = category.rawValue
        self.subcategoryRawValue = subcategory?.rawValue
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
