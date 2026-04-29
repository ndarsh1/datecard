import SwiftUI

struct BoardView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @StateObject private var viewModel = BoardViewModel()
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.posts.isEmpty {
                    ContentUnavailableView(
                        "No Posts Yet",
                        systemImage: "person.2",
                        description: Text("Be the first to post! Find a +1 for your next event.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Event type filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    FilterChip(title: "All", isSelected: viewModel.selectedEventType == nil) {
                                        viewModel.selectedEventType = nil
                                        Task { await viewModel.loadPosts() }
                                    }
                                    ForEach(PlusOnePost.EventType.allCases, id: \.self) { type in
                                        FilterChip(
                                            title: "\(type.emoji) \(type.rawValue.capitalized)",
                                            isSelected: viewModel.selectedEventType == type
                                        ) {
                                            viewModel.selectedEventType = type
                                            Task { await viewModel.loadPosts() }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.posts) { post in
                                    NavigationLink(value: post) {
                                        BoardPostCard(post: post)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("+1 Board")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView(viewModel: viewModel)
            }
            .navigationDestination(for: PlusOnePost.self) { post in
                PostDetailView(post: post)
            }
            .refreshable {
                await viewModel.loadPosts()
            }
            .task {
                viewModel.configure(supabaseService: supabaseService)
                await viewModel.loadPosts()
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : .gray.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

private struct BoardPostCard: View {
    let post: PlusOnePost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(post.eventType.emoji)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.eventName)
                        .font(.headline)
                    Text(post.eventDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if post.ticketIncluded {
                    Label("Ticket", systemImage: "ticket.fill")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }

            if let dressCode = post.dressCode {
                Text("Dress code: \(dressCode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(post.description)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding()
        .background(.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    BoardView()
        .environmentObject(SupabaseService())
}
