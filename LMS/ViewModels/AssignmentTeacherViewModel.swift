import Foundation

enum SubmissionFilter: String, CaseIterable {
    case all = "Все"
    case notGraded = "Не оценено"
    case graded = "Оценено"
}

@Observable
@MainActor
final class AssignmentTeacherViewModel {
    let assignment: Assignment
    var submissions: [Submission] = []
    var filter: SubmissionFilter = .all
    var errorMessage: String?
    var isLoading = false

    var submittedCount: Int { submissions.count }

    var filteredSubmissions: [Submission] {
        switch filter {
        case .all: return submissions
        case .graded: return submissions.filter { $0.grade != nil }
        case .notGraded: return submissions.filter { $0.grade == nil }
        }
    }

    private let apiService: APIServiceProtocol

    init(assignment: Assignment, apiService: APIServiceProtocol = APIService.shared) {
        self.assignment = assignment
        self.apiService = apiService
    }

    func loadSubmissions() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            submissions = try await apiService.getSubmissions(assignmentId: assignment.id)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
