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
        case .student: .teal
        }
    }

    private var icon: String {
        switch role {
        case .owner: "crown"
        case .teacher: "graduationcap"
        case .student: "person"
        }
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(1)
            .frame(minWidth: 120)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct RoleIcon: View {
    let role: Role

    private var color: Color {
        switch role {
        case .owner: .purple
        case .teacher: .blue
        case .student: .teal
        }
    }

    private var icon: String {
        switch role {
        case .owner: "crown.fill"
        case .teacher: "graduationcap.fill"
        case .student: "person.fill"
        }
    }

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: 8) {
        RoleBadge(role: .owner)
        RoleBadge(role: .teacher)
        RoleBadge(role: .student)
        HStack(spacing: 12) {
            RoleIcon(role: .owner)
            RoleIcon(role: .teacher)
            RoleIcon(role: .student)
        }
    }
    .padding()
}
