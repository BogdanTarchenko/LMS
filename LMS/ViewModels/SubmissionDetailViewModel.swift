import Foundation

@Observable
@MainActor
final class SubmissionDetailViewModel {
    var submission: Submission
    var gradeText = ""
    var gradeError: String?
    var errorMessage: String?
    var isLoading = false

    private let apiService: APIServiceProtocol

    init(submission: Submission, apiService: APIServiceProtocol = APIService()) {
        self.submission = submission
        self.apiService = apiService
        if let grade = submission.grade {
            self.gradeText = "\(grade)"
        }
    }

    func gradeSubmission() async -> Bool {
        gradeError = nil
        errorMessage = nil

        guard let grade = Int(gradeText) else {
            gradeError = "Введите число от 0 до 100"
            return false
        }

        guard grade >= 0 && grade <= 100 else {
            gradeError = "Оценка должна быть от 0 до 100"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            submission = try await apiService.gradeSubmission(submissionId: submission.id, grade: grade)
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
