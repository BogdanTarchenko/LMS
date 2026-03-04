import Foundation

struct Assignment: Codable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var createdAt: Date
    var submissionStatus: SubmissionStatus?
}
