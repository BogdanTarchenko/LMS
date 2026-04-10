import Foundation

struct Assignment: Codable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String?
    var deadline: Date?
    var createdAt: Date
    var submissionStatus: SubmissionStatus?
    var grade: Int?
    var fileUrls: [String]?
    var type: String?
    var isTeamBased: Bool?

    var isQuick: Bool { type == "QUICK" }
    var isTeamAssignment: Bool { isTeamBased == true }
}
