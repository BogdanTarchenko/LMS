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
    var isEditing = false

    var hasSubmitted: Bool { submission != nil }

    var isDeadlinePassed: Bool {
        guard let deadline = assignment.deadline else { return false }
        return Date() > deadline
    }

    var canSubmit: Bool {
        !isDeadlinePassed
    }

    var canCancel: Bool {
        guard let submission else { return false }
        return submission.grade == nil && !isDeadlinePassed
    }

    private let apiService: APIServiceProtocol

    init(assignment: Assignment, apiService: APIServiceProtocol = APIService.shared) {
        self.assignment = assignment
        self.apiService = apiService
    }

    func loadMySubmission() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            submission = try await apiService.getMySubmission(assignmentId: assignment.id)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
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
            isEditing = false
            answerText = ""
            fileData = nil
            fileName = nil
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelSubmission() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await apiService.cancelSubmission(assignmentId: assignment.id)
            submission = nil
            isEditing = false
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startEditing() {
        answerText = submission?.text ?? ""
        fileData = nil
        fileName = nil
        isEditing = true
    }
}
