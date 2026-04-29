import SwiftUI
import Kingfisher

struct ExperienceCard: View {
    let experience: DateExperience

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image
            KFImage(URL(string: experience.heroImage))
                .placeholder {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(experience.title)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(experience.neighborhood, systemImage: "mappin")
                    Label("\(experience.durationMinutes) min", systemImage: "clock")
                    Spacer()
                    Text(experience.priceLabel)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    ForEach(experience.categories.prefix(3), id: \.self) { category in
                        Text(category.emoji)
                    }

                    if experience.optInCount > 0 {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                            Text("\(experience.optInCount)")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .padding(12)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

#Preview {
    ExperienceCard(experience: .samples[0])
        .padding()
}
