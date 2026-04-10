import Foundation

struct Submission: Codable, Identifiable, Hashable {
    let id: String
    var studentId: String
    var studentName: String
    var studentAvatarUrl: String?
    var text: String?
    var fileUrls: [String]?
    var grade: Int?
    var submittedAt: Date
    var teamName: String?

    var displayName: String { teamName ?? studentName }

    enum CodingKeys: String, CodingKey {
        case id, studentId, studentName, studentAvatarUrl
        case text = "answerText"
        case fileUrls
        case grade, submittedAt, teamName
    }
}
