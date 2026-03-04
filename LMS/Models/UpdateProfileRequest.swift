import Foundation

struct UpdateProfileRequest: Codable {
    var firstName: String?
    var lastName: String?
    var dateOfBirth: String?
    var avatarBase64: String?
}
