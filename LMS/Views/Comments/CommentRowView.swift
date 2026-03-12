import SwiftUI

struct CommentRowView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(
                url: comment.authorAvatarUrl,
                firstName: String(comment.authorName.prefix(1)),
                lastName: String(comment.authorName.split(separator: " ").last?.prefix(1) ?? ""),
                size: 34
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Text(comment.text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CommentRowView(comment: MockData.sampleComments[0])
        CommentRowView(comment: MockData.sampleComments[1])
    }
    .padding()
}
