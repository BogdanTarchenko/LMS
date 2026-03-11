import Foundation

struct UpdateProfileRequest: Codable {
    var firstName: String?
    var lastName: String?
    var dateOfBirth: String?
    var avatarUrl: String?
    var avatarBase64: String?
}
