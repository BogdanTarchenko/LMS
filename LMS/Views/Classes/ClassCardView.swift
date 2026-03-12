import SwiftUI

struct ClassCardView: View {
    let classroom: ClassRoom

    private var roleColor: Color {
        switch classroom.myRole {
        case .owner: .purple
        case .teacher: .blue
        case .student: .teal
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [roleColor, roleColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "book.closed.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(classroom.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(classroom.memberCount) участников")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            RoleIcon(role: classroom.myRole)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

#Preview {
    VStack(spacing: 12) {
        ClassCardView(classroom: MockData.sampleClasses[0])
        ClassCardView(classroom: MockData.sampleClasses[1])
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
