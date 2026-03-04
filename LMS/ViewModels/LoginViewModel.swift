import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var email = ""
    var password = ""
    var emailError: String?
    var passwordError: String?
    var errorMessage: String?
    var isLoading = false

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func login() async {
        emailError = nil
        passwordError = nil
        errorMessage = nil

        guard validate() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.login(email: email.trimmingCharacters(in: .whitespaces), password: password)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validate() -> Bool {
        var isValid = true

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

        return isValid
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: regex) != nil
    }
}
