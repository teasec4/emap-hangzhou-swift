//
//  PlaceCategory.swift
//  emap-hangzhou
//

import SwiftUI

enum PlaceCategory: String, Codable, CaseIterable {
    case food
    case scenery
    case technology
    case exhibition

    var displayName: String {
        switch self {
        case .food:         return String(localized: "Food")
        case .scenery:      return String(localized: "Scenery")
        case .technology:   return String(localized: "Technology")
        case .exhibition:   return String(localized: "Exhibition")
        }
    }

    var iconName: String {
        switch self {
        case .food:         return "fork.knife"
        case .scenery:      return "mountain.2"
        case .technology:   return "cpu"
        case .exhibition:   return "theatermasks"
        }
    }

    var color: Color {
        switch self {
        case .food:         return .orange
        case .scenery:      return .green
        case .technology:   return .blue
        case .exhibition:   return .purple
        }
    }
}
