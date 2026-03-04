import Foundation

enum SubmissionStatus: String, Codable, Hashable {
    case notSubmitted = "NOT_SUBMITTED"
    case submitted = "SUBMITTED"
    case graded = "GRADED"
}
