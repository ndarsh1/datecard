import Foundation
import SwiftUI

@MainActor
final class OnboardingData: ObservableObject {
    @Published var name: String = ""
    @Published var birthDate: Date = Calendar.current.date(byAdding: .year, value: -21, to: Date()) ?? Date()
    @Published var photoImages: [UIImage] = []
    @Published var photoURLs: [String] = []
    @Published var dateStyleCard: DateStyleCard?
    @Published var selectedCategories: Set<DateCategory> = []
    @Published var dreamDate: String = ""

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var isAgeValid: Bool {
        age >= 18
    }
}
