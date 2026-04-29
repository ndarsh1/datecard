import SwiftUI
import Kingfisher

struct ProfileView: View {
    @EnvironmentObject var supabaseService: SupabaseService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile photo
                    if let firstPhoto = supabaseService.currentUser?.photos.first, !firstPhoto.isEmpty {
                        KFImage(URL(string: firstPhoto))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                            }
                    }

                    // Name and verification
                    VStack(spacing: 4) {
                        Text(supabaseService.currentUser?.name ?? "")
                            .font(.title2.bold())

                        HStack(spacing: 8) {
                            if supabaseService.currentUser?.verifiedPhoto == true {
                                Label("Photo Verified", systemImage: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            if supabaseService.currentUser?.verifiedId == true {
                                Label("ID Verified", systemImage: "checkmark.shield.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }

                    // Date Style Card
                    if let card = supabaseService.currentUser?.dateStyleCard {
                        DateStyleChart(card: card)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }

                    // Favorite date types
                    if let types = supabaseService.currentUser?.favoriteDateTypes, !types.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Favorite Date Types")
                                .font(.headline)
                            FlowLayout(spacing: 8) {
                                ForEach(types, id: \.self) { category in
                                    Text("\(category.emoji) \(category.displayName)")
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    // Dream Date
                    if let dreamDate = supabaseService.currentUser?.dreamDate, !dreamDate.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dream Date")
                                .font(.headline)
                            Text(dreamDate)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    // Sign out
                    Button("Sign Out", role: .destructive) {
                        Task { await supabaseService.signOut() }
                    }
                    .padding(.top, 24)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(SupabaseService())
}
