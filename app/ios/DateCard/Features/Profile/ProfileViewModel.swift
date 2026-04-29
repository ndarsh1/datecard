import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userName = ""
    @Published var isPhotoVerified = false
    @Published var isIdVerified = false
    @Published var dateStyleCard: DateStyleCard?
    @Published var favoriteDateTypes: [DateCategory] = []
    @Published var dreamDate: String?

    func loadFromUser(_ user: User?) {
        guard let user else { return }
        userName = user.name
        isPhotoVerified = user.verifiedPhoto
        isIdVerified = user.verifiedId
        dateStyleCard = user.dateStyleCard
        favoriteDateTypes = user.favoriteDateTypes
        dreamDate = user.dreamDate
    }
}
