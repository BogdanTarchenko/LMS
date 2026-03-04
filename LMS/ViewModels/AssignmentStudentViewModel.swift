import Foundation

@Observable
@MainActor
final class AssignmentStudentViewModel {
    let assignment: Assignment
    var answerText = ""
    var fileData: Data?
    var fileName: String?
    var submission: Submission?
    var errorMessage: String?
    var isLoading = false

    var hasSubmitted: Bool { submission != nil }

    private let apiService: APIServiceProtocol

    init(assignment: Assignment, apiService: APIServiceProtocol = APIService()) {
        self.assignment = assignment
        self.apiService = apiService
    }

    func submitAnswer() async {
        errorMessage = nil

        let trimmedText = answerText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty || fileData != nil else {
            errorMessage = "Введите текст ответа или прикрепите файл"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            submission = try await apiService.submitAnswer(
                assignmentId: assignment.id,
                text: trimmedText.isEmpty ? nil : trimmedText,
                fileData: fileData,
                fileName: fileName
            )
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
