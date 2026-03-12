import Foundation

struct UpdateProfileRequest: Codable {
    var firstName: String
    var lastName: String
    var avatarUrl: String?
    var dateOfBirth: String?
}
