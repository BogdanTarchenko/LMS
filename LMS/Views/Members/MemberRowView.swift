import SwiftUI

struct MemberRowView: View {
    let member: Member

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                url: member.avatarUrl,
                firstName: member.firstName,
                lastName: member.lastName,
                size: 44
            )

            VStack(alignment: .leading, spacing: 1) {
                Text(member.lastName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(member.firstName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            RoleIcon(role: member.role)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        MemberRowView(member: MockData.sampleMembers[0])
        MemberRowView(member: MockData.sampleMembers[1])
        MemberRowView(member: MockData.sampleMembers[2])
    }
}
