import SwiftUI

struct CommentsSection: View {
    @State private var viewModel: CommentsViewModel

    init(assignmentId: String) {
        _viewModel = State(initialValue: CommentsViewModel(assignmentId: assignmentId))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Комментарии")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.comments.isEmpty && !viewModel.isLoading {
                Text("Пока нет комментариев")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            ForEach(viewModel.comments) { comment in
                CommentRowView(comment: comment)
                    .padding(.horizontal)
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Комментарий...", text: Bindable(viewModel).newCommentText)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("comment_field")

                Button {
                    Task { await viewModel.addComment() }
                } label: {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSending)
                .accessibilityIdentifier("send_comment_button")
            }
            .padding(.horizontal)
        }
        .task {
            await viewModel.loadComments()
        }
    }
}
