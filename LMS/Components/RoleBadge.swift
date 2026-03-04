import SwiftUI

struct RoleBadge: View {
    let role: Role

    private var title: String {
        switch role {
        case .owner: "Владелец"
        case .teacher: "Преподаватель"
        case .student: "Студент"
        }
    }

    private var color: Color {
        switch role {
        case .owner: .purple
        case .teacher: .blue
        case .student: .green
        }
    }

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        RoleBadge(role: .owner)
        RoleBadge(role: .teacher)
        RoleBadge(role: .student)
    }
}
