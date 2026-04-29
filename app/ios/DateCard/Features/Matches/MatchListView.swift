import SwiftUI
import Kingfisher

struct MatchListView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var matches: [Match] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if matches.isEmpty {
                    ContentUnavailableView(
                        "No Matches Yet",
                        systemImage: "heart.slash",
                        description: Text("Opt in to experiences and match with people who share your interests.")
                    )
                } else {
                    List(matches) { match in
                        NavigationLink(value: match) {
                            MatchRow(match: match, currentUserId: supabaseService.currentUser?.id ?? "")
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Matches")
            .navigationDestination(for: Match.self) { match in
                ChatView(match: match)
            }
            .refreshable {
                await loadMatches()
            }
            .task {
                await loadMatches()
            }
        }
    }

    private func loadMatches() async {
        isLoading = matches.isEmpty
        defer { isLoading = false }
        do {
            matches = try await supabaseService.fetchMatches()
        } catch {
            print("Failed to load matches: \(error)")
        }
    }
}

private struct MatchRow: View {
    let match: Match
    let currentUserId: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("Match")
                    .font(.headline)
                HStack(spacing: 6) {
                    StatusBadge(status: match.status)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct StatusBadge: View {
    let status: Match.Status

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch status {
        case .pending: .orange
        case .matched: .green
        case .confirmed: .blue
        case .completed: .gray
        }
    }
}

#Preview {
    MatchListView()
        .environmentObject(SupabaseService())
}
