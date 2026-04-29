import SwiftUI

@main
struct DateCardApp: App {
    @StateObject private var supabaseService = SupabaseService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseService)
                .task {
                    await supabaseService.restoreSession()
                }
        }
    }
}
