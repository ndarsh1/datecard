import SwiftUI

struct CategoryPickerView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    @State private var showDreamDate = false

    private let maxSelections = 5

    var body: some View {
        VStack(spacing: 24) {
            Text("Pick your top \(maxSelections) date types")
                .font(.title2.bold())

            Text("\(onboardingData.selectedCategories.count) of \(maxSelections) selected")
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(DateCategory.allCases, id: \.self) { category in
                        let isSelected = onboardingData.selectedCategories.contains(category)
                        Button {
                            if isSelected {
                                onboardingData.selectedCategories.remove(category)
                            } else if onboardingData.selectedCategories.count < maxSelections {
                                onboardingData.selectedCategories.insert(category)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Text(category.emoji)
                                    .font(.title)
                                Text(category.displayName)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isSelected ? Color.accentColor.opacity(0.15) : .gray.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }

            Button {
                showDreamDate = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(onboardingData.selectedCategories.count == maxSelections ? Color.accentColor : .gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(onboardingData.selectedCategories.count != maxSelections)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDreamDate) {
            DreamDateView()
        }
    }
}

#Preview {
    NavigationStack {
        CategoryPickerView()
            .environmentObject(OnboardingData())
    }
}
