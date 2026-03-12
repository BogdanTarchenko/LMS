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
    func createAssignment(classId: String, title: String, description: String, deadline: Date?, files: [FileData]) async throws -> Assignment
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
