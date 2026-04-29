import SwiftUI

struct PhoneEntryView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var codeSent = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Text(codeSent ? "Enter the code" : "What's your number?")
                .font(.title2.bold())

            if !codeSent {
                TextField("(555) 123-4567", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .font(.title3)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    sendCode()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Send Code")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(phoneNumber.count >= 10 ? Color.accentColor : .gray.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(phoneNumber.count < 10 || isLoading)
            } else {
                TextField("000000", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    verifyCode()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Verify")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(verificationCode.count == 6 ? Color.accentColor : .gray.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(verificationCode.count != 6 || isLoading)

                Button("Resend code") {
                    sendCode()
                }
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
                .disabled(isLoading)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Sign In")
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

    private func sendCode() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let formattedPhone = formatPhone(phoneNumber)
                try await supabaseService.signInWithPhone(phone: formattedPhone)
                codeSent = true
            } catch {
                errorMessage = "Failed to send code. Please check your number and try again."
            }
            isLoading = false
        }
    }

    private func verifyCode() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let formattedPhone = formatPhone(phoneNumber)
                try await supabaseService.verifyOTP(phone: formattedPhone, code: verificationCode)
                await supabaseService.loadCurrentUser()
            } catch {
                errorMessage = "Invalid code. Please try again."
            }
            isLoading = false
        }
    }

    private func formatPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        if digits.hasPrefix("1") {
            return "+\(digits)"
        }
        return "+1\(digits)"
    }
}

#Preview {
    NavigationStack {
        PhoneEntryView()
            .environmentObject(SupabaseService())
    }
}
