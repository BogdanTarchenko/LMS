import Foundation

@Observable
@MainActor
final class TeamGradeViewModel {
    var teamGrades: [TeamGrade] = []
    var isLoading = false
    var errorMessage: String?

    // Form state
    var gradeText = ""
    var comment = ""
    var gradeError: String?

    let assignmentId: String
    var apiService: APIServiceProtocol

    init(assignmentId: String, apiService: APIServiceProtocol = APIService.shared) {
        self.assignmentId = assignmentId
        self.apiService = apiService
    }

    func loadTeamGrades() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            teamGrades = try await apiService.getTeamGrades(assignmentId: assignmentId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createTeamGrade(teamId: String) async -> Bool {
        gradeError = nil
        guard let grade = Int(gradeText), grade >= 0, grade <= 100 else {
            gradeError = "Оценка должна быть от 0 до 100"
            return false
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let newGrade = try await apiService.createTeamGrade(
                assignmentId: assignmentId,
                teamId: teamId,
                grade: grade,
                comment: comment.isEmpty ? nil : comment
            )
            teamGrades.append(newGrade)
            gradeText = ""
            comment = ""
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateTeamGrade(teamGradeId: String, grade: Int, comment: String?) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            let updated = try await apiService.updateTeamGrade(
                assignmentId: assignmentId,
                teamGradeId: teamGradeId,
                grade: grade,
                comment: comment
            )
            if let index = teamGrades.firstIndex(where: { $0.id == teamGradeId }) {
                teamGrades[index] = updated
            }
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateAdjustment(teamGradeId: String, studentId: String, adjustment: Int, comment: String?) async -> Bool {
        do {
            let updated = try await apiService.updateAdjustment(
                assignmentId: assignmentId,
                teamGradeId: teamGradeId,
                studentId: studentId,
                adjustment: adjustment,
                comment: comment
            )
            if let gradeIndex = teamGrades.firstIndex(where: { $0.id == teamGradeId }),
               let adjIndex = teamGrades[gradeIndex].individualGrades.firstIndex(where: { $0.studentId == studentId }) {
                teamGrades[gradeIndex].individualGrades[adjIndex] = updated
            }
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

// MARK: - My Team Grade (student)

@Observable
@MainActor
final class MyTeamGradeViewModel {
    var myTeamGrade: MyTeamGrade?
    var isLoading = false
    var errorMessage: String?

    let assignmentId: String
    var apiService: APIServiceProtocol

    init(assignmentId: String, apiService: APIServiceProtocol = APIService.shared) {
        self.assignmentId = assignmentId
        self.apiService = apiService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            myTeamGrade = try await apiService.getMyTeamGrade(assignmentId: assignmentId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
