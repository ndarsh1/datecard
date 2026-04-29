import SwiftUI

struct SafetyCheckOverlay: View {
    let matchId: String
    let onDismiss: () -> Void

    @State private var feeling: Feeling?

    enum Feeling: String, CaseIterable {
        case great = "Great!"
        case okay = "It's okay"
        case uncomfortable = "Uncomfortable"
        case unsafe = "I need help"

        var icon: String {
            switch self {
            case .great: "hand.thumbsup.fill"
            case .okay: "hand.raised.fill"
            case .uncomfortable: "exclamationmark.triangle.fill"
            case .unsafe: "sos"
            }
        }

        var color: Color {
            switch self {
            case .great: .green
            case .okay: .blue
            case .uncomfortable: .orange
            case .unsafe: .red
            }
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Safety Check-In")
                .font(.title2.bold())

            Text("How are you feeling?")
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(Feeling.allCases, id: \.self) { option in
                    Button {
                        feeling = option
                        handleResponse(option)
                    } label: {
                        HStack {
                            Image(systemName: option.icon)
                                .foregroundStyle(option.color)
                            Text(option.rawValue)
                            Spacer()
                        }
                        .padding()
                        .background(feeling == option ? option.color.opacity(0.15) : .gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding()
    }

    private func handleResponse(_ feeling: Feeling) {
        switch feeling {
        case .unsafe:
            // TODO: Trigger emergency flow — share location with emergency contact
            break
        case .uncomfortable:
            // TODO: Offer to end date, share location
            break
        default:
            break
        }

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            onDismiss()
        }
    }
}

#Preview {
    SafetyCheckOverlay(matchId: "test") { }
}
