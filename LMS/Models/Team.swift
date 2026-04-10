import Foundation

// MARK: - Team Member

struct TeamMember: Codable, Identifiable, Hashable {
    let userId: String
    let firstName: String
    let lastName: String
    let isLeader: Bool
    let joinedAt: Date?

    var id: String { userId }
    var fullName: String { "\(firstName) \(lastName)" }
}

// MARK: - Team (full detail)

struct Team: Codable, Identifiable, Hashable {
    let id: String
    let classId: String
    let assignmentId: String?
    var name: String
    var members: [TeamMember]
    let createdBy: String
    let createdAt: Date

    var leader: TeamMember? { members.first(where: { $0.isLeader }) }
}

// MARK: - Team List Item

struct TeamListItem: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    let assignmentId: String?
    let memberCount: Int
    let leaderName: String?
    let createdAt: Date

    var isPermanent: Bool { assignmentId == nil }
}

// MARK: - Shuffle

struct ShuffleResponse: Codable {
    let teams: [Team]
    let totalStudents: Int
    let studentsPerTeam: Int
}

// MARK: - Team Grade

struct TeamGrade: Codable, Identifiable {
    let id: String
    let teamId: String
    let teamName: String
    let assignmentId: String
    var grade: Int
    var comment: String?
    var individualGrades: [IndividualAdjustment]
    let gradedBy: String
    let gradedAt: Date
}

// MARK: - Individual Adjustment

struct IndividualAdjustment: Codable, Identifiable {
    let studentId: String
    let studentName: String
    let teamGrade: Int
    var adjustment: Int
    var finalGrade: Int
    var comment: String?
    var gradedBy: String?
    var gradedAt: Date?

    var id: String { studentId }
}

// MARK: - My Team Grade (student view)

struct MyTeamGrade: Codable {
    let teamId: String
    let teamName: String
    let teamGrade: Int
    let myAdjustment: Int
    let myFinalGrade: Int
    let comment: String?
    let gradedAt: Date
}

// MARK: - My Team (student view)

struct MyTeam: Codable, Identifiable {
    let id: String
    let name: String
    let assignmentId: String?
    let isLeader: Bool
    let memberCount: Int
    let members: [TeamMember]
}
