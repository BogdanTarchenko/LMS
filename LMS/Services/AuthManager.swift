import Foundation

@Observable
final class AuthManager {
    var isAuthenticated = false
    var currentUser: User?
}
