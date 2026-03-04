import Foundation

struct Comment: Codable, Identifiable, Hashable {
    let id: String
    var authorId: String
    var authorName: String
    var authorAvatarURL: String?
    var text: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, authorId, authorName
        case authorAvatarURL = "authorAvatarUrl"
        case text, createdAt
    }
}
