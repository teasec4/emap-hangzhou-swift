//
//  ServerResponse.swift
//  emap-hangzhou
//
//  Created by Максим Ковалев on 6/23/26.
//

import Foundation

/// POI returned by the backend API (GET /api/public/pois).
struct ServerPlace: Codable {
    let id: String
    let name: String
    let category: String
    let subcategory: String?
    let lat: Double
    let lng: Double
    let comment: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, category, subcategory, lat, lng, comment, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        subcategory = try container.decodeIfPresent(String.self, forKey: .subcategory)
        lat = try container.decode(Double.self, forKey: .lat)
        lng = try container.decode(Double.self, forKey: .lng)
        comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }

    init(id: String, name: String, category: String, subcategory: String?, lat: Double, lng: Double, comment: String, createdAt: String, updatedAt: String) {
        self.id = id
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.lat = lat
        self.lng = lng
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Convert to local Place model for display.
    func toPlace() -> Place {
        let cat = PlaceCategory.mapFromServer(category)
        let sub: PlaceSubcategory? = if let raw = subcategory, !raw.isEmpty {
            PlaceSubcategory(rawValue: raw)
        } else {
            nil
        }
        return Place(
            id: UUID(uuidString: id),
            title: name,
            note: comment,
            latitude: lat,
            longitude: lng,
            category: cat,
            subcategory: sub,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? .now
        )
    }
}
