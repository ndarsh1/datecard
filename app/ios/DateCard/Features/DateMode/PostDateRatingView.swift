import SwiftUI

struct PostDateRatingView: View {
    let matchId: String
    @EnvironmentObject var supabaseService: SupabaseService
    @Environment(\.dismiss) private var dismiss
    @State private var overallScore = 4
    @State private var wouldGoAgain = true
    @State private var feedbackText = ""
    @State private var isSubmitting = false
    @State private var didSubmit = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                if didSubmit {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color.accentColor)
                        Text("Thanks for rating!")
                            .font(.title2.bold())
                        Text("Your feedback helps us curate better experiences.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 24) {
                        Text("How was the experience?")
                            .font(.title2.bold())

                        // Star rating
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= overallScore ? "star.fill" : "star")
                                    .font(.title)
                                    .foregroundStyle(star <= overallScore ? .yellow : .gray.opacity(0.3))
                                    .onTapGesture { overallScore = star }
                            }
                        }

                        // Would go again
                        VStack(spacing: 8) {
                            Text("Would you go on another date?")
                                .font(.headline)
                            HStack(spacing: 16) {
                                ToggleButton(title: "Yes!", isSelected: wouldGoAgain) {
                                    wouldGoAgain = true
                                }
                                ToggleButton(title: "Not sure", isSelected: !wouldGoAgain) {
                                    wouldGoAgain = false
                                }
                            }
                        }

                        // Feedback
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Any thoughts? (optional)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $feedbackText)
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(.gray.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button {
                        submitRating()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Submit Rating")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(isSubmitting)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Rate Your Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(didSubmit ? "Done" : "Skip") { dismiss() }
                }
            }
        }
    }

    private func submitRating() {
        isSubmitting = true
        Task {
            do {
                try await supabaseService.submitDateRating(
                    matchId: matchId,
                    overallScore: overallScore,
                    wouldGoAgain: wouldGoAgain,
                    feedbackText: feedbackText.isEmpty ? nil : feedbackText
                )
                didSubmit = true
            } catch {
                print("Rating failed: \(error)")
            }
            isSubmitting = false
        }
    }
}

private struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isSelected ? Color.accentColor.opacity(0.15) : .gray.opacity(0.08))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PostDateRatingView(matchId: "test")
        .environmentObject(SupabaseService())
}
