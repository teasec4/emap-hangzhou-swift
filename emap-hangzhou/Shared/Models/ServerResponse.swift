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
