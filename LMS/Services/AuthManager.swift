import Foundation

@Observable
final class AuthManager {
    var isAuthenticated = false
    var currentUser: User?

    private let apiService: APIServiceProtocol
    private let keychainHelper: KeychainHelperProtocol

    private static let tokenKey = "lms_auth_token"

    init(apiService: APIServiceProtocol = APIService(), keychainHelper: KeychainHelperProtocol = KeychainHelper.shared) {
        self.apiService = apiService
        self.keychainHelper = keychainHelper
    }

    func login(email: String, password: String) async throws {
        let response = try await apiService.login(email: email, password: password)
        keychainHelper.save(response.token, forKey: Self.tokenKey)
        isAuthenticated = true
        currentUser = response.user
    }

    func register(request: RegisterRequest) async throws {
        let response = try await apiService.register(request: request)
        keychainHelper.save(response.token, forKey: Self.tokenKey)
        isAuthenticated = true
        currentUser = response.user
    }

    func logout() {
        keychainHelper.delete(forKey: Self.tokenKey)
        isAuthenticated = false
        currentUser = nil
    }

    func checkAuth() async {
        guard keychainHelper.get(forKey: Self.tokenKey) != nil else { return }

        do {
            let user = try await apiService.getProfile()
            isAuthenticated = true
            currentUser = user
        } catch {
            keychainHelper.delete(forKey: Self.tokenKey)
            isAuthenticated = false
            currentUser = nil
        }
    }
}
