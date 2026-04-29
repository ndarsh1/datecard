import SwiftUI

struct UserChip: View {
    let name: String
    let imageURL: String?

    var body: some View {
        HStack(spacing: 8) {
            if let imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(.gray.opacity(0.2))
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
            }

            Text(name)
                .font(.subheadline.weight(.medium))
        }
        .padding(.trailing, 12)
        .padding(4)
        .background(.gray.opacity(0.08))
        .clipShape(Capsule())
    }
}

#Preview {
    UserChip(name: "Alex", imageURL: nil)
}
