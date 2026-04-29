import SwiftUI

struct DreamDateView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @EnvironmentObject var onboardingData: OnboardingData
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let characterLimit = 500

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Describe your dream date")
                    .font(.title2.bold())

                Text("This helps us find people with similar vibes.")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .trailing, spacing: 4) {
                TextEditor(text: $onboardingData.dreamDate)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: onboardingData.dreamDate) { _, newValue in
                        if newValue.count > characterLimit {
                            onboardingData.dreamDate = String(newValue.prefix(characterLimit))
                        }
                    }

                Text("\(onboardingData.dreamDate.count)/\(characterLimit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Spacer()

            Button {
                completeOnboarding()
            } label: {
                if isSubmitting {
                    HStack {
                        ProgressView()
                        Text("Setting up your profile...")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    Text("Start Exploring")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(!onboardingData.dreamDate.isEmpty ? Color.accentColor : .gray.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(onboardingData.dreamDate.isEmpty || isSubmitting)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Dream Date")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func completeOnboarding() {
        isSubmitting = true
        Task {
            do {
                try await supabaseService.createProfile(
                    name: onboardingData.name,
                    age: onboardingData.age,
                    photos: onboardingData.photoURLs,
                    dateStyleCard: onboardingData.dateStyleCard ?? DateStyleCard(adventurous: 50, planner: 50, talker: 50, foodie: 50),
                    favoriteDateTypes: Array(onboardingData.selectedCategories),
                    dreamDate: onboardingData.dreamDate
                )
            } catch {
                errorMessage = "Failed to save your profile. Please try again."
                isSubmitting = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        DreamDateView()
            .environmentObject(SupabaseService())
            .environmentObject(OnboardingData())
    }
}
