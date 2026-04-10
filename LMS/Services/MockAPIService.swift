import Foundation

final class MockAPIService: APIServiceProtocol {

    // MARK: - Configurable Stubs

    var stubbedLoginResponse: AuthResponse?
    var stubbedClasses: [ClassRoom] = []
    var stubbedAssignments: [Assignment] = []
    var stubbedMembers: [Member] = []
    var stubbedSubmissions: [Submission] = []
    var stubbedComments: [Comment] = []
    var stubbedMySubmission: Submission?
    var stubbedProfile: User?
    var shouldThrowError: NetworkError?
    var stubbedTeams: [TeamListItem] = []
    var stubbedTeamDetail: Team?
    var stubbedMyTeams: [Team] = []
    var stubbedTeamGrades: [TeamGrade] = []
    var stubbedMyTeamGrade: MyTeamGrade?

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

    func regenerateCode(id: String) async throws -> ClassRoom {
        if let error = shouldThrowError { throw error }
        return ClassRoom(id: id, name: "Class", code: "NEWCODE1", myRole: .owner, memberCount: 5)
    }

    // MARK: - Members

    func getMembers(classId: String) async throws -> [Member] {
        if let error = shouldThrowError { throw error }
        return stubbedMembers
    }

    func assignRole(classId: String, userId: String, role: Role) async throws {
        if let error = shouldThrowError { throw error }
    }

    func removeMember(classId: String, userId: String) async throws {
        if let error = shouldThrowError { throw error }
    }

    // MARK: - Assignments

    func getAssignments(classId: String) async throws -> [Assignment] {
        if let error = shouldThrowError { throw error }
        return stubbedAssignments
    }

    func createAssignment(classId: String, title: String, description: String, deadline: Date?, isTeamBased: Bool, files: [FileData]) async throws -> Assignment {
        if let error = shouldThrowError { throw error }
        return Assignment(
            id: UUID().uuidString,
            title: title,
            description: description,
            deadline: deadline,
            createdAt: Date(),
            submissionStatus: nil,
            fileUrls: files.map { "https://example.com/files/\($0.fileName)" },
            type: "STANDARD",
            isTeamBased: isTeamBased
        )
    }

    // MARK: - Submissions

    func submitAnswer(assignmentId: String, text: String?, files: [FileData]) async throws -> Submission {
        if let error = shouldThrowError { throw error }
        return Submission(
            id: UUID().uuidString,
            studentId: MockData.sampleUser.id,
            studentName: "\(MockData.sampleUser.firstName) \(MockData.sampleUser.lastName)",
            text: text,
            fileUrls: files.map { "https://example.com/files/\($0.fileName)" },
            grade: nil,
            submittedAt: Date()
        )
    }

    func getMySubmission(assignmentId: String) async throws -> Submission? {
        if let error = shouldThrowError { throw error }
        return stubbedMySubmission
    }

    func cancelSubmission(assignmentId: String) async throws {
        if let error = shouldThrowError { throw error }
        stubbedMySubmission = nil
    }

    func getSubmissions(assignmentId: String) async throws -> [Submission] {
        if let error = shouldThrowError { throw error }
        return stubbedSubmissions
    }

    func gradeSubmission(submissionId: String, grade: Int) async throws -> Submission {
        if let error = shouldThrowError { throw error }
        if let index = stubbedSubmissions.firstIndex(where: { $0.id == submissionId }) {
            stubbedSubmissions[index].grade = grade
            return stubbedSubmissions[index]
        }
        return Submission(
            id: submissionId,
            studentId: "user-1",
            studentName: "Студент",
            text: "Ответ",
            fileUrls: nil,
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
            assignmentId: assignmentId,
            authorId: MockData.sampleUser.id,
            authorName: "\(MockData.sampleUser.firstName) \(MockData.sampleUser.lastName)",
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
        user.firstName = request.firstName
        user.lastName = request.lastName
        if let avatarUrl = request.avatarUrl {
            user.avatarURL = avatarUrl
        }
        return user
    }

    func uploadAvatar(imageData: Data, fileName: String) async throws -> User {
        if let error = shouldThrowError { throw error }
        var user = stubbedProfile ?? MockData.sampleUser
        user.avatarURL = "https://example.com/avatars/\(fileName)"
        stubbedProfile = user
        return user
    }

    // MARK: - Teams

    func getTeams(classId: String) async throws -> [TeamListItem] {
        if let error = shouldThrowError { throw error }
        return stubbedTeams
    }

    func getTeam(classId: String, teamId: String) async throws -> Team {
        if let error = shouldThrowError { throw error }
        return stubbedTeamDetail ?? Team(
            id: teamId, classId: classId, assignmentId: nil,
            name: "Ансамбль A",
            members: [
                TeamMember(userId: "user-1", firstName: "Иван", lastName: "Петров", isLeader: true, joinedAt: Date()),
                TeamMember(userId: "user-2", firstName: "Анна", lastName: "Сидорова", isLeader: false, joinedAt: Date())
            ],
            createdBy: "user-1", createdAt: Date()
        )
    }

    func createTeam(classId: String, name: String, assignmentId: String?, memberUserIds: [String], leaderUserId: String?) async throws -> Team {
        if let error = shouldThrowError { throw error }
        let members = memberUserIds.enumerated().map { i, uid in
            TeamMember(userId: uid, firstName: "Участник", lastName: "\(i+1)", isLeader: uid == leaderUserId, joinedAt: Date())
        }
        return Team(id: UUID().uuidString, classId: classId, assignmentId: assignmentId, name: name, members: members, createdBy: "me", createdAt: Date())
    }

    func updateTeam(classId: String, teamId: String, name: String?, leaderUserId: String?) async throws -> Team {
        if let error = shouldThrowError { throw error }
        return Team(id: teamId, classId: classId, assignmentId: nil, name: name ?? "Команда", members: [], createdBy: "me", createdAt: Date())
    }

    func deleteTeam(classId: String, teamId: String) async throws {
        if let error = shouldThrowError { throw error }
    }

    func shuffleTeams(classId: String, teamCount: Int, assignmentId: String?, strategy: String) async throws -> ShuffleResponse {
        if let error = shouldThrowError { throw error }
        let teams = (1...teamCount).map { i in
            Team(id: UUID().uuidString, classId: classId, assignmentId: assignmentId, name: "Команда \(i)",
                 members: [TeamMember(userId: UUID().uuidString, firstName: "Лидер", lastName: "\(i)", isLeader: true, joinedAt: Date())],
                 createdBy: "me", createdAt: Date())
        }
        return ShuffleResponse(teams: teams, totalStudents: teamCount * 3, studentsPerTeam: 3)
    }

    func addTeamMember(classId: String, teamId: String, userId: String, isLeader: Bool) async throws -> Team {
        if let error = shouldThrowError { throw error }
        return try await getTeam(classId: classId, teamId: teamId)
    }

    func removeTeamMember(classId: String, teamId: String, userId: String) async throws {
        if let error = shouldThrowError { throw error }
    }

    func getMyTeams(classId: String) async throws -> [Team] {
        if let error = shouldThrowError { throw error }
        return stubbedMyTeams
    }

    // MARK: - Team Grades

    func createTeamGrade(assignmentId: String, teamId: String, grade: Int, comment: String?) async throws -> TeamGrade {
        if let error = shouldThrowError { throw error }
        let adjustments = [
            IndividualAdjustment(studentId: "user-1", studentName: "Иван Петров", teamGrade: grade, adjustment: 0, finalGrade: grade, comment: nil, gradedBy: nil, gradedAt: nil)
        ]
        return TeamGrade(id: UUID().uuidString, teamId: teamId, teamName: "Команда", assignmentId: assignmentId, grade: grade, comment: comment, individualGrades: adjustments, gradedBy: "me", gradedAt: Date())
    }

    func getTeamGrades(assignmentId: String) async throws -> [TeamGrade] {
        if let error = shouldThrowError { throw error }
        return stubbedTeamGrades
    }

    func updateTeamGrade(assignmentId: String, teamGradeId: String, grade: Int, comment: String?) async throws -> TeamGrade {
        if let error = shouldThrowError { throw error }
        return TeamGrade(id: teamGradeId, teamId: "team-1", teamName: "Команда", assignmentId: assignmentId, grade: grade, comment: comment, individualGrades: [], gradedBy: "me", gradedAt: Date())
    }

    func getAdjustments(assignmentId: String, teamGradeId: String) async throws -> [IndividualAdjustment] {
        if let error = shouldThrowError { throw error }
        return []
    }

    func updateAdjustment(assignmentId: String, teamGradeId: String, studentId: String, adjustment: Int, comment: String?) async throws -> IndividualAdjustment {
        if let error = shouldThrowError { throw error }
        return IndividualAdjustment(studentId: studentId, studentName: "Студент", teamGrade: 80, adjustment: adjustment, finalGrade: min(max(80 + adjustment, 0), 100), comment: comment, gradedBy: "me", gradedAt: Date())
    }

    func getMyTeamGrade(assignmentId: String) async throws -> MyTeamGrade? {
        if let error = shouldThrowError { throw error }
        return stubbedMyTeamGrade
    }

    // MARK: - Quick Assignments

    func createQuickAssignment(classId: String, title: String, isTeamBased: Bool, teamIds: [String]) async throws -> Assignment {
        if let error = shouldThrowError { throw error }
        return Assignment(id: UUID().uuidString, title: title, description: "", deadline: nil, createdAt: Date(), submissionStatus: nil, fileUrls: nil, type: "QUICK", isTeamBased: isTeamBased)
    }

    // MARK: - Stats

    func getClassStats(classId: String) async throws -> ClassStats {
        if let error = shouldThrowError { throw error }
        return ClassStats(
            classId: classId,
            className: "Математика 101",
            totalAssignments: 3,
            totalStudents: 3,
            classAverageGrade: 78.5,
            submissionRate: 85.0,
            students: [
                StudentStat(studentId: "user-3", studentName: "Пётр Иванов", avatarUrl: nil, submittedCount: 3, gradedCount: 2, averageGrade: 85.0, missedCount: 0),
                StudentStat(studentId: "user-4", studentName: "Мария Козлова", avatarUrl: nil, submittedCount: 2, gradedCount: 1, averageGrade: 72.0, missedCount: 1),
                StudentStat(studentId: "user-5", studentName: "Алексей Смирнов", avatarUrl: nil, submittedCount: 0, gradedCount: 0, averageGrade: nil, missedCount: 2),
            ]
        )
    }
}
