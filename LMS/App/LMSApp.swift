import SwiftUI

@main
struct LMSApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    Text("LoginView Placeholder")
                }
            }
            .environment(authManager)
        }
    }
}
