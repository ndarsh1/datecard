import Foundation
import Combine
import Supabase
import PostgREST

@MainActor
final class SupabaseService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var session: Session?

    let client: SupabaseClient

    init() {
        self.client = SupabaseClient(
            supabaseURL: Configuration.supabaseURL,
            supabaseKey: Configuration.supabaseAnonKey
        )
    }

    // MARK: - Session

    func restoreSession() async {
        do {
            let session = try await client.auth.session
            self.session = session
            self.isAuthenticated = true
            await loadCurrentUser()
        } catch {
            self.isAuthenticated = false
        }
    }

    // MARK: - Phone Auth

    func signInWithPhone(phone: String) async throws {
        try await client.auth.signInWithOTP(phone: phone)
    }

    func verifyOTP(phone: String, code: String) async throws {
        let response = try await client.auth.verifyOTP(
            phone: phone,
            token: code,
            type: .sms
        )
        self.session = response.session
        self.isAuthenticated = true
    }

    func signOut() async {
        try? await client.auth.signOut()
        self.session = nil
        self.isAuthenticated = false
        self.currentUser = nil
    }

    // MARK: - User Profile

    func loadCurrentUser() async {
        guard let authId = session?.user.id else { return }
        do {
            let users: [User] = try await client.from("users")
                .select()
                .eq("auth_id", value: authId.uuidString)
                .execute()
                .value
            self.currentUser = users.first
        } catch {
            print("Failed to load user: \(error)")
        }
    }

    func checkOnboardingComplete() async -> Bool {
        guard let authId = session?.user.id else { return false }
        do {
            let users: [User] = try await client.from("users")
                .select()
                .eq("auth_id", value: authId.uuidString)
                .execute()
                .value
            return users.first?.onboardingComplete ?? false
        } catch {
            return false
        }
    }

    func createProfile(
        name: String,
        age: Int,
        photos: [String],
        dateStyleCard: DateStyleCard,
        favoriteDateTypes: [DateCategory],
        dreamDate: String
    ) async throws {
        guard let authId = session?.user.id,
              let phone = session?.user.phone else { return }

        let profileData: [String: AnyJSON] = [
            "auth_id": .string(authId.uuidString),
            "phone": .string(phone),
            "name": .string(name),
            "age": .integer(age),
            "photos": .array(photos.map { .string($0) }),
            "date_style_card": .object([
                "adventurous": .integer(dateStyleCard.adventurous),
                "planner": .integer(dateStyleCard.planner),
                "talker": .integer(dateStyleCard.talker),
                "foodie": .integer(dateStyleCard.foodie),
            ]),
            "favorite_date_types": .array(favoriteDateTypes.map { .string($0.rawValue) }),
            "dream_date": .string(dreamDate),
            "onboarding_complete": .bool(true),
        ]

        try await client.from("users")
            .upsert(profileData, onConflict: "auth_id")
            .execute()

        await loadCurrentUser()
    }

    func updateProfile(_ user: User) async throws {
        try await client.from("users")
            .update(user)
            .eq("id", value: user.id)
            .execute()
        self.currentUser = user
    }

    // MARK: - Photo Storage

    func uploadPhoto(imageData: Data, userId: String, index: Int) async throws -> String {
        let path = "profiles/\(userId)/photo_\(index).jpg"
        try await client.storage.from("profile-photos")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))

        let publicURL = try client.storage.from("profile-photos").getPublicURL(path: path)
        return publicURL.absoluteString
    }

    // MARK: - Experiences

    func fetchExperiences(category: DateCategory? = nil, limit: Int = 20, offset: Int = 0) async throws -> [DateExperience] {
        let filterBuilder = client.from("date_experiences").select()

        let filtered: PostgrestFilterBuilder
        if let category {
            filtered = filterBuilder.contains("categories", value: [category.rawValue])
        } else {
            filtered = filterBuilder
        }

        let experiences: [DateExperience] = try await filtered
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return experiences
    }

    func fetchExperience(id: String) async throws -> DateExperience {
        let experience: DateExperience = try await client.from("date_experiences")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return experience
    }

    // MARK: - Opt-Ins

    func optIn(experienceId: String) async throws {
        guard let userId = currentUser?.id else { return }
        let data: [String: AnyJSON] = [
            "user_id": .string(userId),
            "experience_id": .string(experienceId),
        ]
        try await client.from("opt_ins")
            .insert(data)
            .execute()
    }

    func hasOptedIn(experienceId: String) async -> Bool {
        guard let userId = currentUser?.id else { return false }
        do {
            let optIns: [OptInRecord] = try await client.from("opt_ins")
                .select()
                .eq("user_id", value: userId)
                .eq("experience_id", value: experienceId)
                .execute()
                .value
            return !optIns.isEmpty
        } catch {
            return false
        }
    }

    func optInCount(experienceId: String) async -> Int {
        do {
            let records: [OptInRecord] = try await client.from("opt_ins")
                .select()
                .eq("experience_id", value: experienceId)
                .execute()
                .value
            return records.count
        } catch {
            return 0
        }
    }
    // MARK: - Pool

    func fetchOptInPool(experienceId: String) async throws -> [User] {
        guard let userId = currentUser?.id else { return [] }

        // Get all user IDs who opted into this experience (excluding self)
        let optIns: [OptInRecord] = try await client.from("opt_ins")
            .select()
            .eq("experience_id", value: experienceId)
            .neq("user_id", value: userId)
            .execute()
            .value

        let userIds = optIns.map(\.userId)
        guard !userIds.isEmpty else { return [] }

        let users: [User] = try await client.from("users")
            .select()
            .in("id", values: userIds)
            .execute()
            .value
        return users
    }

    // MARK: - Matches

    func requestMatch(targetUserId: String, experienceId: String) async throws {
        guard let userId = currentUser?.id else { return }
        let data: [String: AnyJSON] = [
            "user_a": .string(userId),
            "user_b": .string(targetUserId),
            "experience_id": .string(experienceId),
            "status": .string("pending"),
        ]
        try await client.from("matches")
            .insert(data)
            .execute()
    }

    func fetchMatches() async throws -> [Match] {
        guard let userId = currentUser?.id else { return [] }
        let matches: [Match] = try await client.from("matches")
            .select()
            .or("user_a.eq.\(userId),user_b.eq.\(userId)")
            .order("created_at", ascending: false)
            .execute()
            .value
        return matches
    }

    // MARK: - +1 Board

    func fetchBoardPosts(eventType: PlusOnePost.EventType? = nil, limit: Int = 20, offset: Int = 0) async throws -> [PlusOnePost] {
        let filterBuilder = client.from("plus_one_posts")
            .select()
            .gte("expires_at", value: ISO8601DateFormatter().string(from: Date()))

        let filtered: PostgrestFilterBuilder
        if let eventType {
            filtered = filterBuilder.eq("event_type", value: eventType.rawValue)
        } else {
            filtered = filterBuilder
        }

        let posts: [PlusOnePost] = try await filtered
            .order("event_date", ascending: true)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return posts
    }

    func createBoardPost(
        eventName: String,
        eventType: PlusOnePost.EventType,
        eventDate: Date,
        locationName: String,
        dressCode: String?,
        vibe: String?,
        ticketIncluded: Bool,
        description: String
    ) async throws {
        guard let userId = currentUser?.id else { return }
        let formatter = ISO8601DateFormatter()
        let data: [String: AnyJSON] = [
            "user_id": .string(userId),
            "event_name": .string(eventName),
            "event_type": .string(eventType.rawValue),
            "event_date": .string(formatter.string(from: eventDate)),
            "location_name": .string(locationName),
            "dress_code": dressCode.map { .string($0) } ?? .null,
            "vibe": vibe.map { .string($0) } ?? .null,
            "ticket_included": .bool(ticketIncluded),
            "description": .string(description),
            "expires_at": .string(formatter.string(from: eventDate)),
        ]
        try await client.from("plus_one_posts")
            .insert(data)
            .execute()
    }

    func expressInterest(postId: String, note: String?) async throws {
        guard let userId = currentUser?.id else { return }
        let data: [String: AnyJSON] = [
            "post_id": .string(postId),
            "user_id": .string(userId),
            "note": note.map { .string($0) } ?? .null,
            "status": .string("pending"),
        ]
        try await client.from("plus_one_interests")
            .insert(data)
            .execute()
    }

    func fetchInterests(postId: String) async throws -> [(interest: PlusOneInterest, user: User)] {
        let interests: [PlusOneInterest] = try await client.from("plus_one_interests")
            .select()
            .eq("post_id", value: postId)
            .order("created_at", ascending: false)
            .execute()
            .value

        var results: [(interest: PlusOneInterest, user: User)] = []
        for interest in interests {
            let users: [User] = try await client.from("users")
                .select()
                .eq("id", value: interest.userId)
                .execute()
                .value
            if let user = users.first {
                results.append((interest, user))
            }
        }
        return results
    }

    func updateInterestStatus(interestId: String, status: PlusOneInterest.Status) async throws {
        try await client.from("plus_one_interests")
            .update(["status": status.rawValue])
            .eq("id", value: interestId)
            .execute()
    }

    func acceptInterest(interest: PlusOneInterest, postId: String) async throws {
        try await updateInterestStatus(interestId: interest.id, status: .accepted)

        // Create a match from the board
        guard let userId = currentUser?.id else { return }
        let data: [String: AnyJSON] = [
            "user_a": .string(userId),
            "user_b": .string(interest.userId),
            "plus_one_post_id": .string(postId),
            "status": .string("matched"),
        ]
        try await client.from("matches")
            .insert(data)
            .execute()
    }

    // MARK: - Blocking & Reporting

    func blockUser(id: String) async throws {
        guard let userId = currentUser?.id else { return }
        let data: [String: AnyJSON] = [
            "blocker_id": .string(userId),
            "blocked_id": .string(id),
        ]
        try await client.from("blocked_users")
            .insert(data)
            .execute()
    }

    func reportUser(id: String, reason: String, details: String) async throws {
        guard let userId = currentUser?.id else { return }
        let data: [String: AnyJSON] = [
            "reporter_id": .string(userId),
            "reported_id": .string(id),
            "reason": .string(reason),
            "details": .string(details),
        ]
        try await client.from("reports")
            .insert(data)
            .execute()
    }
}

// Simple record for opt-in queries
private struct OptInRecord: Decodable {
    let id: String
    let userId: String
    let experienceId: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case experienceId = "experience_id"
    }
}
