import SwiftUI

struct FeedView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var locationService = LocationService()
    @State private var selectedCategory: DateCategory?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.experiences.isEmpty {
                    ProgressView("Loading experiences...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.experiences.isEmpty {
                    ContentUnavailableView(
                        "No Experiences Yet",
                        systemImage: "sparkles",
                        description: Text("Check back soon for curated date experiences in your area.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Category filter chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                        selectedCategory = nil
                                    }
                                    ForEach(DateCategory.allCases, id: \.self) { category in
                                        FilterChip(
                                            title: category.displayName,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Experience cards
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.filteredExperiences(for: selectedCategory)) { experience in
                                    NavigationLink(value: experience) {
                                        ExperienceCard(experience: experience)
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        // Infinite scroll trigger
                                        if experience.id == viewModel.experiences.last?.id {
                                            Task { await viewModel.loadMore(category: selectedCategory) }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: DateExperience.self) { experience in
                ExperienceDetailView(experience: experience)
            }
            .refreshable {
                await viewModel.loadExperiences(category: selectedCategory)
            }
            .task {
                viewModel.configure(supabaseService: supabaseService)
                locationService.requestPermission()
                await viewModel.loadExperiences()
            }
            .onChange(of: selectedCategory) { _, newCategory in
                Task { await viewModel.loadExperiences(category: newCategory) }
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : .gray.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(SupabaseService())
}
