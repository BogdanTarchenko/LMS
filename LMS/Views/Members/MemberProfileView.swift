import SwiftUI

struct MemberProfileView: View {
    let member: Member

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AvatarView(
                    url: member.avatarURL,
                    firstName: member.firstName,
                    lastName: member.lastName,
                    size: 80
                )

                VStack(spacing: 4) {
                    Text("\(member.firstName) \(member.lastName)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(member.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    RoleBadge(role: member.role)
                        .padding(.top, 4)
                }
            }
            .padding(.top, 32)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MemberProfileView(member: MockData.sampleMembers[0])
    }
}
