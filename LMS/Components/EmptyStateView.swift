import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(description)
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "book.closed",
        title: "Нет классов",
        description: "Создайте класс или присоединитесь по коду"
    )
}
