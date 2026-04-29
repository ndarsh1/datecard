import Foundation

enum Configuration {
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              let url = URL(string: urlString),
              url.host != nil,
              !urlString.contains("YOUR_PROJECT") else {
            // Return a dummy URL for development/testing when not configured
            return URL(string: "https://placeholder.supabase.co")!
        }
        return url
    }

    static var supabaseAnonKey: String {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !key.isEmpty,
              key != "YOUR_ANON_KEY" else {
            return "placeholder-key"
        }
        return key
    }

    static var backendAPIURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BACKEND_API_URL"] as? String,
              let url = URL(string: urlString),
              url.host != nil else {
            return URL(string: "http://localhost:3001")!
        }
        return url
    }

    static var isConfigured: Bool {
        guard let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String else {
            return false
        }
        return !urlString.contains("YOUR_PROJECT") && key != "YOUR_ANON_KEY"
    }
}
