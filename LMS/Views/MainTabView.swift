import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ClassListView()
                    .navigationDestination(for: ClassRoom.self) { classroom in
                        ClassDetailView(classroom: classroom)
                    }
                    .navigationDestination(for: Submission.self) { submission in
                        SubmissionDetailView(submission: submission)
                    }
            }
            .tabItem {
                Label("Классы", systemImage: "books.vertical")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.circle")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthManager(apiService: MockAPIService(), keychainHelper: MockKeychainHelper()))
}
