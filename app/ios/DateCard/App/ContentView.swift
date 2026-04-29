import SwiftUI

struct ContentView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var selectedTab: Tab = .feed

    enum Tab: String {
        case feed, board, matches, dateMode, profile
    }

    var body: some View {
        Group {
            if supabaseService.isAuthenticated {
                if supabaseService.currentUser?.onboardingComplete == true {
                    TabView(selection: $selectedTab) {
                        FeedView()
                            .tabItem {
                                Label("Explore", systemImage: "sparkles")
                            }
                            .tag(Tab.feed)

                        BoardView()
                            .tabItem {
                                Label("+1 Board", systemImage: "person.2")
                            }
                            .tag(Tab.board)

                        MatchListView()
                            .tabItem {
                                Label("Matches", systemImage: "heart.fill")
                            }
                            .tag(Tab.matches)

                        DateModeView()
                            .tabItem {
                                Label("Date Mode", systemImage: "sparkle")
                            }
                            .tag(Tab.dateMode)

                        ProfileView()
                            .tabItem {
                                Label("Profile", systemImage: "person.crop.circle")
                            }
                            .tag(Tab.profile)
                    }
                } else {
                    NavigationStack {
                        NameAgeView()
                    }
                    .environmentObject(OnboardingData())
                }
            } else {
                WelcomeView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseService())
}
