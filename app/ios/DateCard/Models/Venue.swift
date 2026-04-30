import Foundation

struct Venue: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var description: String?
    var photos: [String]
    var stripeConnectAccountId: String?
    var category: String?
    var priceRange: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, description, photos, category
        case stripeConnectAccountId = "stripe_connect_account_id"
        case priceRange = "price_range"
    }
}

struct VenuePackage: Identifiable, Codable, Hashable {
    let id: String
    var venueId: String
    var name: String
    var description: String?
    var priceCents: Int
    var includes: [String]
    var available: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case venueId = "venue_id"
        case name, description
        case priceCents = "price_cents"
        case includes, available
    }
}

struct Booking: Identifiable, Codable, Hashable {
    let id: String
    var matchId: String?
    var venueId: String
    var packageId: String?
    var userId: String
    var amountCents: Int
    var status: String

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case venueId = "venue_id"
        case packageId = "package_id"
        case userId = "user_id"
        case amountCents = "amount_cents"
        case status
    }
}
