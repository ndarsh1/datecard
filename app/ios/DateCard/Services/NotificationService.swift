import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published var isAuthorized = false

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            print("Notification authorization failed: \(error)")
        }
    }

    func registerForRemoteNotifications() {
        // TODO: Register with APNs
        // UIApplication.shared.registerForRemoteNotifications()
    }

    func scheduleLocalNotification(title: String, body: String, delay: TimeInterval, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removePendingNotification(identifier: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
