import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var avatarURL: String?
    var dateOfBirth: Date?

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email
        case avatarURL = "avatarUrl"
        case dateOfBirth
    }
}
