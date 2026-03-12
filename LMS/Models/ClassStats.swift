import Foundation

struct StudentStat: Codable, Identifiable {
    var id: String { studentId }
    let studentId: String
    let studentName: String
    let avatarUrl: String?
    let submittedCount: Int
    let gradedCount: Int
    let averageGrade: Double?
    let missedCount: Int
}

struct ClassStats: Codable {
    let classId: String
    let className: String
    let totalAssignments: Int
    let totalStudents: Int
    let classAverageGrade: Double?
    let submissionRate: Double
    let students: [StudentStat]
}
