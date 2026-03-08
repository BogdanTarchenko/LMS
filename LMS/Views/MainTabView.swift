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
                Label("Классы", systemImage: "book.closed")
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
}
