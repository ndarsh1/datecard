import Foundation

@MainActor
final class BoardViewModel: ObservableObject {
    @Published var posts: [PlusOnePost] = []
    @Published var isLoading = false
    @Published var selectedEventType: PlusOnePost.EventType?

    private var supabaseService: SupabaseService?

    func configure(supabaseService: SupabaseService) {
        self.supabaseService = supabaseService
    }

    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }

        guard let supabaseService else {
            posts = PlusOnePost.samples
            return
        }

        do {
            posts = try await supabaseService.fetchBoardPosts(eventType: selectedEventType)
        } catch {
            posts = PlusOnePost.samples
        }
    }

    func createPost(
        eventName: String,
        eventType: PlusOnePost.EventType,
        eventDate: Date,
        locationName: String,
        dressCode: String?,
        vibe: String?,
        ticketIncluded: Bool,
        description: String
    ) async throws {
        guard let supabaseService else { return }
        try await supabaseService.createBoardPost(
            eventName: eventName,
            eventType: eventType,
            eventDate: eventDate,
            locationName: locationName,
            dressCode: dressCode,
            vibe: vibe,
            ticketIncluded: ticketIncluded,
            description: description
        )
        await loadPosts()
    }
}
