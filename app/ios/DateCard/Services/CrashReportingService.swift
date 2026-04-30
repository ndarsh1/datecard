import Foundation
import Sentry

final class CrashReportingService {
    static let shared = CrashReportingService()

    private init() {}

    func initialize(dsn: String) {
        SentrySDK.start { options in
            options.dsn = dsn
            options.tracesSampleRate = 0.2
            options.enableAutoPerformanceTracing = true
            options.attachScreenshot = true
            options.environment = Configuration.isConfigured ? "production" : "development"
        }
    }

    func setUser(id: String, name: String?) {
        let user = Sentry.User()
        user.userId = id
        user.username = name
        SentrySDK.setUser(user)
    }

    func clearUser() {
        SentrySDK.setUser(nil)
    }

    func addBreadcrumb(category: String, message: String) {
        let crumb = Breadcrumb()
        crumb.category = category
        crumb.message = message
        crumb.level = .info
        SentrySDK.addBreadcrumb(crumb)
    }

    func captureError(_ error: Error) {
        SentrySDK.capture(error: error)
    }
}
