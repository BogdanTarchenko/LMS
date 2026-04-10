import Foundation
import SwiftUI

protocol APIServiceProtocol {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(request: RegisterRequest) async throws -> AuthResponse
    func getMyClasses() async throws -> [ClassRoom]
    func createClass(name: String) async throws -> ClassRoom
    func joinClass(code: String) async throws -> ClassRoom
    func deleteClass(id: String) async throws
    func updateClass(id: String, name: String) async throws -> ClassRoom
    func regenerateCode(id: String) async throws -> ClassRoom
    func getMembers(classId: String) async throws -> [Member]
    func assignRole(classId: String, userId: String, role: Role) async throws
    func removeMember(classId: String, userId: String) async throws
    func getAssignments(classId: String) async throws -> [Assignment]
    func createAssignment(classId: String, title: String, description: String, deadline: Date?, isTeamBased: Bool, files: [FileData]) async throws -> Assignment
    func submitAnswer(assignmentId: String, text: String?, files: [FileData]) async throws -> Submission
    func getMySubmission(assignmentId: String) async throws -> Submission?
    func cancelSubmission(assignmentId: String) async throws
    func getSubmissions(assignmentId: String) async throws -> [Submission]
    func gradeSubmission(submissionId: String, grade: Int) async throws -> Submission
    func getComments(assignmentId: String) async throws -> [Comment]
    func addComment(assignmentId: String, text: String) async throws -> Comment
    func getProfile() async throws -> User
    func updateProfile(request: UpdateProfileRequest) async throws -> User
    func uploadAvatar(imageData: Data, fileName: String) async throws -> User
    func getClassStats(classId: String) async throws -> ClassStats

    // MARK: - Teams
    func getTeams(classId: String) async throws -> [TeamListItem]
    func getTeam(classId: String, teamId: String) async throws -> Team
    func createTeam(classId: String, name: String, assignmentId: String?, memberUserIds: [String], leaderUserId: String?) async throws -> Team
    func updateTeam(classId: String, teamId: String, name: String?, leaderUserId: String?) async throws -> Team
    func deleteTeam(classId: String, teamId: String) async throws
    func shuffleTeams(classId: String, teamCount: Int, assignmentId: String?, strategy: String) async throws -> ShuffleResponse
    func addTeamMember(classId: String, teamId: String, userId: String, isLeader: Bool) async throws -> Team
    func removeTeamMember(classId: String, teamId: String, userId: String) async throws
    func getMyTeams(classId: String) async throws -> [Team]

    // MARK: - Team Grades
    func createTeamGrade(assignmentId: String, teamId: String, grade: Int, comment: String?) async throws -> TeamGrade
    func getTeamGrades(assignmentId: String) async throws -> [TeamGrade]
    func updateTeamGrade(assignmentId: String, teamGradeId: String, grade: Int, comment: String?) async throws -> TeamGrade
    func getAdjustments(assignmentId: String, teamGradeId: String) async throws -> [IndividualAdjustment]
    func updateAdjustment(assignmentId: String, teamGradeId: String, studentId: String, adjustment: Int, comment: String?) async throws -> IndividualAdjustment
    func getMyTeamGrade(assignmentId: String) async throws -> MyTeamGrade?

    // MARK: - Quick Assignments
    func createQuickAssignment(classId: String, title: String, isTeamBased: Bool, teamIds: [String]) async throws -> Assignment
}

// MARK: - Environment Key

private struct APIServiceKey: EnvironmentKey {
    static let defaultValue: APIServiceProtocol = APIService.shared
}

extension EnvironmentValues {
    var apiService: APIServiceProtocol {
        get { self[APIServiceKey.self] }
        set { self[APIServiceKey.self] = newValue }
    }
}
