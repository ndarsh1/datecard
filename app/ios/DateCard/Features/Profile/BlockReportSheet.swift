import SwiftUI

struct BlockReportSheet: View {
    let userId: String
    @EnvironmentObject var supabaseService: SupabaseService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAction: Action?
    @State private var reportReason: ReportReason?
    @State private var reportDetails = ""
    @State private var isSubmitting = false
    @State private var didComplete = false

    enum Action: String, CaseIterable {
        case block = "Block"
        case report = "Report"
    }

    enum ReportReason: String, CaseIterable {
        case fakeProfile = "Fake profile"
        case inappropriatePhotos = "Inappropriate photos"
        case harassment = "Harassment"
        case spam = "Spam"
        case other = "Other"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if didComplete {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                        Text("Done")
                            .font(.title3.bold())
                        Text("Thanks for helping keep DateCard safe.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                } else if selectedAction == nil {
                    VStack(spacing: 16) {
                        ForEach(Action.allCases, id: \.self) { action in
                            Button {
                                selectedAction = action
                            } label: {
                                HStack {
                                    Text(action.rawValue)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(.gray.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 24)
                } else if selectedAction == .block {
                    VStack(spacing: 16) {
                        Text("They won't be able to see your profile or contact you.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            blockUser()
                        } label: {
                            Text(isSubmitting ? "Blocking..." : "Confirm Block")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.red)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isSubmitting)
                    }
                    .padding(.top, 24)
                } else {
                    VStack(spacing: 16) {
                        ForEach(ReportReason.allCases, id: \.self) { reason in
                            Button {
                                reportReason = reason
                            } label: {
                                HStack {
                                    Text(reason.rawValue)
                                    Spacer()
                                    if reportReason == reason {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                                .padding()
                                .background(reportReason == reason ? Color.accentColor.opacity(0.1) : .gray.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }

                        if reportReason != nil {
                            TextField("Additional details (optional)", text: $reportDetails, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...5)

                            Button {
                                reportUser()
                            } label: {
                                Text(isSubmitting ? "Submitting..." : "Submit Report")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isSubmitting)
                        }
                    }
                    .padding(.top, 12)
                }

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle(selectedAction?.rawValue ?? "Block or Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func blockUser() {
        isSubmitting = true
        Task {
            try? await supabaseService.blockUser(id: userId)
            didComplete = true
            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        }
    }

    private func reportUser() {
        guard let reason = reportReason else { return }
        isSubmitting = true
        Task {
            try? await supabaseService.reportUser(id: userId, reason: reason.rawValue, details: reportDetails)
            didComplete = true
            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        }
    }
}

#Preview {
    BlockReportSheet(userId: "test")
        .environmentObject(SupabaseService())
}
