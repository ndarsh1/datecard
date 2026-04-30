import Foundation
import Mixpanel

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func initialize(token: String) {
        Mixpanel.initialize(token: token, trackAutomaticEvents: true)
    }

    func identify(userId: String) {
        Mixpanel.mainInstance().identify(distinctId: userId)
    }

    func setUserProperties(name: String, age: Int, city: String?) {
        Mixpanel.mainInstance().people.set(properties: [
            "name": name,
            "age": age,
            "city": city ?? "unknown",
        ])
    }

    // MARK: - Track Events

    func trackOnboardingCompleted() {
        track("onboarding_completed")
    }

    func trackExperienceViewed(experienceId: String, title: String) {
        track("experience_viewed", properties: [
            "experience_id": experienceId,
            "title": title,
        ])
    }

    func trackOptIn(experienceId: String) {
        track("experience_optin", properties: ["experience_id": experienceId])
    }

    func trackPoolViewed(experienceId: String) {
        track("pool_viewed", properties: ["experience_id": experienceId])
    }

    func trackInterestSent(experienceId: String) {
        track("interest_sent", properties: ["experience_id": experienceId])
    }

    func trackMatchCreated(matchId: String, source: String) {
        track("match_created", properties: ["match_id": matchId, "source": source])
    }

    func trackChatFirstMessage(matchId: String) {
        track("chat_first_message", properties: ["match_id": matchId])
    }

    func trackDateConfirmed(matchId: String) {
        track("date_confirmed", properties: ["match_id": matchId])
    }

    func trackDateModeActivated(matchId: String) {
        track("date_mode_activated", properties: ["match_id": matchId])
    }

    func trackExperienceRated(matchId: String, score: Int) {
        track("experience_rated", properties: ["match_id": matchId, "score": score])
    }

    func trackBoardPostCreated(eventType: String) {
        track("board_post_created", properties: ["event_type": eventType])
    }

    func trackBookingCompleted(venueId: String, amount: Int) {
        track("booking_completed", properties: ["venue_id": venueId, "amount_cents": amount])
    }

    // MARK: - Private

    private func track(_ event: String, properties: [String: MixpanelType]? = nil) {
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }
}
