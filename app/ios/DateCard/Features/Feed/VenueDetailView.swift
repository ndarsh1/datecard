import SwiftUI
import Kingfisher

struct VenueDetailView: View {
    let venueId: String
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var venue: Venue?
    @State private var packages: [VenuePackage] = []
    @State private var isLoading = true
    @State private var selectedPackage: VenuePackage?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let venue {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Venue photos
                        if let firstPhoto = venue.photos.first, !firstPhoto.isEmpty {
                            KFImage(URL(string: firstPhoto))
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 250)
                                .overlay {
                                    Image(systemName: "building.2")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text(venue.name)
                                .font(.title2.bold())

                            if let address = venue.address {
                                Label(address, systemImage: "mappin")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let description = venue.description {
                                Text(description)
                                    .font(.body)
                            }

                            // Packages
                            if !packages.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Date Packages")
                                        .font(.title3.bold())

                                    ForEach(packages) { package in
                                        PackageCard(package: package) {
                                            selectedPackage = package
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                ContentUnavailableView("Venue Not Found", systemImage: "building.2")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedPackage) { package in
            BookingView(venue: venue!, package: package)
                .environmentObject(supabaseService)
        }
        .task {
            await loadVenue()
        }
    }

    private func loadVenue() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await supabaseService.fetchVenue(id: venueId)
            venue = result.venue
            packages = result.packages
        } catch {
            print("Failed to load venue: \(error)")
        }
    }
}

private struct PackageCard: View {
    let package: VenuePackage
    let onBook: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(package.name)
                    .font(.headline)
                Spacer()
                Text("$\(package.priceCents / 100)")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }

            if let description = package.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !package.includes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text(package.includes.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                onBook()
            } label: {
                Text("Book This")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        VenueDetailView(venueId: "venue-1")
            .environmentObject(SupabaseService())
    }
}
