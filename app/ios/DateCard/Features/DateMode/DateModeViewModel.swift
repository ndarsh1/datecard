import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
final class DateModeViewModel: ObservableObject {
    @Published var activeMatch: Match?
    @Published var currentPrompt: LifelinePrompt?
    @Published var isDateActive = false
    @Published var startTime: Date?

    private var timer: AnyCancellable?

    var elapsedTimeFormatted: String {
        guard let startTime else { return "00:00" }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startDate(match: Match) {
        activeMatch = match
        isDateActive = true
        startTime = Date()

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    func requestPrompt(tier: LifelinePrompt.Tier) {
        // TODO: Send via Stream Chat custom event for real-time sync
        let prompt = LifelinePrompt.random(tier: tier)
        withAnimation(.spring(duration: 0.4)) {
            currentPrompt = prompt
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func endDate() {
        timer?.cancel()
        activeMatch = nil
        isDateActive = false
        currentPrompt = nil
        startTime = nil
    }

    func handleAppBackground() {
        guard isDateActive, let matchId = activeMatch?.id else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your date is waiting"
        content.body = "Tap to get back to your Lifeline prompts"
        content.userInfo = ["matchId": matchId, "screen": "date-mode"]
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "datemode-background-\(matchId)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
