import Foundation

struct Match: Identifiable, Codable, Hashable {
    let id: String
    var userA: String
    var userB: String
    var experienceId: String
    var plusOnePostId: String?
    var status: Status
    var chatChannelId: String?

    enum Status: String, Codable, Hashable {
        case pending, matched, confirmed, completed
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userA = "user_a"
        case userB = "user_b"
        case experienceId = "experience_id"
        case plusOnePostId = "plus_one_post_id"
        case status
        case chatChannelId = "chat_channel_id"
    }
}

struct LifelinePrompt: Identifiable, Hashable {
    let id: String
    let text: String
    let tier: Tier

    enum Tier: String, CaseIterable, Hashable {
        case conversationSparks = "conversation_sparks"
        case games
        case challenges
        case deepDive = "deep_dive"

        var displayName: String {
            switch self {
            case .conversationSparks: "Sparks"
            case .games: "Games"
            case .challenges: "Challenges"
            case .deepDive: "Deep Dive"
            }
        }

        var icon: String {
            switch self {
            case .conversationSparks: "bubble.left.and.bubble.right"
            case .games: "gamecontroller"
            case .challenges: "flame"
            case .deepDive: "water.waves"
            }
        }
    }

    static func random(tier: Tier) -> LifelinePrompt {
        let prompts: [Tier: [String]] = [
            .conversationSparks: [
                "What's the most spontaneous thing you've ever done?",
                "If you could live anywhere for a year, where would it be?",
                "What's a skill you'd love to learn?",
                "What's the best meal you've ever had?",
            ],
            .games: [
                "Two truths and a lie — go!",
                "Would you rather: time travel to the past or the future?",
                "Rock paper scissors — loser tells an embarrassing story",
            ],
            .challenges: [
                "Teach each other something in 60 seconds",
                "Describe your perfect day without using the word 'relax'",
                "Take a photo together that captures this moment",
            ],
            .deepDive: [
                "What's something you've changed your mind about recently?",
                "What does your ideal Tuesday look like?",
                "What's a dream you haven't told many people about?",
            ],
        ]

        let options = prompts[tier] ?? []
        let text = options.randomElement() ?? "Tell me something surprising about yourself."
        return LifelinePrompt(id: UUID().uuidString, text: text, tier: tier)
    }
}
