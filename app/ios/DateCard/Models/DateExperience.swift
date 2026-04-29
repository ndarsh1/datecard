import Foundation

struct DateExperience: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var description: String
    var categories: [DateCategory]
    var venueId: String?
    var priceRange: Int  // 1, 2, or 3
    var durationMinutes: Int
    var latitude: Double
    var longitude: Double
    var neighborhood: String
    var heroImage: String
    var galleryImages: [String]
    var optInCount: Int
    var source: Source
    var isVenuePackage: Bool
    var expiresAt: Date?

    enum Source: String, Codable, Hashable {
        case editorial, venue, algorithmic, community
    }

    var priceLabel: String {
        String(repeating: "$", count: priceRange)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, categories, latitude, longitude, neighborhood
        case venueId = "venue_id"
        case priceRange = "price_range"
        case durationMinutes = "duration_minutes"
        case heroImage = "hero_image"
        case galleryImages = "gallery_images"
        case optInCount = "opt_in_count"
        case source
        case isVenuePackage = "is_venue_package"
        case expiresAt = "expires_at"
    }
}

// MARK: - Sample Data

extension DateExperience {
    static let samples: [DateExperience] = [
        DateExperience(
            id: "exp-1",
            title: "Sunset Rooftop Dinner",
            description: "A curated three-course dinner on a stunning downtown rooftop with panoramic city views. Perfect for a memorable first impression.",
            categories: [.dinnerAndDrinks, .nightlife],
            venueId: "venue-1",
            priceRange: 3,
            durationMinutes: 120,
            latitude: 40.7128,
            longitude: -74.0060,
            neighborhood: "Downtown",
            heroImage: "",
            galleryImages: [],
            optInCount: 12,
            source: .editorial,
            isVenuePackage: true
        ),
        DateExperience(
            id: "exp-2",
            title: "Morning Hike & Coffee",
            description: "A guided sunrise hike through scenic trails followed by artisan coffee at a trailside cafe. Low-key and genuine.",
            categories: [.outdoorAdventure, .coffeeAndBrunch],
            priceRange: 1,
            durationMinutes: 180,
            latitude: 40.7580,
            longitude: -73.9855,
            neighborhood: "Midtown",
            heroImage: "",
            galleryImages: [],
            optInCount: 8,
            source: .editorial,
            isVenuePackage: false
        ),
        DateExperience(
            id: "exp-3",
            title: "Pasta Making Class",
            description: "Learn to make fresh pasta from scratch at an intimate cooking studio. Work together, eat together.",
            categories: [.cooking, .dinnerAndDrinks],
            venueId: "venue-2",
            priceRange: 2,
            durationMinutes: 150,
            latitude: 40.7282,
            longitude: -73.7949,
            neighborhood: "East Village",
            heroImage: "",
            galleryImages: [],
            optInCount: 15,
            source: .venue,
            isVenuePackage: true
        ),
    ]
}
