import XCTest
@testable import DateCard

final class MatchTests: XCTestCase {

    func testLifelinePromptRandomGeneration() {
        let prompt = LifelinePrompt.random(tier: .conversationSparks)
        XCTAssertFalse(prompt.id.isEmpty)
        XCTAssertFalse(prompt.text.isEmpty)
        XCTAssertEqual(prompt.tier, .conversationSparks)
    }

    func testLifelinePromptAllTiers() {
        for tier in LifelinePrompt.Tier.allCases {
            let prompt = LifelinePrompt.random(tier: tier)
            XCTAssertEqual(prompt.tier, tier)
            XCTAssertFalse(prompt.text.isEmpty)
            XCTAssertFalse(tier.displayName.isEmpty)
            XCTAssertFalse(tier.icon.isEmpty)
        }
    }

    func testPlusOnePostSamples() {
        XCTAssertFalse(PlusOnePost.samples.isEmpty)
        for post in PlusOnePost.samples {
            XCTAssertFalse(post.eventName.isEmpty)
            XCTAssertFalse(post.description.isEmpty)
            XCTAssertTrue(post.eventDate > Date())
        }
    }

    func testEventTypeEmoji() {
        for type in PlusOnePost.EventType.allCases {
            XCTAssertFalse(type.emoji.isEmpty, "\(type.rawValue) should have an emoji")
        }
    }
}
