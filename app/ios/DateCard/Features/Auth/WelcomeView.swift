import SwiftUI

struct WelcomeView: View {
    @State private var showPhoneEntry = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text("DateCard")
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text("Dates worth going on.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 16) {
                    Button {
                        showPhoneEntry = true
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
            .navigationDestination(isPresented: $showPhoneEntry) {
                PhoneEntryView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
