import XCTest
@testable import LMS

// MARK: - MockAPIService Tests

final class MockAPIServiceTests: XCTestCase {
    var sut: MockAPIService!

    override func setUp() {
        sut = MockAPIService()
    }

    override func tearDown() {
        sut = nil
    }

    // MARK: - Login

    func test_login_success_returnsAuthResponse() async throws {
        let response = try await sut.login(email: "test@test.com", password: "password")

        XCTAssertFalse(response.token.isEmpty)
        XCTAssertEqual(response.user.email, MockData.sampleUser.email)
    }

    func test_login_stubbedResponse_returnsStub() async throws {
        let stubUser = User(id: "stub", firstName: "S", lastName: "T", email: "s@t.com")
        sut.stubbedLoginResponse = AuthResponse(token: "stub_token", user: stubUser)

        let response = try await sut.login(email: "any", password: "any")

        XCTAssertEqual(response.token, "stub_token")
        XCTAssertEqual(response.user.id, "stub")
    }

    func test_login_shouldThrowError_throws() async {
        sut.shouldThrowError = .unauthorized

        do {
            _ = try await sut.login(email: "test@test.com", password: "wrong")
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Register

    func test_register_success_returnsAuthResponse() async throws {
        let request = RegisterRequest(firstName: "A", lastName: "B", email: "a@b.com", password: "12345678")

        let response = try await sut.register(request: request)

        XCTAssertFalse(response.token.isEmpty)
    }

    func test_register_shouldThrowError_throws() async {
        sut.shouldThrowError = .conflict("Email already exists")

        do {
            let request = RegisterRequest(firstName: "A", lastName: "B", email: "a@b.com", password: "12345678")
            _ = try await sut.register(request: request)
            XCTFail("Expected error")
        } catch let error as NetworkError {
            if case .conflict(let msg) = error {
                XCTAssertEqual(msg, "Email already exists")
            } else {
                XCTFail("Expected conflict error")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }

    // MARK: - Classes

    func test_getMyClasses_success_returnsClasses() async throws {
        sut.stubbedClasses = MockData.sampleClasses

        let classes = try await sut.getMyClasses()

        XCTAssertEqual(classes.count, MockData.sampleClasses.count)
    }

    func test_getMyClasses_empty_returnsEmpty() async throws {
        sut.stubbedClasses = []

        let classes = try await sut.getMyClasses()

        XCTAssertTrue(classes.isEmpty)
    }

    func test_getMyClasses_shouldThrowError_throws() async {
        sut.shouldThrowError = .serverError(500)

        do {
            _ = try await sut.getMyClasses()
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .serverError(500))
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func test_createClass_success_returnsClassRoom() async throws {
        let classroom = try await sut.createClass(name: "Новый класс")

        XCTAssertEqual(classroom.name, "Новый класс")
        XCTAssertEqual(classroom.myRole, .owner)
        XCTAssertFalse(classroom.code.isEmpty)
    }

    func test_joinClass_success_returnsClassRoom() async throws {
        let classroom = try await sut.joinClass(code: "ABC12345")

        XCTAssertEqual(classroom.myRole, .student)
    }

    func test_joinClass_shouldThrowError_throws() async {
        sut.shouldThrowError = .notFound

        do {
            _ = try await sut.joinClass(code: "INVALID")
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func test_deleteClass_success_doesNotThrow() async throws {
        try await sut.deleteClass(id: "class-1")
    }

    func test_updateClass_success_returnsUpdatedClass() async throws {
        let updated = try await sut.updateClass(id: "class-1", name: "Новое имя")

        XCTAssertEqual(updated.name, "Новое имя")
    }

    // MARK: - Members

    func test_getMembers_success_returnsMembers() async throws {
        sut.stubbedMembers = MockData.sampleMembers

        let members = try await sut.getMembers(classId: "class-1")

        XCTAssertEqual(members.count, MockData.sampleMembers.count)
    }

    func test_assignRole_success_doesNotThrow() async throws {
        try await sut.assignRole(classId: "class-1", userId: "user-2", role: .teacher)
    }

    // MARK: - Assignments

    func test_getAssignments_success_returnsAssignments() async throws {
        sut.stubbedAssignments = MockData.sampleAssignments

        let assignments = try await sut.getAssignments(classId: "class-1")

        XCTAssertEqual(assignments.count, MockData.sampleAssignments.count)
    }

    func test_createAssignment_success_returnsAssignment() async throws {
        let assignment = try await sut.createAssignment(classId: "class-1", title: "Тест", description: "Описание")

        XCTAssertEqual(assignment.title, "Тест")
        XCTAssertEqual(assignment.description, "Описание")
    }

    // MARK: - Submissions

    func test_submitAnswer_success_returnsSubmission() async throws {
        let submission = try await sut.submitAnswer(assignmentId: "assign-1", text: "Ответ", fileData: nil, fileName: nil)

        XCTAssertEqual(submission.text, "Ответ")
    }

    func test_getSubmissions_success_returnsSubmissions() async throws {
        sut.stubbedSubmissions = MockData.sampleSubmissions

        let submissions = try await sut.getSubmissions(assignmentId: "assign-1")

        XCTAssertEqual(submissions.count, MockData.sampleSubmissions.count)
    }

    func test_gradeSubmission_success_returnsGradedSubmission() async throws {
        let submission = try await sut.gradeSubmission(submissionId: "sub-1", grade: 95)

        XCTAssertEqual(submission.grade, 95)
    }

    // MARK: - Comments

    func test_getComments_success_returnsComments() async throws {
        sut.stubbedComments = MockData.sampleComments

        let comments = try await sut.getComments(assignmentId: "assign-1")

        XCTAssertEqual(comments.count, MockData.sampleComments.count)
    }

    func test_addComment_success_returnsComment() async throws {
        let comment = try await sut.addComment(assignmentId: "assign-1", text: "Новый комментарий")

        XCTAssertEqual(comment.text, "Новый комментарий")
    }

    // MARK: - Profile

    func test_getProfile_success_returnsUser() async throws {
        sut.stubbedProfile = MockData.sampleUser

        let user = try await sut.getProfile()

        XCTAssertEqual(user.id, MockData.sampleUser.id)
    }

    func test_updateProfile_success_returnsUpdatedUser() async throws {
        let request = UpdateProfileRequest(firstName: "Новое", lastName: "Имя")

        let user = try await sut.updateProfile(request: request)

        XCTAssertEqual(user.firstName, "Новое")
        XCTAssertEqual(user.lastName, "Имя")
    }
}

// MARK: - NetworkError Tests

final class NetworkErrorTests: XCTestCase {

    func test_networkError_unauthorized_isEquatable() {
        XCTAssertEqual(NetworkError.unauthorized, NetworkError.unauthorized)
    }

    func test_networkError_serverError_isEquatable() {
        XCTAssertEqual(NetworkError.serverError(500), NetworkError.serverError(500))
        XCTAssertNotEqual(NetworkError.serverError(500), NetworkError.serverError(503))
    }

    func test_networkError_notFound_isEquatable() {
        XCTAssertEqual(NetworkError.notFound, NetworkError.notFound)
    }

    func test_networkError_conflict_isEquatable() {
        XCTAssertEqual(NetworkError.conflict("msg"), NetworkError.conflict("msg"))
    }

    func test_networkError_noConnection_isEquatable() {
        XCTAssertEqual(NetworkError.noConnection, NetworkError.noConnection)
    }

    func test_networkError_decodingError_isEquatable() {
        XCTAssertEqual(NetworkError.decodingError, NetworkError.decodingError)
    }

    func test_networkError_unknown_isEquatable() {
        XCTAssertEqual(NetworkError.unknown("a"), NetworkError.unknown("a"))
    }

    func test_networkError_localizedDescription_isNotEmpty() {
        let errors: [NetworkError] = [
            .unauthorized,
            .notFound,
            .noConnection,
            .serverError(500),
            .conflict("test"),
            .decodingError,
            .unknown("error"),
        ]

        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty, "\(error) has empty description")
        }
    }
}

// MARK: - APIConfig Tests

final class APIConfigTests: XCTestCase {

    func test_baseURL_isNotEmpty() {
        XCTAssertFalse(APIConfig.baseURL.isEmpty)
    }

    func test_baseURL_isValidURL() {
        XCTAssertNotNil(URL(string: APIConfig.baseURL))
    }
}
