import XCTest
@testable import DateCard

final class UserTests: XCTestCase {

    func testDateStyleCardInitialization() {
        let card = DateStyleCard(adventurous: 75, planner: 60, talker: 80, foodie: 90)
        XCTAssertEqual(card.adventurous, 75)
        XCTAssertEqual(card.planner, 60)
        XCTAssertEqual(card.talker, 80)
        XCTAssertEqual(card.foodie, 90)
    }

    func testDateCategoryDisplayName() {
        XCTAssertEqual(DateCategory.dinnerAndDrinks.displayName, "Dinner & Drinks")
        XCTAssertEqual(DateCategory.outdoorAdventure.displayName, "Outdoor Adventure")
        XCTAssertEqual(DateCategory.liveMusic.displayName, "Live Music")
        XCTAssertEqual(DateCategory.coffeeAndBrunch.displayName, "Coffee & Brunch")
    }

    func testDateCategoryEmoji() {
        XCTAssertFalse(DateCategory.dinnerAndDrinks.emoji.isEmpty)
        for category in DateCategory.allCases {
            XCTAssertFalse(category.emoji.isEmpty, "\(category.rawValue) should have an emoji")
            XCTAssertFalse(category.displayName.isEmpty, "\(category.rawValue) should have a display name")
        }
    }

    func testDateCategoryAllCasesCount() {
        XCTAssertEqual(DateCategory.allCases.count, 12)
    }
}
