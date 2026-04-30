import SwiftUI

struct BookingView: View {
    let venue: Venue
    let package: VenuePackage
    @EnvironmentObject var supabaseService: SupabaseService
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var bookingComplete = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if bookingComplete {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                        Text("Booking Confirmed!")
                            .font(.title2.bold())
                        Text("Check your matches for details.")
                            .foregroundStyle(.secondary)
                        Button("Done") { dismiss() }
                            .font(.headline)
                            .padding()
                    }
                    .padding(.top, 40)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        // Venue info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(venue.name)
                                .font(.headline)
                            if let address = venue.address {
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()

                        // Package details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(package.name)
                                .font(.title3.bold())

                            if let description = package.description {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if !package.includes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Includes:")
                                        .font(.subheadline.weight(.medium))
                                    ForEach(package.includes, id: \.self) { item in
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .foregroundStyle(.green)
                                            Text(item)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                            }
                        }

                        Divider()

                        // Price
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("$\(package.priceCents / 100)")
                                .font(.title2.bold())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding()

                    Spacer()

                    // Book button
                    Button {
                        processBooking()
                    } label: {
                        if isProcessing {
                            HStack {
                                ProgressView()
                                Text("Processing...")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            Text("Confirm Booking")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(isProcessing)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Book Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !bookingComplete {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
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

    private func processBooking() {
        isProcessing = true
        Task {
            do {
                // TODO: Integrate Stripe PaymentSheet here
                // For now, create booking directly
                try await supabaseService.createBooking(
                    venueId: venue.id,
                    packageId: package.id,
                    amountCents: package.priceCents
                )
                bookingComplete = true
            } catch {
                errorMessage = "Booking failed. Please try again."
            }
            isProcessing = false
        }
    }
}

#Preview {
    BookingView(
        venue: Venue(id: "v1", name: "Test Venue", address: "123 Main St", photos: [], priceRange: 2),
        package: VenuePackage(id: "p1", venueId: "v1", name: "Dinner for Two", description: "3-course meal", priceCents: 15000, includes: ["Appetizer", "Entree", "Dessert"])
    )
    .environmentObject(SupabaseService())
}
