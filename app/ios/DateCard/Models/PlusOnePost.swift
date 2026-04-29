import Foundation

struct PlusOnePost: Identifiable, Codable, Hashable {
    let id: String
    var userId: String
    var eventName: String
    var eventType: EventType
    var eventDate: Date
    var locationName: String
    var latitude: Double?
    var longitude: Double?
    var dressCode: String?
    var vibe: String?
    var ticketIncluded: Bool
    var description: String
    var expiresAt: Date

    enum EventType: String, Codable, CaseIterable, Hashable {
        case wedding, gala, concert, party, sports, other

        var emoji: String {
            switch self {
            case .wedding: "💒"
            case .gala: "🎭"
            case .concert: "🎤"
            case .party: "🎉"
            case .sports: "🏟️"
            case .other: "📌"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventName = "event_name"
        case eventType = "event_type"
        case eventDate = "event_date"
        case locationName = "location_name"
        case latitude, longitude
        case dressCode = "dress_code"
        case vibe
        case ticketIncluded = "ticket_included"
        case description
        case expiresAt = "expires_at"
    }
}

struct PlusOneInterest: Identifiable, Codable, Hashable {
    let id: String
    var postId: String
    var userId: String
    var note: String?
    var status: Status

    enum Status: String, Codable, Hashable {
        case pending, accepted, passed
    }

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case note, status
    }
}

// MARK: - Sample Data

extension PlusOnePost {
    static let samples: [PlusOnePost] = [
        PlusOnePost(
            id: "post-1",
            userId: "user-1",
            eventName: "Jazz at Lincoln Center",
            eventType: .concert,
            eventDate: Date().addingTimeInterval(86400 * 3),
            locationName: "Lincoln Center",
            dressCode: "Smart casual",
            vibe: "Intimate, sophisticated",
            ticketIncluded: true,
            description: "I have an extra ticket for an amazing jazz show this weekend. Looking for someone who appreciates live music and good conversation.",
            expiresAt: Date().addingTimeInterval(86400 * 3)
        ),
        PlusOnePost(
            id: "post-2",
            userId: "user-2",
            eventName: "Friend's Gallery Opening",
            eventType: .gala,
            eventDate: Date().addingTimeInterval(86400 * 5),
            locationName: "Chelsea Gallery District",
            dressCode: "All black",
            vibe: "Artsy, creative crowd",
            ticketIncluded: true,
            description: "My friend is opening a new photography exhibit. Would love to bring someone who enjoys art and meeting creative people.",
            expiresAt: Date().addingTimeInterval(86400 * 5)
        ),
    ]
}
