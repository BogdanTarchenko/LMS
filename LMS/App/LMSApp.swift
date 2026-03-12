import SwiftUI
import UIKit

@main
struct LMSApp: App {
    @State private var authManager: AuthManager
    @State private var isCheckingAuth = true

    init() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("UI_TESTING") {
            let mock = MockAPIService()
            mock.stubbedClasses = MockData.sampleClasses
            mock.stubbedAssignments = MockData.sampleAssignments
            mock.stubbedMembers = MockData.sampleMembers
            mock.stubbedProfile = MockData.sampleUser
            let manager = AuthManager(apiService: mock, keychainHelper: MockKeychainHelper())
            if args.contains("MOCK_AUTHENTICATED") {
                manager.isAuthenticated = true
                manager.currentUser = MockData.sampleUser
            }
            _authManager = State(initialValue: manager)
        } else {
            _authManager = State(initialValue: AuthManager())
        }
    }

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
            .environment(\.apiService, authManager.apiService)
            .task {
                if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
                    isCheckingAuth = false
                } else {
                    await authManager.checkAuth()
                    isCheckingAuth = false
                }
            }
        }
    }
}
