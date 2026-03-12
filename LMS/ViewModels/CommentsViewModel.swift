import Foundation

@Observable
@MainActor
final class CommentsViewModel {
    var comments: [Comment] = []
    var newCommentText = ""
    var errorMessage: String?
    var isLoading = false
    var isSending = false

    private let assignmentId: String
    var apiService: APIServiceProtocol

    init(assignmentId: String, apiService: APIServiceProtocol = APIService.shared) {
        self.assignmentId = assignmentId
        self.apiService = apiService
    }

    func loadComments() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            comments = try await apiService.getComments(assignmentId: assignmentId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addComment() async {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        do {
            let comment = try await apiService.addComment(assignmentId: assignmentId, text: trimmed)
            comments.append(comment)
            newCommentText = ""
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
