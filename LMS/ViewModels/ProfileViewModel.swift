import Foundation
import PhotosUI
import SwiftUI

@Observable
@MainActor
final class ProfileViewModel {
    var user: User?
    var firstName = ""
    var lastName = ""
    var isEditing = false
    var isLoading = false
    var errorMessage: String?

    var selectedPhoto: PhotosPickerItem?
    var avatarData: Data?
    var avatarImage: UIImage?

    private let authManager: AuthManager
    private let apiService: APIServiceProtocol

    init(authManager: AuthManager, apiService: APIServiceProtocol = APIService.shared) {
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

    func handlePhotoSelection() async {
        guard let selectedPhoto else { return }

        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self) {
                avatarData = data
                avatarImage = UIImage(data: data)
            }
        } catch {
            errorMessage = "Не удалось загрузить фото"
        }
    }

    func updateProfile() async -> Bool {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        var avatarBase64: String?
        if let avatarData {
            // Compress to JPEG for smaller size
            if let uiImage = UIImage(data: avatarData),
               let jpeg = uiImage.jpegData(compressionQuality: 0.7) {
                avatarBase64 = jpeg.base64EncodedString()
            } else {
                avatarBase64 = avatarData.base64EncodedString()
            }
        }

        let request = UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName,
            avatarBase64: avatarBase64
        )

        do {
            let updated = try await apiService.updateProfile(request: request)
            user = updated
            isEditing = false
            avatarData = nil
            avatarImage = nil
            selectedPhoto = nil
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func cancelEditing() {
        guard let user else { return }
        isEditing = false
        firstName = user.firstName
        lastName = user.lastName
        avatarData = nil
        avatarImage = nil
        selectedPhoto = nil
    }

    func logout() {
        authManager.logout()
    }
}
