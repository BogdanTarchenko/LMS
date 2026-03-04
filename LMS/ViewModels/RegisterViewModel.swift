import Foundation
import SwiftUI

@Observable
@MainActor
final class RegisterViewModel {
    var firstName = ""
    var lastName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var dateOfBirth = Date()
    var showDatePicker = false
    var avatarData: Data?

    var firstNameError: String?
    var lastNameError: String?
    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?
    var errorMessage: String?
    var isLoading = false

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func register() async {
        clearErrors()
        guard validate() else { return }

        isLoading = true
        defer { isLoading = false }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let request = RegisterRequest(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            password: password,
            dateOfBirth: showDatePicker ? dateFormatter.string(from: dateOfBirth) : nil,
            avatarBase64: avatarData?.base64EncodedString()
        )

        do {
            try await authManager.register(request: request)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearErrors() {
        firstNameError = nil
        lastNameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        errorMessage = nil
    }

    private func validate() -> Bool {
        var isValid = true

        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            firstNameError = "Введите имя"
            isValid = false
        }

        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            lastNameError = "Введите фамилию"
            isValid = false
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = "Введите email"
            isValid = false
        } else if !isValidEmail(trimmedEmail) {
            emailError = "Неверный формат email"
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Введите пароль"
            isValid = false
        } else if password.count < 8 {
            passwordError = "Пароль должен быть не менее 8 символов"
            isValid = false
        }

        if password != confirmPassword {
            confirmPasswordError = "Пароли не совпадают"
            isValid = false
        }

        return isValid
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: regex) != nil
    }
}
