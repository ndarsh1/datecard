import SwiftUI

struct DateModeView: View {
    @StateObject private var viewModel = DateModeViewModel()
    @State private var showRating = false

    var body: some View {
        NavigationStack {
            Group {
                if let activeMatch = viewModel.activeMatch {
                    ActiveDateView(viewModel: viewModel, match: activeMatch, showRating: $showRating)
                } else {
                    ContentUnavailableView(
                        "No Active Date",
                        systemImage: "sparkle",
                        description: Text("Date Mode activates when both you and your match check in at the venue.")
                    )
                }
            }
            .navigationTitle("Date Mode")
            .sheet(isPresented: $showRating) {
                if let matchId = viewModel.lastEndedMatchId {
                    PostDateRatingView(matchId: matchId)
                }
            }
        }
    }
}

private struct ActiveDateView: View {
    @ObservedObject var viewModel: DateModeViewModel
    let match: Match
    @Binding var showRating: Bool
    @State private var showSafetyCheck = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Timer
                Text(viewModel.elapsedTimeFormatted)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(.secondary)

                // Current prompt card
                if let prompt = viewModel.currentPrompt {
                    LifelinePromptCard(prompt: prompt)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.accentColor)
                        Text("Tap a category below for a conversation prompt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 24)
                }

                // Prompt tier selector
                HStack(spacing: 12) {
                    ForEach(LifelinePrompt.Tier.allCases, id: \.self) { tier in
                        Button {
                            viewModel.requestPrompt(tier: tier)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tier.icon)
                                    .font(.title3)
                                Text(tier.displayName)
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Safety check + End date
                VStack(spacing: 12) {
                    Button {
                        showSafetyCheck = true
                    } label: {
                        Label("Safety Check", systemImage: "shield.checkered")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }

                    Button {
                        viewModel.endDate()
                        showRating = true
                    } label: {
                        Text("End Date")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom)
            }
            .padding()

            if showSafetyCheck {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showSafetyCheck = false }

                SafetyCheckOverlay(matchId: match.id) {
                    showSafetyCheck = false
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: showSafetyCheck)
    }
}

#Preview {
    DateModeView()
}
