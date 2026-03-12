import Foundation

enum MockData {
    static let sampleUser = User(
        id: "user-1",
        firstName: "Иван",
        lastName: "Петров",
        email: "ivan@test.com",
        avatarURL: "https://example.com/avatar.jpg",
        dateOfBirth: Date(timeIntervalSince1970: 946684800) // 2000-01-01
    )

    static let sampleUser2 = User(
        id: "user-2",
        firstName: "Анна",
        lastName: "Сидорова",
        email: "anna@test.com",
        avatarURL: nil,
        dateOfBirth: nil
    )

    static let sampleClasses: [ClassRoom] = [
        ClassRoom(id: "class-1", name: "Математика 101", code: "MATH1234", myRole: .owner, memberCount: 25),
        ClassRoom(id: "class-2", name: "Физика", code: "PHYS5678", myRole: .teacher, memberCount: 18),
        ClassRoom(id: "class-3", name: "История", code: "HIST9012", myRole: .student, memberCount: 30),
    ]

    static let sampleAssignments: [Assignment] = [
        Assignment(
            id: "assign-1",
            title: "Домашнее задание 1",
            description: "Решить задачи 1-10 из учебника",
            deadline: Date(timeIntervalSince1970: 1710000000),
            createdAt: Date(timeIntervalSince1970: 1709280000),
            submissionStatus: .submitted
        ),
        Assignment(
            id: "assign-2",
            title: "Контрольная работа",
            description: "Теория множеств",
            createdAt: Date(timeIntervalSince1970: 1709366400),
            submissionStatus: .graded
        ),
        Assignment(
            id: "assign-3",
            title: "Лабораторная работа",
            description: "Механика",
            deadline: Date().addingTimeInterval(7 * 24 * 3600),
            createdAt: Date(timeIntervalSince1970: 1709452800),
            submissionStatus: nil
        ),
    ]

    static let sampleMembers: [Member] = [
        Member(userId: "user-1", firstName: "Иван", lastName: "Петров", email: "ivan@test.com", role: .owner, avatarUrl: "https://example.com/avatar.jpg"),
        Member(userId: "user-2", firstName: "Анна", lastName: "Сидорова", email: "anna@test.com", role: .teacher, avatarUrl: nil),
        Member(userId: "user-3", firstName: "Пётр", lastName: "Иванов", email: "petr@test.com", role: .student, avatarUrl: nil),
    ]

    static let sampleSubmissions: [Submission] = [
        Submission(id: "sub-1", studentId: "user-3", studentName: "Пётр Иванов", studentAvatarUrl: nil, text: "Мой ответ на задание", fileUrls: nil, grade: 85, submittedAt: Date(timeIntervalSince1970: 1709366400)),
        Submission(id: "sub-2", studentId: "user-4", studentName: "Мария Козлова", studentAvatarUrl: nil, text: nil, fileUrls: ["https://example.com/file.pdf"], grade: nil, submittedAt: Date(timeIntervalSince1970: 1709452800)),
    ]

    static let sampleComments: [Comment] = [
        Comment(id: "com-1", assignmentId: "assign-1", authorId: "user-1", authorName: "Иван Петров", authorAvatarUrl: "https://example.com/avatar.jpg", text: "Отличная работа!", createdAt: Date(timeIntervalSince1970: 1709366400)),
        Comment(id: "com-2", assignmentId: "assign-1", authorId: "user-3", authorName: "Пётр Иванов", authorAvatarUrl: nil, text: "Спасибо!", createdAt: Date(timeIntervalSince1970: 1709370000)),
    ]

    static let sampleAuthResponse = AuthResponse(
        token: "test_jwt_token",
        user: sampleUser
    )
}
