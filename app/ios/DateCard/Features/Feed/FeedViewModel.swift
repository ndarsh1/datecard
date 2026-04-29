import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var experiences: [DateExperience] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasMore = true

    private var offset = 0
    private let pageSize = 20
    private var supabaseService: SupabaseService?

    func configure(supabaseService: SupabaseService) {
        self.supabaseService = supabaseService
    }

    func loadExperiences(category: DateCategory? = nil) async {
        isLoading = true
        offset = 0
        defer { isLoading = false }

        guard let supabaseService else {
            // Fallback to sample data when not configured
            experiences = DateExperience.samples
            return
        }

        do {
            experiences = try await supabaseService.fetchExperiences(category: category, limit: pageSize, offset: 0)
            hasMore = experiences.count == pageSize
            offset = experiences.count
        } catch {
            // Fall back to sample data if Supabase isn't configured yet
            experiences = DateExperience.samples
            self.error = error
        }
    }

    func loadMore(category: DateCategory? = nil) async {
        guard hasMore, !isLoading, let supabaseService else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let newExperiences = try await supabaseService.fetchExperiences(category: category, limit: pageSize, offset: offset)
            experiences.append(contentsOf: newExperiences)
            hasMore = newExperiences.count == pageSize
            offset += newExperiences.count
        } catch {
            self.error = error
        }
    }

    func filteredExperiences(for category: DateCategory?) -> [DateExperience] {
        guard let category else { return experiences }
        return experiences.filter { $0.categories.contains(category) }
    }
}
