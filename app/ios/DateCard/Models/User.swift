import Foundation
import CoreLocation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var authId: String?
    var phone: String?
    var name: String
    var age: Int
    var photos: [String]
    var latitude: Double?
    var longitude: Double?
    var dateStyleCard: DateStyleCard
    var favoriteDateTypes: [DateCategory]
    var dreamDate: String
    var verifiedPhoto: Bool
    var verifiedId: Bool
    var onboardingComplete: Bool

    var location: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case authId = "auth_id"
        case phone, name, age, photos, latitude, longitude
        case dateStyleCard = "date_style_card"
        case favoriteDateTypes = "favorite_date_types"
        case dreamDate = "dream_date"
        case verifiedPhoto = "verified_photo"
        case verifiedId = "verified_id"
        case onboardingComplete = "onboarding_complete"
    }
}

struct DateStyleCard: Codable, Hashable {
    var adventurous: Int  // 0–100
    var planner: Int
    var talker: Int
    var foodie: Int
}

enum DateCategory: String, Codable, CaseIterable, Hashable {
    case dinnerAndDrinks = "dinner_and_drinks"
    case outdoorAdventure = "outdoor_adventure"
    case liveMusic = "live_music"
    case cooking
    case artAndCulture = "art_and_culture"
    case sports
    case nightlife
    case wellness
    case coffeeAndBrunch = "coffee_and_brunch"
    case games
    case travel
    case volunteering

    var displayName: String {
        switch self {
        case .dinnerAndDrinks: "Dinner & Drinks"
        case .outdoorAdventure: "Outdoor Adventure"
        case .liveMusic: "Live Music"
        case .cooking: "Cooking"
        case .artAndCulture: "Art & Culture"
        case .sports: "Sports"
        case .nightlife: "Nightlife"
        case .wellness: "Wellness"
        case .coffeeAndBrunch: "Coffee & Brunch"
        case .games: "Games"
        case .travel: "Travel"
        case .volunteering: "Volunteering"
        }
    }

    var emoji: String {
        switch self {
        case .dinnerAndDrinks: "🍷"
        case .outdoorAdventure: "🏔️"
        case .liveMusic: "🎵"
        case .cooking: "👨‍🍳"
        case .artAndCulture: "🎨"
        case .sports: "⚽"
        case .nightlife: "🌃"
        case .wellness: "🧘"
        case .coffeeAndBrunch: "☕"
        case .games: "🎲"
        case .travel: "✈️"
        case .volunteering: "🤝"
        }
    }
}
