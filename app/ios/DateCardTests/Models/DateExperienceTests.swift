import XCTest
@testable import DateCard

final class DateExperienceTests: XCTestCase {

    func testSampleDataExists() {
        XCTAssertFalse(DateExperience.samples.isEmpty)
        XCTAssertEqual(DateExperience.samples.count, 3)
    }

    func testSampleDataHasRequiredFields() {
        for experience in DateExperience.samples {
            XCTAssertFalse(experience.id.isEmpty, "Experience should have an ID")
            XCTAssertFalse(experience.title.isEmpty, "Experience should have a title")
            XCTAssertFalse(experience.description.isEmpty, "Experience should have a description")
            XCTAssertFalse(experience.categories.isEmpty, "Experience should have categories")
            XCTAssertGreaterThan(experience.durationMinutes, 0, "Duration should be positive")
            XCTAssertTrue((1...3).contains(experience.priceRange), "Price range should be 1-3")
        }
    }

    func testPriceLabel() {
        let cheap = DateExperience.samples.first { $0.priceRange == 1 }
        XCTAssertEqual(cheap?.priceLabel, "$")

        let mid = DateExperience.samples.first { $0.priceRange == 2 }
        XCTAssertEqual(mid?.priceLabel, "$$")

        let expensive = DateExperience.samples.first { $0.priceRange == 3 }
        XCTAssertEqual(expensive?.priceLabel, "$$$")
    }
}
