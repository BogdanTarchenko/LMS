import Foundation

@Observable
final class AuthManager {
    var isAuthenticated = false
    var currentUser: User?
}

struct User: Codable, Identifiable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var avatarURL: String?
    var dateOfBirth: Date?
}
