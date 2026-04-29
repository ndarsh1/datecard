import SwiftUI

struct NameAgeView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    @State private var showPhotos = false

    private let minDate = Calendar.current.date(byAdding: .year, value: -80, to: Date()) ?? Date()
    private let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()

    var body: some View {
        VStack(spacing: 24) {
            Text("Let's get to know you")
                .font(.title2.bold())

            VStack(spacing: 16) {
                TextField("First name", text: $onboardingData.name)
                    .textContentType(.givenName)
                    .font(.title3)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Birthday")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    DatePicker(
                        "Birthday",
                        selection: $onboardingData.birthDate,
                        in: minDate...maxDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()

                    if !onboardingData.isAgeValid {
                        Text("You must be at least 18 to use DateCard.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                showPhotos = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.accentColor : .gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!isValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("About You")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPhotos) {
            PhotoUploadView()
        }
    }

    private var isValid: Bool {
        !onboardingData.name.trimmingCharacters(in: .whitespaces).isEmpty && onboardingData.isAgeValid
    }
}

#Preview {
    NavigationStack {
        NameAgeView()
            .environmentObject(OnboardingData())
    }
}
