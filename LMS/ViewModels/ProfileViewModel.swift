import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    var user: User?
    var firstName = ""
    var lastName = ""
    var isEditing = false
    var isLoading = false
    var errorMessage: String?

    private let authManager: AuthManager
    private let apiService: APIServiceProtocol

    init(authManager: AuthManager, apiService: APIServiceProtocol = APIService()) {
        self.authManager = authManager
        self.apiService = apiService
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let profile = try await apiService.getProfile()
            user = profile
            firstName = profile.firstName
            lastName = profile.lastName
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateProfile() async -> Bool {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let request = UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName
        )

        do {
            let updated = try await apiService.updateProfile(request: request)
            user = updated
            isEditing = false
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func logout() {
        authManager.logout()
    }
}
