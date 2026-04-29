import SwiftUI
import Kingfisher

struct OptInPoolView: View {
    let experienceId: String
    let experienceTitle: String
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var selectedUser: User?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if users.isEmpty {
                ContentUnavailableView(
                    "No One Yet",
                    systemImage: "person.2.slash",
                    description: Text("You're the first one in! More people will show up soon.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(users) { user in
                            PoolUserCard(user: user)
                                .onTapGesture { selectedUser = user }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Who's In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedUser) { user in
            NavigationStack {
                UserProfileView(user: user, experienceId: experienceId)
                    .environmentObject(supabaseService)
            }
        }
        .task {
            await loadPool()
        }
    }

    private func loadPool() async {
        isLoading = true
        defer { isLoading = false }
        do {
            users = try await supabaseService.fetchOptInPool(experienceId: experienceId)
        } catch {
            print("Failed to load pool: \(error)")
        }
    }
}

private struct PoolUserCard: View {
    let user: User

    var body: some View {
        VStack(spacing: 8) {
            if let firstPhoto = user.photos.first, !firstPhoto.isEmpty {
                KFImage(URL(string: firstPhoto))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.15))
                    .frame(width: 140, height: 180)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(spacing: 2) {
                Text(user.name)
                    .font(.subheadline.weight(.semibold))
                Text("\(user.age)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OptInPoolView(experienceId: "exp-1", experienceTitle: "Sunset Dinner")
            .environmentObject(SupabaseService())
    }
}
