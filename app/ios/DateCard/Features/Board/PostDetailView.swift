import SwiftUI

struct PostDetailView: View {
    let post: PlusOnePost
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var interestNote = ""
    @State private var hasExpressedInterest = false
    @State private var isSubmitting = false
    @State private var showInterests = false

    private var isMyPost: Bool {
        post.userId == supabaseService.currentUser?.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(post.eventType.emoji)
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(post.eventName)
                                .font(.title2.bold())
                            Text(post.eventDate.formatted(date: .complete, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Label(post.locationName, systemImage: "mappin")
                        .font(.subheadline)

                    if let dressCode = post.dressCode {
                        Label(dressCode, systemImage: "tshirt.fill")
                            .font(.subheadline)
                    }

                    if post.ticketIncluded {
                        Label("Ticket included", systemImage: "ticket.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }

                Divider()

                Text(post.description)
                    .font(.body)

                if let vibe = post.vibe {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vibe")
                            .font(.headline)
                        Text(vibe)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            if isMyPost {
                Button {
                    showInterests = true
                } label: {
                    Text("View Interested")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding()
                .background(.ultraThinMaterial)
            } else if !hasExpressedInterest {
                VStack(spacing: 12) {
                    TextField("Why you'd be a great +1...", text: $interestNote, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)

                    Button {
                        expressInterest()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("I'm Interested")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(isSubmitting)
                }
                .padding()
                .background(.ultraThinMaterial)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Interest sent!")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInterests) {
            InterestListView(postId: post.id)
                .environmentObject(supabaseService)
        }
    }

    private func expressInterest() {
        isSubmitting = true
        Task {
            do {
                try await supabaseService.expressInterest(postId: post.id, note: interestNote.isEmpty ? nil : interestNote)
                hasExpressedInterest = true
            } catch {
                print("Interest failed: \(error)")
            }
            isSubmitting = false
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: .samples[0])
            .environmentObject(SupabaseService())
    }
}
