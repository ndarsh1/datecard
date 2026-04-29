import SwiftUI
import Kingfisher

struct UserProfileView: View {
    let user: User
    let experienceId: String?
    @EnvironmentObject var supabaseService: SupabaseService
    @Environment(\.dismiss) private var dismiss
    @State private var showBlockReport = false
    @State private var matchRequested = false
    @State private var isRequesting = false

    init(user: User, experienceId: String? = nil) {
        self.user = user
        self.experienceId = experienceId
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Photo carousel
                TabView {
                    ForEach(user.photos, id: \.self) { photoURL in
                        KFImage(URL(string: photoURL))
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .clipped()
                    }
                }
                .frame(height: 400)
                .tabViewStyle(.page)

                VStack(spacing: 16) {
                    // Name, age, verification
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Text("\(user.name), \(user.age)")
                                .font(.title2.bold())
                            if user.verifiedPhoto {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }

                    // Date Style Card
                    DateStyleChart(card: user.dateStyleCard)
                        .frame(height: 200)

                    // Favorite types
                    if !user.favoriteDateTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Favorite Date Types")
                                .font(.headline)
                            FlowLayout(spacing: 8) {
                                ForEach(user.favoriteDateTypes, id: \.self) { category in
                                    Text("\(category.emoji) \(category.displayName)")
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Dream date
                    if !user.dreamDate.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dream Date")
                                .font(.headline)
                            Text(user.dreamDate)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            if experienceId != nil {
                Button {
                    requestMatch()
                } label: {
                    if isRequesting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(matchRequested ? "Request Sent!" : "Match")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(matchRequested ? .green : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(matchRequested || isRequesting)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        showBlockReport = true
                    } label: {
                        Label("Block or Report", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showBlockReport) {
            BlockReportSheet(userId: user.id)
                .environmentObject(supabaseService)
        }
    }

    private func requestMatch() {
        guard let experienceId else { return }
        isRequesting = true
        Task {
            do {
                try await supabaseService.requestMatch(targetUserId: user.id, experienceId: experienceId)
                matchRequested = true
            } catch {
                print("Match request failed: \(error)")
            }
            isRequesting = false
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            user: User(
                id: "preview",
                name: "Alex",
                age: 28,
                photos: [],
                dateStyleCard: DateStyleCard(adventurous: 75, planner: 60, talker: 80, foodie: 90),
                favoriteDateTypes: [.dinnerAndDrinks, .outdoorAdventure, .liveMusic],
                dreamDate: "A sunset picnic overlooking the city.",
                verifiedPhoto: true,
                verifiedId: false,
                onboardingComplete: true
            ),
            experienceId: "exp-1"
        )
        .environmentObject(SupabaseService())
    }
}
