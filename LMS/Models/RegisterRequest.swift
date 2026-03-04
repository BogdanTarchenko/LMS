import Foundation

struct RegisterRequest: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var dateOfBirth: String?
    var avatarBase64: String?
}
