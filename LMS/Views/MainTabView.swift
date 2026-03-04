import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                Text("ClassListView Placeholder")
                    .navigationTitle("Мои классы")
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
