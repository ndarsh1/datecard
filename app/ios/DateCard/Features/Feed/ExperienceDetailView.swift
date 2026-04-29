import SwiftUI
import Kingfisher

struct ExperienceDetailView: View {
    let experience: DateExperience
    @EnvironmentObject var supabaseService: SupabaseService
    @StateObject private var viewModel = ExperienceDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero image
                KFImage(URL(string: experience.heroImage))
                    .placeholder {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Image(systemName: "sparkles")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    // Title & meta
                    VStack(alignment: .leading, spacing: 8) {
                        Text(experience.title)
                            .font(.title2.bold())

                        HStack(spacing: 12) {
                            Label(experience.neighborhood, systemImage: "mappin")
                            Label("\(experience.durationMinutes) min", systemImage: "clock")
                            Text(experience.priceLabel)
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    // Categories
                    HStack(spacing: 8) {
                        ForEach(experience.categories, id: \.self) { category in
                            Text("\(category.emoji) \(category.displayName)")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }

                    // Description
                    Text(experience.description)
                        .font(.body)

                    // Opt-in count + pool link
                    if viewModel.optInCount > 0 || experience.optInCount > 0 {
                        if viewModel.hasOptedIn {
                            NavigationLink {
                                OptInPoolView(experienceId: experience.id, experienceTitle: experience.title)
                            } label: {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("\(max(viewModel.optInCount, experience.optInCount)) people are in")
                                    Spacer()
                                    Text("See who")
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.accentColor)
                                .padding()
                                .background(Color.accentColor.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        } else {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("\(max(viewModel.optInCount, experience.optInCount)) people are in")
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            Button {
                Task { await viewModel.optIn(experienceId: experience.id) }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text(viewModel.hasOptedIn ? "You're In!" : "I'm In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(viewModel.hasOptedIn ? .green : Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(viewModel.hasOptedIn || viewModel.isLoading)
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(supabaseService: supabaseService, experienceId: experience.id)
        }
    }
}

#Preview {
    NavigationStack {
        ExperienceDetailView(experience: .samples[0])
            .environmentObject(SupabaseService())
    }
}
