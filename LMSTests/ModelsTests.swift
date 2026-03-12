import XCTest
@testable import LMS

final class UserModelTests: XCTestCase {

    func test_user_decodesFromJSON_allFields() throws {
        let json = """
        {
            "id": "user-1",
            "firstName": "Иван",
            "lastName": "Петров",
            "email": "ivan@test.com",
            "avatarUrl": "https://example.com/avatar.jpg",
            "dateOfBirth": "2000-01-15"
        }
        """.data(using: .utf8)!

        let user = try JSONDecoder.lms.decode(User.self, from: json)

        XCTAssertEqual(user.id, "user-1")
        XCTAssertEqual(user.firstName, "Иван")
        XCTAssertEqual(user.lastName, "Петров")
        XCTAssertEqual(user.email, "ivan@test.com")
        XCTAssertEqual(user.avatarURL, "https://example.com/avatar.jpg")
        XCTAssertNotNil(user.dateOfBirth)
    }

    func test_user_decodesFromJSON_optionalFieldsNil() throws {
        let json = """
        {
            "id": "user-2",
            "firstName": "Анна",
            "lastName": "Сидорова",
            "email": "anna@test.com"
        }
        """.data(using: .utf8)!

        let user = try JSONDecoder.lms.decode(User.self, from: json)

        XCTAssertEqual(user.id, "user-2")
        XCTAssertNil(user.avatarURL)
        XCTAssertNil(user.dateOfBirth)
    }

    func test_user_encodesAndDecodes_roundTrip() throws {
        let user = User(
            id: "user-3",
            firstName: "Тест",
            lastName: "Тестов",
            email: "test@test.com",
            avatarURL: "https://example.com/a.jpg",
            dateOfBirth: Date(timeIntervalSince1970: 946684800)
        )

        let data = try JSONEncoder.lms.encode(user)
        let decoded = try JSONDecoder.lms.decode(User.self, from: data)

        XCTAssertEqual(user, decoded)
    }

    func test_user_conformsToIdentifiable() {
        let user = User(id: "u1", firstName: "A", lastName: "B", email: "a@b.com")
        XCTAssertEqual(user.id, "u1")
    }

    func test_user_conformsToHashable() {
        let user1 = User(id: "u1", firstName: "A", lastName: "B", email: "a@b.com")
        let user2 = User(id: "u1", firstName: "A", lastName: "B", email: "a@b.com")
        XCTAssertEqual(user1.hashValue, user2.hashValue)
    }
}

final class RoleModelTests: XCTestCase {

    func test_role_rawValues() {
        XCTAssertEqual(Role.owner.rawValue, "OWNER")
        XCTAssertEqual(Role.teacher.rawValue, "TEACHER")
        XCTAssertEqual(Role.student.rawValue, "STUDENT")
    }

    func test_role_decodesFromJSON() throws {
        let json = "\"OWNER\"".data(using: .utf8)!
        let role = try JSONDecoder().decode(Role.self, from: json)
        XCTAssertEqual(role, .owner)
    }

    func test_role_encodesToJSON() throws {
        let data = try JSONEncoder().encode(Role.teacher)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"TEACHER\"")
    }
}

final class ClassRoomModelTests: XCTestCase {

    func test_classRoom_decodesFromJSON() throws {
        let json = """
        {
            "id": "class-1",
            "name": "Математика 101",
            "code": "ABC12345",
            "myRole": "OWNER",
            "memberCount": 25
        }
        """.data(using: .utf8)!

        let classroom = try JSONDecoder.lms.decode(ClassRoom.self, from: json)

        XCTAssertEqual(classroom.id, "class-1")
        XCTAssertEqual(classroom.name, "Математика 101")
        XCTAssertEqual(classroom.code, "ABC12345")
        XCTAssertEqual(classroom.myRole, .owner)
        XCTAssertEqual(classroom.memberCount, 25)
    }

    func test_classRoom_encodesAndDecodes_roundTrip() throws {
        let classroom = ClassRoom(
            id: "c1",
            name: "Физика",
            code: "XYZ99999",
            myRole: .student,
            memberCount: 10
        )

        let data = try JSONEncoder.lms.encode(classroom)
        let decoded = try JSONDecoder.lms.decode(ClassRoom.self, from: data)

        XCTAssertEqual(classroom, decoded)
    }
}

final class SubmissionStatusModelTests: XCTestCase {

    func test_submissionStatus_rawValues() {
        XCTAssertEqual(SubmissionStatus.notSubmitted.rawValue, "NOT_SUBMITTED")
        XCTAssertEqual(SubmissionStatus.submitted.rawValue, "SUBMITTED")
        XCTAssertEqual(SubmissionStatus.graded.rawValue, "GRADED")
    }

    func test_submissionStatus_decodesFromJSON() throws {
        let json = "\"GRADED\"".data(using: .utf8)!
        let status = try JSONDecoder().decode(SubmissionStatus.self, from: json)
        XCTAssertEqual(status, .graded)
    }
}

final class AssignmentModelTests: XCTestCase {

    func test_assignment_decodesFromJSON_withStatus() throws {
        let json = """
        {
            "id": "assign-1",
            "title": "Домашнее задание 1",
            "description": "Решить задачи 1-10",
            "createdAt": "2026-03-01T10:00:00Z",
            "submissionStatus": "SUBMITTED"
        }
        """.data(using: .utf8)!

        let assignment = try JSONDecoder.lms.decode(Assignment.self, from: json)

        XCTAssertEqual(assignment.id, "assign-1")
        XCTAssertEqual(assignment.title, "Домашнее задание 1")
        XCTAssertEqual(assignment.description, "Решить задачи 1-10")
        XCTAssertNotNil(assignment.createdAt)
        XCTAssertEqual(assignment.submissionStatus, .submitted)
        XCTAssertNil(assignment.deadline)
    }

    func test_assignment_decodesFromJSON_withDeadline() throws {
        let json = """
        {
            "id": "assign-1",
            "title": "Задание",
            "description": "Описание",
            "deadline": "2026-04-01T23:59:00Z",
            "createdAt": "2026-03-01T10:00:00Z"
        }
        """.data(using: .utf8)!

        let assignment = try JSONDecoder.lms.decode(Assignment.self, from: json)

        XCTAssertNotNil(assignment.deadline)
    }

    func test_assignment_decodesFromJSON_withoutStatus() throws {
        let json = """
        {
            "id": "assign-2",
            "title": "Задание 2",
            "description": "",
            "createdAt": "2026-03-02T12:00:00Z"
        }
        """.data(using: .utf8)!

        let assignment = try JSONDecoder.lms.decode(Assignment.self, from: json)

        XCTAssertNil(assignment.submissionStatus)
        XCTAssertNil(assignment.deadline)
    }

    func test_assignment_encodesAndDecodes_roundTrip() throws {
        let assignment = Assignment(
            id: "a1",
            title: "Test",
            description: "Desc",
            deadline: Date(timeIntervalSince1970: 1710000000),
            createdAt: Date(timeIntervalSince1970: 1709280000),
            submissionStatus: .graded
        )

        let data = try JSONEncoder.lms.encode(assignment)
        let decoded = try JSONDecoder.lms.decode(Assignment.self, from: data)

        XCTAssertEqual(assignment, decoded)
    }
}

final class SubmissionModelTests: XCTestCase {

    func test_submission_decodesFromJSON_allFields() throws {
        let json = """
        {
            "id": "sub-1",
            "studentId": "user-1",
            "studentName": "Иван Петров",
            "answerText": "Мой ответ",
            "fileUrls": ["https://example.com/file.pdf"],
            "grade": 85,
            "submittedAt": "2026-03-01T14:00:00Z"
        }
        """.data(using: .utf8)!

        let submission = try JSONDecoder.lms.decode(Submission.self, from: json)

        XCTAssertEqual(submission.id, "sub-1")
        XCTAssertEqual(submission.studentId, "user-1")
        XCTAssertEqual(submission.studentName, "Иван Петров")
        XCTAssertEqual(submission.text, "Мой ответ")
        XCTAssertEqual(submission.fileUrls, ["https://example.com/file.pdf"])
        XCTAssertEqual(submission.grade, 85)
        XCTAssertNotNil(submission.submittedAt)
    }

    func test_submission_decodesFromJSON_optionalFieldsNil() throws {
        let json = """
        {
            "id": "sub-2",
            "studentId": "user-2",
            "studentName": "Анна",
            "submittedAt": "2026-03-01T14:00:00Z"
        }
        """.data(using: .utf8)!

        let submission = try JSONDecoder.lms.decode(Submission.self, from: json)

        XCTAssertNil(submission.text)
        XCTAssertNil(submission.fileUrls)
        XCTAssertNil(submission.grade)
    }
}

final class CommentModelTests: XCTestCase {

    func test_comment_decodesFromJSON() throws {
        let json = """
        {
            "id": "com-1",
            "assignmentId": "assign-1",
            "authorId": "user-1",
            "authorName": "Иван Петров",
            "text": "Отличная работа!",
            "createdAt": "2026-03-01T15:00:00Z"
        }
        """.data(using: .utf8)!

        let comment = try JSONDecoder.lms.decode(Comment.self, from: json)

        XCTAssertEqual(comment.id, "com-1")
        XCTAssertEqual(comment.assignmentId, "assign-1")
        XCTAssertEqual(comment.authorId, "user-1")
        XCTAssertEqual(comment.authorName, "Иван Петров")
        XCTAssertEqual(comment.text, "Отличная работа!")
        XCTAssertNotNil(comment.createdAt)
    }

    func test_comment_decodesFromJSON_noAssignmentId() throws {
        let json = """
        {
            "id": "com-2",
            "authorId": "user-2",
            "authorName": "Анна",
            "text": "Вопрос",
            "createdAt": "2026-03-01T16:00:00Z"
        }
        """.data(using: .utf8)!

        let comment = try JSONDecoder.lms.decode(Comment.self, from: json)

        XCTAssertNil(comment.assignmentId)
    }
}

final class MemberModelTests: XCTestCase {

    func test_member_decodesFromJSON() throws {
        let json = """
        {
            "userId": "user-1",
            "firstName": "Иван",
            "lastName": "Петров",
            "email": "ivan@test.com",
            "role": "TEACHER"
        }
        """.data(using: .utf8)!

        let member = try JSONDecoder.lms.decode(Member.self, from: json)

        XCTAssertEqual(member.id, "user-1")
        XCTAssertEqual(member.userId, "user-1")
        XCTAssertEqual(member.firstName, "Иван")
        XCTAssertEqual(member.lastName, "Петров")
        XCTAssertEqual(member.email, "ivan@test.com")
        XCTAssertEqual(member.role, .teacher)
    }
}

final class AuthResponseModelTests: XCTestCase {

    func test_authResponse_decodesFromJSON() throws {
        let json = """
        {
            "token": "jwt_token_here",
            "user": {
                "id": "user-1",
                "firstName": "Иван",
                "lastName": "Петров",
                "email": "ivan@test.com"
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.lms.decode(AuthResponse.self, from: json)

        XCTAssertEqual(response.token, "jwt_token_here")
        XCTAssertEqual(response.user.id, "user-1")
        XCTAssertEqual(response.user.firstName, "Иван")
    }
}

final class RegisterRequestModelTests: XCTestCase {

    func test_registerRequest_encodesToJSON() throws {
        let request = RegisterRequest(
            firstName: "Иван",
            lastName: "Петров",
            email: "ivan@test.com",
            password: "password123",
            dateOfBirth: nil,
            avatarBase64: nil
        )

        let data = try JSONEncoder.lms.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["firstName"] as? String, "Иван")
        XCTAssertEqual(dict["lastName"] as? String, "Петров")
        XCTAssertEqual(dict["email"] as? String, "ivan@test.com")
        XCTAssertEqual(dict["password"] as? String, "password123")
    }

    func test_registerRequest_encodesToJSON_withOptionalFields() throws {
        let request = RegisterRequest(
            firstName: "Иван",
            lastName: "Петров",
            email: "ivan@test.com",
            password: "password123",
            dateOfBirth: "2000-01-15",
            avatarBase64: "base64data"
        )

        let data = try JSONEncoder.lms.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["dateOfBirth"] as? String, "2000-01-15")
        XCTAssertEqual(dict["avatarBase64"] as? String, "base64data")
    }
}

final class UpdateProfileRequestModelTests: XCTestCase {

    func test_updateProfileRequest_encodesToJSON() throws {
        let request = UpdateProfileRequest(
            firstName: "Новое",
            lastName: "Имя",
            dateOfBirth: "1999-05-20"
        )

        let data = try JSONEncoder.lms.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["firstName"] as? String, "Новое")
        XCTAssertEqual(dict["lastName"] as? String, "Имя")
        XCTAssertEqual(dict["dateOfBirth"] as? String, "1999-05-20")
    }

    func test_updateProfileRequest_encodesToJSON_withAvatarUrl() throws {
        let request = UpdateProfileRequest(
            firstName: "Иван",
            lastName: "Петров",
            avatarUrl: "https://example.com/avatar.jpg"
        )

        let data = try JSONEncoder.lms.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["avatarUrl"] as? String, "https://example.com/avatar.jpg")
    }
}

final class MockDataTests: XCTestCase {

    func test_sampleUser_isValid() {
        let user = MockData.sampleUser
        XCTAssertFalse(user.id.isEmpty)
        XCTAssertFalse(user.firstName.isEmpty)
        XCTAssertFalse(user.lastName.isEmpty)
        XCTAssertFalse(user.email.isEmpty)
    }

    func test_sampleClasses_areNotEmpty() {
        XCTAssertFalse(MockData.sampleClasses.isEmpty)
    }

    func test_sampleClasses_haveDifferentRoles() {
        let roles = Set(MockData.sampleClasses.map(\.myRole))
        XCTAssertTrue(roles.count > 1, "Sample classes should have different roles")
    }

    func test_sampleAssignments_areNotEmpty() {
        XCTAssertFalse(MockData.sampleAssignments.isEmpty)
    }

    func test_sampleMembers_areNotEmpty() {
        XCTAssertFalse(MockData.sampleMembers.isEmpty)
    }

    func test_sampleSubmissions_areNotEmpty() {
        XCTAssertFalse(MockData.sampleSubmissions.isEmpty)
    }

    func test_sampleComments_areNotEmpty() {
        XCTAssertFalse(MockData.sampleComments.isEmpty)
    }
}
