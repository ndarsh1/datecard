import SwiftUI

struct DateModeView: View {
    @StateObject private var viewModel = DateModeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let activeMatch = viewModel.activeMatch {
                    ActiveDateView(viewModel: viewModel, match: activeMatch)
                } else {
                    ContentUnavailableView(
                        "No Active Date",
                        systemImage: "sparkle",
                        description: Text("Date Mode activates when both you and your match check in at the venue.")
                    )
                }
            }
            .navigationTitle("Date Mode")
        }
    }
}

private struct ActiveDateView: View {
    @ObservedObject var viewModel: DateModeViewModel
    let match: Match

    var body: some View {
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

            // End date button
            Button {
                viewModel.endDate()
            } label: {
                Text("End Date")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            .padding(.bottom)
        }
        .padding()
    }
}

#Preview {
    DateModeView()
}
