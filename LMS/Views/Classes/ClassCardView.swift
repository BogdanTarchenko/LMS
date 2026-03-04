import SwiftUI

struct ClassCardView: View {
    let classroom: ClassRoom

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(classroom.name)
                    .font(.headline)
                Spacer()
                RoleBadge(role: classroom.myRole)
            }

            HStack {
                Image(systemName: "person.2")
                    .foregroundStyle(.secondary)
                Text("\(classroom.memberCount)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    ClassCardView(classroom: MockData.sampleClasses[0])
        .padding()
        .background(Color(.systemGroupedBackground))
}
