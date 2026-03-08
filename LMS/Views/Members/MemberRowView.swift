import SwiftUI

struct MemberRowView: View {
    let member: Member

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                url: nil,
                firstName: member.firstName,
                lastName: member.lastName,
                size: 36
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("\(member.firstName) \(member.lastName)")
                    .font(.body)
                Text(member.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            RoleBadge(role: member.role)
        }
    }
}

#Preview {
    List {
        MemberRowView(member: MockData.sampleMembers[0])
        MemberRowView(member: MockData.sampleMembers[1])
        MemberRowView(member: MockData.sampleMembers[2])
    }
}
