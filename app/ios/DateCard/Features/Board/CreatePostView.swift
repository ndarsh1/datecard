import SwiftUI

struct CreatePostView: View {
    @ObservedObject var viewModel: BoardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var eventName = ""
    @State private var eventType: PlusOnePost.EventType = .party
    @State private var eventDate = Date()
    @State private var locationName = ""
    @State private var dressCode = ""
    @State private var vibe = ""
    @State private var description = ""
    @State private var ticketIncluded = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event name", text: $eventName)

                    Picker("Type", selection: $eventType) {
                        ForEach(PlusOnePost.EventType.allCases, id: \.self) { type in
                            Text("\(type.emoji) \(type.rawValue.capitalized)")
                                .tag(type)
                        }
                    }

                    DatePicker("Date & Time", selection: $eventDate, in: Date()...)
                    TextField("Location", text: $locationName)
                }

                Section("Details") {
                    TextField("Dress code (optional)", text: $dressCode)
                    TextField("Vibe (optional)", text: $vibe)
                    Toggle("Ticket included", isOn: $ticketIncluded)
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        submitPost()
                    }
                    .disabled(!isValid || isSubmitting)
                }
            }
            .alert("Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var isValid: Bool {
        !eventName.isEmpty && !description.isEmpty && !locationName.isEmpty
    }

    private func submitPost() {
        isSubmitting = true
        Task {
            do {
                try await viewModel.createPost(
                    eventName: eventName,
                    eventType: eventType,
                    eventDate: eventDate,
                    locationName: locationName,
                    dressCode: dressCode.isEmpty ? nil : dressCode,
                    vibe: vibe.isEmpty ? nil : vibe,
                    ticketIncluded: ticketIncluded,
                    description: description
                )
                dismiss()
            } catch {
                errorMessage = "Failed to create post. Please try again."
                isSubmitting = false
            }
        }
    }
}

#Preview {
    CreatePostView(viewModel: BoardViewModel())
}
