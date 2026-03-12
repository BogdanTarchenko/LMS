import Foundation

struct Member: Codable, Identifiable, Hashable {
    var id: String { userId }

    let userId: String
    var firstName: String
    var lastName: String
    var email: String
    var role: Role
    var joinedAt: Date?
    var avatarUrl: String?
}
