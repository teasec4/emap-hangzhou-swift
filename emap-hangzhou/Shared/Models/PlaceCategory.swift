//
//  PlaceCategory.swift
//  emap-hangzhou
//

import SwiftUI

enum PlaceCategory: String, Codable, CaseIterable {
    case food
    case coffee
    case sport
    case relax
    case shopping
    case culture
    case nature

    var displayName: String {
        switch self {
        case .food:      return String(localized: "Food")
        case .coffee:    return String(localized: "Coffee")
        case .sport:     return String(localized: "Sport")
        case .relax:     return String(localized: "Relax")
        case .shopping:  return String(localized: "Shopping")
        case .culture:   return String(localized: "Culture")
        case .nature:    return String(localized: "Nature")
        }
    }

    var iconName: String {
        switch self {
        case .food:      return "fork.knife"
        case .coffee:    return "cup.and.saucer"
        case .sport:     return "figure.run"
        case .relax:     return "sparkles"
        case .shopping:  return "bag"
        case .culture:   return "building.columns"
        case .nature:    return "leaf"
        }
    }

    var color: Color {
        switch self {
        case .food:      return .red
        case .coffee:    return .orange
        case .sport:     return .green
        case .relax:     return .purple
        case .shopping:  return .yellow
        case .culture:   return .blue
        case .nature:    return .mint
        }
    }

    /// Map backend category string to PlaceCategory.
    static func mapFromServer(_ serverCategory: String) -> PlaceCategory {
        PlaceCategory(rawValue: serverCategory.lowercased()) ?? .nature
    }
}

// MARK: - Subcategory

enum PlaceSubcategory: String, Codable, CaseIterable {
    // Food
    case italian
    case spanish
    case chinese
    case japanese
    case korean
    case french
    case russian
    case english
    case american
    case indian
    case thai
    case vietnamese
    case mideast
    case fusion
    case foodOther = "food_other"
    // Sport
    case fitness
    case yoga
    case swimming
    case climbing
    case running
    case teamGames = "team_games"
    case skatepark
    case sportOther = "sport_other"
    // Relax
    case spa
    case massage
    case banyaSauna = "banya_sauna"
    case hotSpring = "hot_spring"
    case care
    case relaxOther = "relax_other"
    // Shopping
    case mall
    case vintage
    case market
    case boutique
    case outlet
    case bookstore
    case shopOther = "shop_other"
    // Culture
    case museum
    case gallery
    case viewpoint
    case temple
    case historic
    case cultureOther = "culture_other"
    // Nature
    case park
    case lake
    case mountain
    case garden
    case natureOther = "nature_other"

    var displayName: String {
        switch self {
        // Food
        case .italian:    return String(localized: "Italian")
        case .spanish:    return String(localized: "Spanish")
        case .chinese:    return String(localized: "Chinese")
        case .japanese:   return String(localized: "Japanese")
        case .korean:     return String(localized: "Korean")
        case .french:     return String(localized: "French")
        case .russian:    return String(localized: "Russian")
        case .english:    return String(localized: "English")
        case .american:   return String(localized: "American")
        case .indian:     return String(localized: "Indian")
        case .thai:       return String(localized: "Thai")
        case .vietnamese: return String(localized: "Vietnamese")
        case .mideast:    return String(localized: "Middle Eastern")
        case .fusion:     return String(localized: "Fusion")
        case .foodOther:  return String(localized: "Other")
        // Sport
        case .fitness:     return String(localized: "Fitness")
        case .yoga:        return String(localized: "Yoga")
        case .swimming:    return String(localized: "Swimming")
        case .climbing:    return String(localized: "Climbing")
        case .running:     return String(localized: "Running")
        case .teamGames:   return String(localized: "Team Games")
        case .skatepark:   return String(localized: "Skatepark")
        case .sportOther:  return String(localized: "Other")
        // Relax
        case .spa:         return String(localized: "Spa")
        case .massage:     return String(localized: "Massage")
        case .banyaSauna:  return String(localized: "Banya/Sauna")
        case .hotSpring:   return String(localized: "Hot Spring")
        case .care:        return String(localized: "Care")
        case .relaxOther:  return String(localized: "Other")
        // Shopping
        case .mall:        return String(localized: "Mall")
        case .vintage:     return String(localized: "Vintage")
        case .market:      return String(localized: "Market")
        case .boutique:    return String(localized: "Boutique")
        case .outlet:      return String(localized: "Outlet")
        case .bookstore:   return String(localized: "Bookstore")
        case .shopOther:   return String(localized: "Other")
        // Culture
        case .museum:       return String(localized: "Museum")
        case .gallery:      return String(localized: "Gallery")
        case .viewpoint:    return String(localized: "Viewpoint")
        case .temple:       return String(localized: "Temple")
        case .historic:     return String(localized: "Historic Site")
        case .cultureOther: return String(localized: "Other")
        // Nature
        case .park:         return String(localized: "Park")
        case .lake:         return String(localized: "Lake")
        case .mountain:     return String(localized: "Mountain")
        case .garden:       return String(localized: "Garden")
        case .natureOther:  return String(localized: "Other")
        }
    }
}
