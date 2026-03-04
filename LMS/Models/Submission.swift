import Foundation

struct Submission: Codable, Identifiable, Hashable {
    let id: String
    var studentId: String
    var studentName: String
    var text: String?
    var fileURL: String?
    var grade: Int?
    var submittedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, studentId, studentName
        case text = "answerText"
        case fileURL = "fileUrl"
        case grade, submittedAt
    }
}
