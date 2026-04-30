import SwiftUI
import Sentry

@main
struct DateCardApp: App {
    @StateObject private var supabaseService = SupabaseService()

    init() {
        // Initialize crash reporting
        CrashReportingService.shared.initialize(dsn: "https://0f713c3d348948a3599ea45060959092@o4511309124206592.ingest.us.sentry.io/4511309125779456")

        // Initialize analytics
        // TODO: Replace with real Mixpanel token
        AnalyticsService.shared.initialize(token: "9edab695d83138a2cfda1068331f71ff")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseService)
                .task {
                    await supabaseService.restoreSession()

                    // Set analytics user after session restore
                    if let user = supabaseService.currentUser {
                        AnalyticsService.shared.identify(userId: user.id)
                        AnalyticsService.shared.setUserProperties(name: user.name, age: user.age, city: nil)
                        CrashReportingService.shared.setUser(id: user.id, name: user.name)
                    }
                }
        }
    }
}
