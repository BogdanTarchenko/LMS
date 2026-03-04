import SwiftUI

struct CommentRowView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(
                url: comment.authorAvatarURL,
                firstName: String(comment.authorName.prefix(1)),
                lastName: String(comment.authorName.split(separator: " ").last?.prefix(1) ?? ""),
                size: 32
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName)
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(comment.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(comment.text)
                    .font(.body)
            }
        }
    }
}

#Preview {
    VStack {
        CommentRowView(comment: MockData.sampleComments[0])
        CommentRowView(comment: MockData.sampleComments[1])
    }
    .padding()
}
