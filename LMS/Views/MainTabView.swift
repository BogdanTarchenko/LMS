import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ClassListView()
                    .navigationDestination(for: ClassRoom.self) { classroom in
                        ClassDetailView(classroom: classroom)
                    }
            }
            .tabItem {
                Label("Классы", systemImage: "book.closed")
            }

            NavigationStack {
                Text("ProfileView Placeholder")
                    .navigationTitle("Профиль")
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
