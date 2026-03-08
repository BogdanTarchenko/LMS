import Foundation

struct Comment: Codable, Identifiable, Hashable {
    let id: String
    var assignmentId: String?
    var authorId: String
    var authorName: String
    var text: String
    var createdAt: Date
}
