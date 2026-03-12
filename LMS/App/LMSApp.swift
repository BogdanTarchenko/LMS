import SwiftUI

@main
struct LMSApp: App {
    @State private var authManager = AuthManager()
    @State private var isCheckingAuth = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingAuth {
                    ProgressView()
                } else if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environment(authManager)
            .task {
                await authManager.checkAuth()
                isCheckingAuth = false
            }
        }
    }
}
