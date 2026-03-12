import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel: LoginViewModel?
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection

                    VStack(spacing: 24) {
                        if let vm = viewModel {
                            loginForm(vm)
                        }

                        HStack(spacing: 4) {
                            Text("Нет аккаунта?")
                                .foregroundStyle(.secondary)
                            Button("Зарегистрироваться") {
                                showRegister = true
                            }
                            .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LoginViewModel(authManager: authManager)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .overlay {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }
                .shadow(color: .accentColor.opacity(0.4), radius: 20, y: 8)

            VStack(spacing: 6) {
                Text("Добро пожаловать")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Войдите в систему обучения")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private func loginForm(_ vm: LoginViewModel) -> some View {
        VStack(spacing: 16) {
            if let error = vm.errorMessage {
                ErrorBanner(message: error)
            }

            VStack(spacing: 12) {
                AuthField(
                    placeholder: "Email",
                    text: Bindable(vm).email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    error: vm.emailError,
                    accessibilityId: "email_field",
                    errorAccessibilityId: "email_error"
                )

                AuthSecureField(
                    placeholder: "Пароль",
                    text: Bindable(vm).password,
                    icon: "lock",
                    error: vm.passwordError,
                    accessibilityId: "password_field",
                    errorAccessibilityId: "password_error"
                )
            }

            LoadingButton(title: "Войти", isLoading: vm.isLoading) {
                Task { await vm.login() }
            }
            .accessibilityIdentifier("login_button")
        }
    }
}

struct AuthField: View {
    let placeholder: String
    let text: Binding<String>
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    let error: String?
    let accessibilityId: String
    var errorAccessibilityId: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier(accessibilityId)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(error != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
            )

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
                    .accessibilityIdentifier(errorAccessibilityId)
            }
        }
    }
}

struct AuthSecureField: View {
    let placeholder: String
    let text: Binding<String>
    let icon: String
    var textContentType: UITextContentType? = nil
    let error: String?
    let accessibilityId: String
    var errorAccessibilityId: String = ""
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Group {
                    if isRevealed {
                        TextField(placeholder, text: text)
                            .textContentType(.oneTimeCode)
                    } else {
                        SecureField(placeholder, text: text)
                            .textContentType(.oneTimeCode)
                    }
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier(accessibilityId)

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(error != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
            )

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
                    .accessibilityIdentifier(errorAccessibilityId)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager(apiService: MockAPIService(), keychainHelper: MockKeychainHelper()))
}
