import Foundation

final class MockAPIService: APIServiceProtocol {

    // MARK: - Configurable Stubs

    var stubbedLoginResponse: AuthResponse?
    var stubbedClasses: [ClassRoom] = []
    var stubbedAssignments: [Assignment] = []
    var stubbedMembers: [Member] = []
    var stubbedSubmissions: [Submission] = []
    var stubbedComments: [Comment] = []
    var stubbedProfile: User?
    var shouldThrowError: NetworkError?

    // MARK: - Auth

    func login(email: String, password: String) async throws -> AuthResponse {
        if let error = shouldThrowError { throw error }
        return stubbedLoginResponse ?? MockData.sampleAuthResponse
    }

    func register(request: RegisterRequest) async throws -> AuthResponse {
        if let error = shouldThrowError { throw error }
        let user = User(
            id: UUID().uuidString,
            firstName: request.firstName,
            lastName: request.lastName,
            email: request.email
        )
        return AuthResponse(token: "test_token", user: user)
    }

    // MARK: - Classes

    func getMyClasses() async throws -> [ClassRoom] {
        if let error = shouldThrowError { throw error }
        return stubbedClasses
    }

    func createClass(name: String) async throws -> ClassRoom {
        if let error = shouldThrowError { throw error }
        return ClassRoom(
            id: UUID().uuidString,
            name: name,
            code: String("ABCDEFGH".prefix(8)),
            myRole: .owner,
            memberCount: 1
        )
    }

    func joinClass(code: String) async throws -> ClassRoom {
        if let error = shouldThrowError { throw error }
        return ClassRoom(
            id: UUID().uuidString,
            name: "Присоединённый класс",
            code: code,
            myRole: .student,
            memberCount: 10
        )
    }

    func deleteClass(id: String) async throws {
        if let error = shouldThrowError { throw error }
    }

    func updateClass(id: String, name: String) async throws -> ClassRoom {
        if let error = shouldThrowError { throw error }
        return ClassRoom(id: id, name: name, code: "ABCD1234", myRole: .owner, memberCount: 5)
    }

    // MARK: - Members

    func getMembers(classId: String) async throws -> [Member] {
        if let error = shouldThrowError { throw error }
        return stubbedMembers
    }

    func assignRole(classId: String, userId: String, role: Role) async throws {
        if let error = shouldThrowError { throw error }
    }

    // MARK: - Assignments

    func getAssignments(classId: String) async throws -> [Assignment] {
        if let error = shouldThrowError { throw error }
        return stubbedAssignments
    }

    func createAssignment(classId: String, title: String, description: String) async throws -> Assignment {
        if let error = shouldThrowError { throw error }
        return Assignment(
            id: UUID().uuidString,
            title: title,
            description: description,
            createdAt: Date(),
            submissionStatus: nil
        )
    }

    // MARK: - Submissions

    func submitAnswer(assignmentId: String, text: String?, fileData: Data?, fileName: String?) async throws -> Submission {
        if let error = shouldThrowError { throw error }
        return Submission(
            id: UUID().uuidString,
            studentId: MockData.sampleUser.id,
            studentName: "\(MockData.sampleUser.firstName) \(MockData.sampleUser.lastName)",
            text: text,
            fileURL: fileName.map { "https://example.com/files/\($0)" },
            grade: nil,
            submittedAt: Date()
        )
    }

    func getSubmissions(assignmentId: String) async throws -> [Submission] {
        if let error = shouldThrowError { throw error }
        return stubbedSubmissions
    }

    func gradeSubmission(submissionId: String, grade: Int) async throws -> Submission {
        if let error = shouldThrowError { throw error }
        return Submission(
            id: submissionId,
            studentId: "user-1",
            studentName: "Студент",
            text: "Ответ",
            fileURL: nil,
            grade: grade,
            submittedAt: Date()
        )
    }

    // MARK: - Comments

    func getComments(assignmentId: String) async throws -> [Comment] {
        if let error = shouldThrowError { throw error }
        return stubbedComments
    }

    func addComment(assignmentId: String, text: String) async throws -> Comment {
        if let error = shouldThrowError { throw error }
        return Comment(
            id: UUID().uuidString,
            authorId: MockData.sampleUser.id,
            authorName: "\(MockData.sampleUser.firstName) \(MockData.sampleUser.lastName)",
            authorAvatarURL: MockData.sampleUser.avatarURL,
            text: text,
            createdAt: Date()
        )
    }

    // MARK: - Profile

    func getProfile() async throws -> User {
        if let error = shouldThrowError { throw error }
        return stubbedProfile ?? MockData.sampleUser
    }

    func updateProfile(request: UpdateProfileRequest) async throws -> User {
        if let error = shouldThrowError { throw error }
        var user = stubbedProfile ?? MockData.sampleUser
        if let firstName = request.firstName { user.firstName = firstName }
        if let lastName = request.lastName { user.lastName = lastName }
        return user
    }
}
