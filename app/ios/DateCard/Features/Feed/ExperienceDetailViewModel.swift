import Foundation

@MainActor
final class ExperienceDetailViewModel: ObservableObject {
    @Published var hasOptedIn = false
    @Published var isLoading = false
    @Published var optInCount = 0

    private var supabaseService: SupabaseService?

    func configure(supabaseService: SupabaseService, experienceId: String) {
        self.supabaseService = supabaseService
        Task {
            hasOptedIn = await supabaseService.hasOptedIn(experienceId: experienceId)
            optInCount = await supabaseService.optInCount(experienceId: experienceId)
        }
    }

    func optIn(experienceId: String) async {
        guard let supabaseService, !hasOptedIn else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await supabaseService.optIn(experienceId: experienceId)
            hasOptedIn = true
            optInCount += 1
        } catch {
            print("Opt-in failed: \(error)")
        }
    }
}
