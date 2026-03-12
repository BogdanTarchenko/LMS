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

    var showAvatarOptions = false
    var showPhotoPicker = false
    var showAvatarAlert = false
    var avatarUrlText = ""

    var selectedPhotoItem: PhotosPickerItem? {
        didSet { Task { await handlePhotoSelection() } }
    }
    var selectedAvatarImage: Image?

    private var pendingAvatarData: Data?
    private var pendingAvatarFileName: String?

    private let authManager: AuthManager
    var apiService: APIServiceProtocol

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

    func promptAvatarChange() {
        showAvatarOptions = true
    }

    func promptAvatarURL() {
        avatarUrlText = user?.avatarURL ?? ""
        showAvatarAlert = true
    }

    private func handlePhotoSelection() async {
        guard let item = selectedPhotoItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }

        let uiImage = UIImage(data: data)
        let jpegData = uiImage?.jpegData(compressionQuality: 0.85) ?? data

        pendingAvatarData = jpegData
        pendingAvatarFileName = "avatar.jpg"

        if let uiImage {
            selectedAvatarImage = Image(uiImage: uiImage)
        }
    }

    func updateProfile() async -> Bool {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        if let data = pendingAvatarData, let fileName = pendingAvatarFileName {
            do {
                let updated = try await apiService.uploadAvatar(imageData: data, fileName: fileName)
                user = updated
                pendingAvatarData = nil
                pendingAvatarFileName = nil
                selectedAvatarImage = nil
                selectedPhotoItem = nil
            } catch let error as NetworkError {
                errorMessage = error.localizedDescription
                return false
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
        }

        let request = UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName,
            avatarUrl: avatarUrlText.isEmpty ? user?.avatarURL : avatarUrlText
        )

        do {
            let updated = try await apiService.updateProfile(request: request)
            user = updated
            isEditing = false
            avatarUrlText = ""
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
        avatarUrlText = ""
        pendingAvatarData = nil
        pendingAvatarFileName = nil
        selectedAvatarImage = nil
        selectedPhotoItem = nil
    }

    func logout() {
        authManager.logout()
    }
}
