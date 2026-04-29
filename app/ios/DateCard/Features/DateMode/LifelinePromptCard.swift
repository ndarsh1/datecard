import SwiftUI

struct LifelinePromptCard: View {
    let prompt: LifelinePrompt

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: prompt.tier.icon)
                Text(prompt.tier.displayName)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                Spacer()
            }
            .foregroundStyle(Color.accentColor)

            Text(prompt.text)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

#Preview {
    LifelinePromptCard(prompt: LifelinePrompt(
        id: "1",
        text: "What's the most spontaneous thing you've ever done?",
        tier: .conversationSparks
    ))
}
