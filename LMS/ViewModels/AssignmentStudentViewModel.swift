import Foundation

@Observable
@MainActor
final class AssignmentStudentViewModel {
    let assignment: Assignment
    var answerText = ""
    var attachedFiles: [FileData] = []
    var submission: Submission?
    var myTeam: Team?
    var errorMessage: String?
    var isLoading = false
    var isEditing = false

    var hasSubmitted: Bool { submission != nil }

    var isTeamLeader: Bool { myTeam?.leader != nil }

    var isDeadlinePassed: Bool {
        guard let deadline = assignment.deadline else { return false }
        return Date() > deadline
    }

    var canSubmit: Bool { !isDeadlinePassed }

    var canCancel: Bool {
        guard let submission else { return false }
        return submission.grade == nil && !isDeadlinePassed
    }

    var apiService: APIServiceProtocol

    init(assignment: Assignment, apiService: APIServiceProtocol = APIService.shared) {
        self.assignment = assignment
        self.apiService = apiService
    }

    func addFiles(_ files: [FileData]) {
        attachedFiles.append(contentsOf: files)
    }

    func removeFile(at index: Int) {
        guard index < attachedFiles.count else { return }
        attachedFiles.remove(at: index)
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

    func loadTeamInfo(classId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let teams = try await apiService.getMyTeams(classId: classId)
            myTeam = teams.first(where: { $0.assignmentId == assignment.id })
                ?? teams.first(where: { $0.assignmentId == nil })
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        guard isTeamLeader else { return }

        do {
            submission = try await apiService.getMySubmission(assignmentId: assignment.id)
        } catch {
        }
    }

    func submitAnswer() async {
        errorMessage = nil

        let trimmedText = answerText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty || !attachedFiles.isEmpty else {
            errorMessage = "Введите текст ответа или прикрепите файл"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            submission = try await apiService.submitAnswer(
                assignmentId: assignment.id,
                text: trimmedText.isEmpty ? nil : trimmedText,
                files: attachedFiles
            )
            isEditing = false
            answerText = ""
            attachedFiles = []
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
        attachedFiles = []
        isEditing = true
    }
}
