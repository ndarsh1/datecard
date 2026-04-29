import SwiftUI
import Kingfisher

struct InterestListView: View {
    let postId: String
    @EnvironmentObject var supabaseService: SupabaseService
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [(interest: PlusOneInterest, user: User)] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if entries.isEmpty {
                    ContentUnavailableView(
                        "No Interest Yet",
                        systemImage: "person.2.slash",
                        description: Text("No one has expressed interest yet. Check back later!")
                    )
                } else {
                    List {
                        ForEach(entries, id: \.interest.id) { entry in
                            InterestRow(
                                interest: entry.interest,
                                user: entry.user,
                                onAccept: { acceptInterest(entry) },
                                onPass: { passInterest(entry) }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Interested (\(entries.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await loadInterests()
            }
        }
    }

    private func loadInterests() async {
        isLoading = true
        defer { isLoading = false }
        do {
            entries = try await supabaseService.fetchInterests(postId: postId)
        } catch {
            print("Failed to load interests: \(error)")
        }
    }

    private func acceptInterest(_ entry: (interest: PlusOneInterest, user: User)) {
        Task {
            do {
                try await supabaseService.acceptInterest(interest: entry.interest, postId: postId)
                await loadInterests()
            } catch {
                print("Accept failed: \(error)")
            }
        }
    }

    private func passInterest(_ entry: (interest: PlusOneInterest, user: User)) {
        Task {
            do {
                try await supabaseService.updateInterestStatus(interestId: entry.interest.id, status: .passed)
                await loadInterests()
            } catch {
                print("Pass failed: \(error)")
            }
        }
    }
}

private struct InterestRow: View {
    let interest: PlusOneInterest
    let user: User
    let onAccept: () -> Void
    let onPass: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if let photo = user.photos.first, !photo.isEmpty {
                    KFImage(URL(string: photo))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                        }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(user.name), \(user.age)")
                        .font(.headline)
                    if let note = interest.note, !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }

            if interest.status == .pending {
                HStack(spacing: 12) {
                    Button {
                        onPass()
                    } label: {
                        Text("Pass")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onAccept()
                    } label: {
                        Text("Accept")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text(interest.status == .accepted ? "Accepted" : "Passed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(interest.status == .accepted ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InterestListView(postId: "test")
        .environmentObject(SupabaseService())
}
