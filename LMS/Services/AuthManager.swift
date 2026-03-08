import Foundation

@Observable
final class AuthManager {
    var isAuthenticated = false
    var currentUser: User?

    let apiService: APIServiceProtocol
    private let keychainHelper: KeychainHelperProtocol

    private static let tokenKey = "lms_auth_token"

    init(apiService: APIServiceProtocol = APIService.shared, keychainHelper: KeychainHelperProtocol = KeychainHelper.shared) {
        self.apiService = apiService
        self.keychainHelper = keychainHelper
    }

    func login(email: String, password: String) async throws {
        let response = try await apiService.login(email: email, password: password)
        applyToken(response.token)
        isAuthenticated = true
        currentUser = response.user
    }

    func register(request: RegisterRequest) async throws {
        let response = try await apiService.register(request: request)
        applyToken(response.token)
        isAuthenticated = true
        currentUser = response.user
    }

    func logout() {
        keychainHelper.delete(forKey: Self.tokenKey)
        if let service = apiService as? APIService {
            service.setToken(nil)
        }
        isAuthenticated = false
        currentUser = nil
    }

    func checkAuth() async {
        guard let token = keychainHelper.get(forKey: Self.tokenKey) else { return }

        if let service = apiService as? APIService {
            service.setToken(token)
        }

        do {
            let user = try await apiService.getProfile()
            isAuthenticated = true
            currentUser = user
        } catch {
            keychainHelper.delete(forKey: Self.tokenKey)
            if let service = apiService as? APIService {
                service.setToken(nil)
            }
            isAuthenticated = false
            currentUser = nil
        }
    }

    private func applyToken(_ token: String) {
        keychainHelper.save(token, forKey: Self.tokenKey)
        if let service = apiService as? APIService {
            service.setToken(token)
        }
    }
}
