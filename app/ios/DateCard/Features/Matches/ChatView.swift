import SwiftUI

struct ChatView: View {
    let match: Match
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []

    var body: some View {
        VStack(spacing: 0) {
            // Context banner
            HStack {
                Image(systemName: "sparkles")
                Text("Matched on an experience")
                    .font(.caption.weight(.medium))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))

            // Messages
            ScrollView {
                if messages.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Say hello!")
                            .font(.headline)
                        Text("Start a conversation about the experience you matched on.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }
            }

            // Input
            HStack(spacing: 12) {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        // TODO: Send via Stream Chat SDK when integrated
        let message = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        messages.append(message)
        messageText = ""
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isFromCurrentUser ? Color.accentColor : .gray.opacity(0.15))
                .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            if !message.isFromCurrentUser { Spacer() }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

#Preview {
    NavigationStack {
        ChatView(match: Match(
            id: "preview",
            userA: "user1",
            userB: "user2",
            experienceId: "exp-1",
            status: .matched,
            chatChannelId: "ch-preview"
        ))
    }
}
