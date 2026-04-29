import XCTest
@testable import DateCard

@MainActor
final class FeedViewModelTests: XCTestCase {

    func testInitialState() {
        let viewModel = FeedViewModel()
        XCTAssertTrue(viewModel.experiences.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadExperiences() async {
        let viewModel = FeedViewModel()
        await viewModel.loadExperiences()
        XCTAssertFalse(viewModel.experiences.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFilteredExperiencesNoFilter() async {
        let viewModel = FeedViewModel()
        await viewModel.loadExperiences()
        let all = viewModel.filteredExperiences(for: nil)
        XCTAssertEqual(all.count, viewModel.experiences.count)
    }

    func testFilteredExperiencesByCategory() async {
        let viewModel = FeedViewModel()
        await viewModel.loadExperiences()

        let filtered = viewModel.filteredExperiences(for: .cooking)
        XCTAssertTrue(filtered.allSatisfy { $0.categories.contains(.cooking) })
    }

    func testFilteredExperiencesNonMatchingCategory() async {
        let viewModel = FeedViewModel()
        await viewModel.loadExperiences()

        let filtered = viewModel.filteredExperiences(for: .volunteering)
        // No sample experiences have volunteering category
        XCTAssertTrue(filtered.isEmpty)
    }
}
