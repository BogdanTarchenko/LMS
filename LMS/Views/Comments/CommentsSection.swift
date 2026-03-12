import SwiftUI

struct CommentsSection: View {
    @State private var viewModel: CommentsViewModel

    init(assignmentId: String) {
        _viewModel = State(initialValue: CommentsViewModel(assignmentId: assignmentId))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Комментарии", systemImage: "bubble.left.and.bubble.right")
                .font(.headline)

            if viewModel.comments.isEmpty && !viewModel.isLoading {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text("Пока нет комментариев")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            }

            VStack(spacing: 12) {
                ForEach(viewModel.comments) { comment in
                    CommentRowView(comment: comment)
                }
            }

            HStack(spacing: 10) {
                TextField("Написать комментарий...", text: Bindable(viewModel).newCommentText, axis: .vertical)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .lineLimit(1...5)
                    .accessibilityIdentifier("comment_field")

                Button {
                    Task { await viewModel.addComment() }
                } label: {
                    Group {
                        if viewModel.isSending {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16))
                        }
                    }
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                }
                .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSending)
                .opacity(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .accessibilityIdentifier("send_comment_button")
            }
        }
        .task {
            await viewModel.loadComments()
        }
    }
}
